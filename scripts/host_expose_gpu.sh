#!/usr/bin/env bash
set -euo pipefail

# 1. Generate or load a persistent master key for friends/Codespaces
ENV_FILE="$HOME/.homelab_litellm.env"
if [[ ! -f "$ENV_FILE" ]]; then
  GEN_KEY="sk-homelab-$(openssl rand -hex 12)"
  echo "export HOMELAB_LITELLM_KEY=\"$GEN_KEY\"" > "$ENV_FILE"
  chmod 600 "$ENV_FILE"
fi
source "$ENV_FILE"

# 2. Determine target inference port (llama-swap :8000 -> LiteLLM :4000 -> Direct :8080)
if ss -tulpn 2>/dev/null | grep -q ":8000 "; then
  TARGET_PORT=8000
  echo "Targeting active llama-swap proxy on port 8000..."
elif ss -tulpn 2>/dev/null | grep -q ":4000 "; then
  TARGET_PORT=4000
  echo "Targeting active LiteLLM Gateway on port 4000..."
elif ss -tulpn 2>/dev/null | grep -q ":8080 "; then
  TARGET_PORT=8080
  echo "Targeting direct primary LLM on port 8080..."
else
  TARGET_PORT=8000
  echo "Starting llama-swap on port 8000..."
  vram-rig-ctl llama-swap-up || true
fi

# 3. Enable Tailscale Funnel on selected port -> public HTTPS 443
tailscale funnel --bg --https=443 "http://127.0.0.1:${TARGET_PORT}"

TS_DNS=$(tailscale status --json | jq -r '.Self.DNSName | rtrimstr(".")')

echo "============================================================"
echo "Homelab GPU Gateway is LIVE via Tailscale Funnel!"
echo "Add these two secrets to GitHub Settings -> Secrets -> Codespaces & Actions:"
echo ""
echo "  HOMELAB_LITELLM_URL = https://${TS_DNS}/v1"
echo "  HOMELAB_LITELLM_KEY = ${HOMELAB_LITELLM_KEY}"
echo "============================================================"
