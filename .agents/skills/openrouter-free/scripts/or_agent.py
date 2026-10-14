#!/usr/bin/env python3
"""
or_agent.py — OpenRouter Free-Tier LLM & Tool-Calling Runner with Gemini Fallback
"""

import argparse
import json
import os
import subprocess
import sys
import time
import urllib.request
import urllib.error

DEFAULT_CASCADE = [
    {
        "provider": "homelab-litellm",
        "model": "agent-coder",
        "url": os.environ.get("HOMELAB_LITELLM_URL", "http://127.0.0.1:4000/v1").rstrip("/") + "/chat/completions",
        "env_key": "HOMELAB_LITELLM_KEY",
    },
    {
        "provider": "openrouter",
        "model": "nvidia/llama-3.1-nemotron-70b-instruct:free",
        "url": "https://openrouter.ai/api/v1/chat/completions",
        "env_key": "OPENROUTER_API_KEY",
    },
    {
        "provider": "openrouter",
        "model": "openrouter/free",
        "url": "https://openrouter.ai/api/v1/chat/completions",
        "env_key": "OPENROUTER_API_KEY",
    },
    {
        "provider": "gemini",
        "model": "gemini-2.5-flash",
        "url": "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
        "env_key": "GEMINI_API_KEY",
    },
]

TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "run_bash",
            "description": "Execute a shell command in the workspace (git, tests, CDP browser verification, file edits).",
            "parameters": {
                "type": "object",
                "properties": {
                    "command": {"type": "string", "description": "Shell command to execute"}
                },
                "required": ["command"],
            },
        },
    }
]


def call_llm(messages, preferred_model=None, enable_tools=True):
    cascade = list(DEFAULT_CASCADE)
    if preferred_model and preferred_model != "openrouter/free":
        cascade.insert(
            0,
            {
                "provider": "openrouter",
                "model": preferred_model,
                "url": "https://openrouter.ai/api/v1/chat/completions",
                "env_key": "OPENROUTER_API_KEY",
            },
        )

    last_err = None
    for target in cascade:
        api_key = os.environ.get(target["env_key"])
        if not api_key:
            continue

        payload = {
            "model": target["model"],
            "messages": messages,
        }
        if enable_tools:
            payload["tools"] = TOOLS

        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://github.com/local-agent",
            "X-Title": "Agent Workspace Subagent",
        }

        req = urllib.request.Request(
            target["url"],
            data=json.dumps(payload).encode("utf-8"),
            headers=headers,
            method="POST",
        )

        for retry in range(2):
            try:
                with urllib.request.urlopen(req, timeout=90) as resp:
                    data = json.loads(resp.read().decode("utf-8"))
                    choice = data["choices"][0]
                    return choice["message"], target["model"]
            except urllib.error.HTTPError as e:
                err_body = e.read().decode("utf-8", errors="ignore")
                sys.stderr.write(f"[openrouter-free] {target['model']} HTTP {e.code}: {err_body[:200]}\n")
                last_err = f"HTTP {e.code}: {err_body[:100]}"
                if e.code in (429, 503) and retry == 0:
                    time.sleep(3)
                    continue
                break
            except Exception as e:
                sys.stderr.write(f"[openrouter-free] {target['model']} error: {e}\n")
                last_err = str(e)
                break

    raise RuntimeError(f"All free models and fallbacks failed. Last error: {last_err}")


def run_agent_loop(prompt, preferred_model="openrouter/free", max_turns=15):
    system_prompt = (
        "You are an autonomous coding and browser verification subagent running in a Linux environment. "
        "You have bash access (`run_bash`) to view/edit files, run git, run tests, and use CDP browser tools on port 9222. "
        "Complete the task, verify your changes, and output a concise summary."
    )
    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": prompt},
    ]

    for turn in range(1, max_turns + 1):
        sys.stderr.write(f"\n[Turn {turn}/{max_turns}] Querying model...\n")
        msg, active_model = call_llm(messages, preferred_model=preferred_model)
        messages.append(msg)

        tool_calls = msg.get("tool_calls")
        if not tool_calls:
            print(f"\n--- Completed via {active_model} ---")
            print(msg.get("content", ""))
            return

        for tc in tool_calls:
            fn_name = tc.get("function", {}).get("name")
            raw_args = tc.get("function", {}).get("arguments", "{}")
            try:
                args = json.loads(raw_args) if isinstance(raw_args, str) else raw_args
            except Exception:
                args = {"command": raw_args}

            if fn_name == "run_bash":
                cmd = args.get("command", "")
                sys.stderr.write(f"[Tool: run_bash] {cmd}\n")
                try:
                    proc = subprocess.run(
                        cmd,
                        shell=True,
                        capture_output=True,
                        text=True,
                        timeout=120,
                    )
                    output = (proc.stdout + "\n" + proc.stderr).strip()[:8000]
                    if not output:
                        output = f"(exit code {proc.returncode}, no output)"
                except subprocess.TimeoutExpired:
                    output = "Error: Command timed out after 120 seconds."
                except Exception as ex:
                    output = f"Execution error: {ex}"

                messages.append(
                    {
                        "role": "tool",
                        "tool_call_id": tc["id"],
                        "name": fn_name,
                        "content": output,
                    }
                )

    print(f"\n⚠️ Max turns ({max_turns}) reached before task marked complete.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Autonomous OpenRouter Free / Gemini agent loop")
    parser.add_argument("--prompt", required=True, help="Task instructions for the agent")
    parser.add_argument("--model", default="openrouter/free", help="Preferred OpenRouter model ID")
    parser.add_argument("--max-turns", type=int, default=15, help="Maximum conversation turns")
    args = parser.parse_args()

    run_agent_loop(args.prompt, args.model, args.max_turns)
