# Multiplayer Cloud Workspace & Homelab GPU Agent Template

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/rodritimecoder/agent-multiplayer-template)

Cloud development environment with **real-time multiplayer** (Browser Live Share, Zed, or `tmux`) connected to a **32GB VRAM Homelab GPU cluster** via Tailscale Funnel + LiteLLM, with automatic failover to **OpenRouter Free** and **Gemini**—plus up to **20 parallel GitHub Actions subagents** and the full **Workstation Code Craft & Review Suite**.

---

## 🎮 Multiplayer Modes (No Cursor Required)

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

---

## 🍽️ On-Demand Code Craft & Review Hub (`doordash`)

Pre-installed inside every Codespace terminal. Enforce senior engineering rigor and automated reviews without prompt bloat:

```bash
# View available kitchens
doordash menu

# Order specific reviews on your working tree or pull request
doordash order ponytail              # Minimal diff & YAGNI audit
doordash order poteto                # Domain modeling & State Transition Matrix
doordash order thermonuclear         # Structural audit & complexity elimination
doordash order create-verification   # Scaffold [REQ-XX] Grounded Verification tests
doordash order unslop                # 31-rule AI tell scanner

# Run the full review combo
doordash order combo
```

---

## 📦 Built-In Agent Skills & Tools

| Skill Directory | Command | Purpose |
|---|---|---|
| [`.agents/skills/craft-hub`](.agents/skills/craft-hub/) | `doordash` / `craft-hub` | Late-binding DoorDash API for code reviews, state matrices, and verification. |
| [`.agents/skills/skills-hub`](.agents/skills/skills-hub/) | `skills-hub` | Meta-tool gateway: dynamically search (`skills-hub search`) and run tools without context bloat. |
| [`.agents/skills/graph-memory`](.agents/skills/graph-memory/) | `graph-memory` | Hybrid BM25 + embedding RAG over project notes, with exact-quote LLM distillation. |
| [`.agents/skills/markitdown-cli`](.agents/skills/markitdown-cli/) | `markitdown-cli` | Universal document converter to Markdown (PDF, DOCX, XLSX, PPTX, CSV, HTML). |
| [`.agents/skills/gh-action-subagent`](.agents/skills/gh-action-subagent/) | `gh-subagent` | Dispatch up to 20 parallel cloud subagents inside GitHub Actions VMs via PRs. |
| [`.agents/skills/openrouter-free`](.agents/skills/openrouter-free/) | `openrouter-free` | Multi-model fallback (Nemotron, Qwen Coder, Gemini 2.5 Flash). |
| [`.agents/skills/tailscale-ops`](.agents/skills/tailscale-ops/) | `tailscale-ops` | Private mesh networking and Tailscale Funnel management. |
| [`.agents/skills/litellm-vram-switcher`](.agents/skills/litellm-vram-switcher/) | `vram-rig-ctl` | Dynamic GPU VRAM switcher and LiteLLM gateway. |
| [`.agents/skills/cdp-browser`](.agents/skills/cdp-browser/) | `cdp-browser` | Headless Chrome DevTools Protocol browser automation. |

---

## ⚡ Connecting Your Homelab GPU Rig to the Cloud Workspace

1. **On your home GPU PC**, expose LiteLLM (`:4000`) over Tailscale Funnel:
   ```bash
   ./scripts/host_expose_gpu.sh
   ```
2. **Add Secrets**: Copy the printed `HOMELAB_LITELLM_URL` and `HOMELAB_LITELLM_KEY` into your GitHub Repo's **Codespaces Secrets** and **Actions Secrets**.
3. **Automatic Bridging**: Inside the Codespace, the bridge is automatically configured on shell startup:
   * **When your PC is awake**: Cloud agents and human collaborators run inference against your dual RX 9060 XT local models (`8080–8090`).
   * **When your PC is off or gaming (`evict-all`)**: Requests seamlessly fail over to `openrouter/free` and `gemini-2.5-flash`.
   * Test the bridge anytime with:
     ```bash
     ./scripts/connect_homelab_gpu.sh
     ```

---

## 📁 Repository Structure

```
agent-multiplayer-template/
├── .devcontainer/
│   ├── devcontainer.json        # Universal container (Node 22, Live Share, port forwarding)
│   └── bootstrap.sh             # Auto-symlinks doordash, skills-hub, and sets up pair-join
├── .github/workflows/
│   └── subagent.yml             # Parallel subagents executing tasks via Pull Requests
├── .agents/skills/              # Curated workstation & cloud skills
│   ├── craft-hub/               # DoorDash code review hub
│   ├── skills-hub/              # Meta-tool discovery gateway
│   ├── graph-memory/            # Local hybrid RAG & distillation
│   ├── markitdown-cli/          # Document to Markdown converter
│   ├── gh-action-subagent/      # Parallel cloud subagents
│   ├── litellm-vram-switcher/   # LiteLLM failover manager
│   ├── tailscale-ops/           # Tailscale mesh & funnel routing
│   ├── openrouter-free/         # Free multi-model inference fallback
│   └── cdp-browser/             # Headless browser automation
└── scripts/
    ├── host_expose_gpu.sh       # Expose home PC LiteLLM securely over Tailscale Funnel
    ├── connect_homelab_gpu.sh   # Bind Codespace environment to homelab GPU
    └── publish_template.sh      # Publish & configure repository as a GitHub Template
```
