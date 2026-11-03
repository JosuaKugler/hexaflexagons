#!/usr/bin/env bash
# Run tests.html in headless Chromium and print its results. Exits 0 if every check passes.
set -euo pipefail
cd "$(dirname "$0")"
PORT="${PORT:-8765}"
python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null' EXIT
sleep 0.5
BROWSER="$(command -v chromium || command -v chromium-browser || command -v google-chrome)"
"$BROWSER" --headless=new --disable-gpu --no-sandbox --virtual-time-budget=120000 \
  --dump-dom "http://127.0.0.1:$PORT/tests.html" 2>/dev/null | python3 -c '
import sys, html, re
dom = sys.stdin.read()
def text(s): return html.unescape(re.sub(r"<[^>]+>", "", s)).strip()
m = re.search(r"<div id=\"summary\">(.*?)</div>", dom, re.S)
summary = text(m.group(1)) if m else "FAIL: no result (page did not finish)"
print(summary, "\n")
for row in re.findall(r"<tr>(.*?)</tr>", dom, re.S):
    cells = re.findall(r"<td[^>]*>(.*?)</td>", row, re.S)
    if len(cells) == 3:
        name = text(re.sub(r"<span.*?</span>", "", cells[0], flags=re.S))
        print(f"[{text(cells[1])}] {name}\n        {text(cells[2])}".replace("\n", "\n        ", 1))
sys.exit(0 if summary.startswith("PASS") else 1)
'
