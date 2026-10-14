---
name: openrouter-free
description: >
  Execute LLM completions, coding tasks, and tool-calling loops using free OpenRouter models
  (such as NVIDIA Nemotron, Qwen Coder, and openrouter/free) via OPENROUTER_API_KEY with
  automatic rate-limit fallback to Gemini. Use when offloading subagent tasks, getting a second
  model opinion, or bypassing primary model quotas.
---

# OpenRouter Free-Tier Skill

Use this skill to run tasks or subagent loops against zero-cost OpenRouter endpoints without switching CLIs.

## Prerequisites
Ensure `OPENROUTER_API_KEY` is exported in the environment.
Optional: export `GEMINI_API_KEY` as a fallback when free OpenRouter endpoints return HTTP 429 or 503.

## How to Invoke

### 1. Direct Single-Turn / Delegated Prompt
Run the bundled script:

```bash
python3 ~/my-agent-skills/openrouter-free/scripts/or_agent.py \
  --prompt "Analyze src/auth.ts for race conditions and output a unified diff." \
  --model "nvidia/llama-3.1-nemotron-70b-instruct:free"
```

### 2. Automatic Free Router Mode
If you do not care which free model answers and want maximum uptime with tool-calling support, omit `--model` or pass `openrouter/free`:

```bash
python3 ~/my-agent-skills/openrouter-free/scripts/or_agent.py \
  --prompt "Write unit tests for utils/parser.js" \
  --model "openrouter/free"
```

## Available Free Model Targets (Priority Cascade)
1. `nvidia/llama-3.1-nemotron-70b-instruct:free` (High reasoning & code)
2. `qwen/qwen-2.5-coder-32b-instruct:free` (Fast code generation & patching)
3. `openrouter/free` (Auto-routes to fastest available zero-cost tool-capable model)
4. Fallback: `gemini-2.5-flash` (Triggered automatically if all OpenRouter free tiers return 429/503)

## Pitfalls to Avoid
- Free endpoints enforce 20 RPM and daily caps. Do not spawn tight polling loops in a single second.
- Always let `or_agent.py` handle retries rather than manually retrying failed bash calls.
