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

# 2. Ensure LiteLLM Gateway is running on port 4000 with master_key protection
LITELLM_CFG=".agents/skills/litellm-vram-switcher/config/litellm_config.yaml"
if ! ss -tulpn 2>/dev/null | grep -q ":4000 "; then
  echo "Starting LiteLLM Gateway on 127.0.0.1:4000..."
  nohup litellm \
    --config "$LITELLM_CFG" \
    --port 4000 \
    --host 127.0.0.1 \
    --master_key "$HOMELAB_LITELLM_KEY" \
    > /tmp/litellm_funnel.log 2>&1 &
  sleep 2
fi

# 3. Enable Tailscale Funnel on port 4000 -> public HTTPS 443
tailscale funnel --bg --https=443 http://127.0.0.1:4000

TS_DNS=$(tailscale status --json | jq -r '.Self.DNSName | rtrimstr(".")')

echo "============================================================"
echo "Homelab GPU Gateway is LIVE via Tailscale Funnel!"
echo "Add these two secrets to GitHub Settings -> Secrets -> Codespaces & Actions:"
echo ""
echo "  HOMELAB_LITELLM_URL = https://${TS_DNS}/v1"
echo "  HOMELAB_LITELLM_KEY = ${HOMELAB_LITELLM_KEY}"
echo "============================================================"
