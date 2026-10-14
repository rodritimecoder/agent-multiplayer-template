#!/usr/bin/env bash
#!/usr/bin/env python3
import sys
import json
import argparse
import urllib.request
import urllib.error

CDP_BASE = "http://127.0.0.1:9222"

def check_status():
    url = f"{CDP_BASE}/json/version"
    try:
        with urllib.request.urlopen(url, timeout=2) as resp:
            data = json.loads(resp.read().decode())
            print(f"✅ CDP Browser Online: {data.get('Browser', 'Unknown')}")
            print(f"   User-Agent: {data.get('User-Agent', '')}")
            return 0
    except Exception as e:
        print(f"❌ CDP Browser Offline on {CDP_BASE}: {e}")
        print("💡 Run 'cdp-start' or launch Chromium with --remote-debugging-port=9222")
        return 1

def list_targets():
    url = f"{CDP_BASE}/json/list"
    try:
        with urllib.request.urlopen(url, timeout=2) as resp:
            targets = json.loads(resp.read().decode())
            print(f"Active Pages/Tabs ({len(targets)}):")
            for t in targets:
                print(f" - [{t.get('type')}] {t.get('title')} ({t.get('url')})")
            return 0
    except Exception as e:
        print(f"Error querying targets: {e}")
        return 1

def main():
    parser = argparse.ArgumentParser(description="CDP Browser Controller")
    subparsers = parser.add_subparsers(dest="command")

    subparsers.add_parser("status", help="Check if CDP browser is reachable on :9222")
    subparsers.add_parser("list", help="List active targets / tabs")

    nav_p = subparsers.add_parser("navigate", help="Navigate to a URL using Playwright")
    nav_p.add_argument("--url", required=True, help="Target URL")

    shot_p = subparsers.add_parser("screenshot", help="Capture screenshot using Playwright")
    shot_p.add_argument("--url", required=True, help="Target URL")
    shot_p.add_argument("--output", default="/tmp/screenshot.png", help="Output PNG path")

    args = parser.parse_args()

    if args.command == "status" or not args.command:
        sys.exit(check_status())
    elif args.command == "list":
        sys.exit(list_targets())
    elif args.command in ("navigate", "screenshot"):
        try:
            from playwright.sync_api import sync_playwright
        except ImportError:
            print("⚠️ Playwright not installed. Install via: pip install playwright && playwright install chromium")
            sys.exit(1)

        with sync_playwright() as p:
            try:
                browser = p.chromium.connect_over_cdp(CDP_BASE)
            except Exception:
                # Fallback to local launch if CDP daemon isn't up
                browser = p.chromium.launch(headless=True)
            context = browser.new_context()
            page = context.new_page()
            page.goto(args.url)
            print(f"Page Title: {page.title()}")
            if args.command == "screenshot":
                page.screenshot(path=args.output, full_page=True)
                print(f"✅ Saved screenshot to {args.output}")
            else:
                text = page.inner_text("body")[:1000]
                print(f"Page Preview:\n{text}")
            browser.close()

if __name__ == "__main__":
    main()
