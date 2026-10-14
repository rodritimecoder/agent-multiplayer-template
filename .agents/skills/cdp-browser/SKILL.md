---
name: cdp-browser
description: "Headless Chrome DevTools Protocol (CDP) browser skill for web navigation, DOM inspection, screenshotting, and automated verification via local Chromium on port 9222."
---

# CDP Browser Skill

Automates a local or remote headless Chromium instance over the Chrome DevTools Protocol (CDP) on port `9222`.

## Starting the Browser Daemon
In GitHub Codespaces or any Linux machine with Playwright installed:
```bash
cdp-start
```
Or directly:
```bash
CHROME_BIN=$(find ~/.cache/ms-playwright -name "chrome" -type f | head -n 1)
"$CHROME_BIN" --headless=new --no-sandbox --disable-gpu --remote-debugging-port=9222 about:blank &
```

## CLI Usage

### Check CDP Connection
```bash
python3 .agents/skills/cdp-browser/scripts/cdp_ctl.py status
```

### Navigate and Dump Page Text
```bash
python3 .agents/skills/cdp-browser/scripts/cdp_ctl.py navigate --url "https://example.com"
```

### Capture Screenshot
```bash
python3 .agents/skills/cdp-browser/scripts/cdp_ctl.py screenshot --url "https://example.com" --output /tmp/page.png
```
