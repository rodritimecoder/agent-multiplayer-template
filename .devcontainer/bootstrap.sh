#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Installing multiplayer terminal & network tools..."
sudo apt-get update -qq
sudo apt-get install -y -qq tmux jq netcat-openbsd curl

echo "[2/4] Pre-caching Headless Chromium for CDP Browser Skill..."
npx playwright install --with-deps chromium

echo "[3/4] Setting executable permissions on Agent Skills & Scripts..."
find .agents/skills scripts -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} + 2>/dev/null || true

echo "[4/4] Configuring shell profile for Homelab GPU & Multiplayer..."
cat << 'EOF' >> ~/.bashrc

# --- Homelab GPU Bridge & Multiplayer Helpers ---
if [[ -f "$PWD/scripts/connect_homelab_gpu.sh" ]]; then
  source "$PWD/scripts/connect_homelab_gpu.sh" --quiet || true
fi

alias pair-join="tmux new-session -A -s collab"
alias cdp-start='CHROME_BIN=$(find ~/.cache/ms-playwright -name "chrome" -type f | head -n 1); "$CHROME_BIN" --headless=new --no-sandbox --disable-gpu --remote-debugging-port=9222 about:blank &'
EOF

echo "Workspace Ready! Run 'pair-join' for terminal multiplayer or use Live Share in browser."
