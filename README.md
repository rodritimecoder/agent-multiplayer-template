# Multiplayer Cloud Workspace & Homelab GPU Agent Template

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/rodritimecoder/agent-multiplayer-template)

Cloud development environment with **real-time multiplayer** (Browser Live Share, Zed, or `tmux`) connected to a **32GB VRAM Homelab GPU cluster** via Tailscale Funnel + LiteLLM, with automatic failover to **OpenRouter Free** and **Gemini**—plus up to **20 parallel GitHub Actions subagents**.

## Quick Start: Multiplayer Modes (No Cursor Required)

1. **Browser Co-Editing (Zero Installs)**:
   Click **Open in GitHub Codespaces** above -> Click the **Live Share** icon on the left sidebar -> Send the invite link to friends. Everyone gets independent cursors, shared terminals, and shared localhost preview ports in their browser.
2. **Terminal Multiplayer (`tmux` + Neovim / Helix / Pi / agy)**:
   Host runs `pair-join` inside the Codespace terminal. Friends connect from their own terminal via:
   ```bash
   gh codespace ssh
   pair-join
   ```
3. **Zed Native Multiplayer**:
   Run `gh codespace ssh --config >> ~/.ssh/config`, connect via Zed Remote Server, and share the project channel.

## Connecting Your Homelab GPU Rig to the Cloud Workspace

1. On your home GPU PC, expose LiteLLM (`:4000`) over Tailscale Funnel:
   ```bash
   ./scripts/host_expose_gpu.sh
   ```
2. Copy the printed `HOMELAB_LITELLM_URL` and `HOMELAB_LITELLM_KEY` into your GitHub Repo's **Codespaces Secrets** and **Actions Secrets**.
3. Inside the Codespace, verify the bridge at any time:
   ```bash
   ./scripts/connect_homelab_gpu.sh
   ```
   - **When your PC is awake**: Agents and collaborators inside the Codespace run inference against your local models (`8080–8090`).
   - **When your PC is off or gaming (`evict-all`)**: Requests seamlessly fail over to `openrouter/free` and `gemini-2.5-flash`.

## Directory Overview

- `.devcontainer/`: Universal Devcontainer configured with Node 22, Live Share, `tmux`, and Playwright headless Chromium.
- `.github/workflows/subagent.yml`: Autonomous cloud subagent pipeline running tasks via PRs.
- `.agents/skills/`:
  - `openrouter-free/`: Multi-model LLM inference with homelab GPU primary target.
  - `gh-action-subagent/`: Dispatcher for parallel cloud subagents.
  - `tailscale-ops/`: Private mesh networking and Tailscale Funnel management.
  - `litellm-vram-switcher/`: Dynamic GPU VRAM switcher and LiteLLM gateway.
  - `cdp-browser/`: Chrome DevTools Protocol automation.
- `scripts/`:
  - `host_expose_gpu.sh`: Run on home PC to expose LiteLLM securely.
  - `connect_homelab_gpu.sh`: Run in Codespace to bind to homelab GPU or fallback.
  - `publish_template.sh`: Publish and configure as a GitHub Template repo.
