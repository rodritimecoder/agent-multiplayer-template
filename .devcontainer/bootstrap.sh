#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Installing multiplayer terminal & network tools..."
sudo apt-get update -qq
sudo apt-get install -y -qq tmux jq netcat-openbsd curl ripgrep

echo "[2/5] Pre-caching Headless Chromium for CDP Browser Skill..."
npx playwright install --with-deps chromium

echo "[3/5] Setting executable permissions on Agent Skills & Scripts..."
find .agents/skills scripts -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} + 2>/dev/null || true

echo "[4/5] Symlinking Engineering & Review CLIs into PATH..."
sudo ln -sf "$PWD/.agents/skills/skills-hub/scripts/skills_hub.py" /usr/local/bin/skills-hub
sudo ln -sf "$PWD/.agents/skills/craft-hub/scripts/craft_hub.py" /usr/local/bin/craft-hub
sudo ln -sf "$PWD/.agents/skills/craft-hub/scripts/craft_hub.py" /usr/local/bin/doordash

echo "[5/5] Configuring shell profile for Homelab GPU & Multiplayer..."
cat << 'EOF' >> ~/.bashrc

# --- Homelab GPU Bridge & Multiplayer Helpers ---
if [[ -f "$PWD/scripts/connect_homelab_gpu.sh" ]]; then
  source "$PWD/scripts/connect_homelab_gpu.sh" --quiet || true
fi

alias pair-join="tmux new-session -A -s collab"
alias cdp-start='CHROME_BIN=$(find ~/.cache/ms-playwright -name "chrome" -type f | head -n 1); "$CHROME_BIN" --headless=new --no-sandbox --disable-gpu --remote-debugging-port=9222 about:blank &'
EOF

echo "✅ Workspace Ready! Run 'pair-join' for terminal multiplayer, 'doordash' for reviews, or 'skills-hub' for tools."
