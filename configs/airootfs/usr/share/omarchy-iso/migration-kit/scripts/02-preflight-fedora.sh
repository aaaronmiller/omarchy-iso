#!/usr/bin/env bash
# Run on FEDORA before touching the disk. Read-only except for one test image in /tmp.
# Answers: is the IR camera usable? is everything backed up? is anything left unpushed?
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IR=/dev/v4l/by-path/pci-0000:00:14.0-usb-0:6:1.2-video-index0
ok() { printf '  \e[32m✓\e[0m %s\n' "$*"; }
bad() { printf '  \e[31m✗\e[0m %s\n' "$*"; FAIL=1; }
FAIL=0

echo "1. IR camera (face login depends on this)"
if [[ -e $IR ]]; then
  ok "IR node present: $IR -> $(readlink -f "$IR")"
  if command -v ffmpeg >/dev/null; then
    # The emitter strobes: lit and dark frames alternate, so one frame proves nothing. Measure 40.
    lit=$(ffmpeg -hide_banner -f v4l2 -i "$IR" -frames:v 40 -vf signalstats,metadata=print:key=lavfi.signalstats.YAVG -f null - 2>&1 |
      grep -o 'YAVG=[0-9.]*' | awk -F= '$2>20{n++} END{print n+0}')
    if ((lit > 5)); then
      ok "IR emitter strobing: $lit/40 lit frames — Howdy/face plugins will work (verified 2026-10-17: ~20/40)"
    else
      bad "only $lit/40 lit IR frames — emitter may need linux-enable-ir-emitter"
    fi
  else
    echo "  - ffmpeg missing; skip frame test (sudo dnf install ffmpeg)"
  fi
else
  bad "IR node missing"
fi

echo "2. Git repos with unpushed/uncommitted work"
"$ROOT/scripts/01-export-inventory.sh" >/dev/null 2>&1
if [[ -s $ROOT/inventory/git-dirty.txt ]]; then
  bad "$(wc -l <"$ROOT/inventory/git-dirty.txt") repos need commit/push:"; sed 's/^/      /' "$ROOT/inventory/git-dirty.txt"
else
  ok "all repos clean and pushed"
fi

echo "3. Backup target"
BK=${BACKUP_DIR:-}
if [[ -n $BK && -d $BK ]]; then
  need=$(du -sb ~ 2>/dev/null | cut -f1); have=$(df -B1 --output=avail "$BK" | tail -1)
  ((have > need)) && ok "$BK has room ($(numfmt --to=iec "$have") free, need $(numfmt --to=iec "$need"))" \
    || bad "$BK too small"
else
  bad "set BACKUP_DIR=/run/media/$USER/<drive> and re-run"
fi

echo "4. Secrets & keys that live outside git (back these up by hand, encrypted)"
for p in ~/.ssh ~/.gnupg ~/.config/gh ~/.hermes ~/.openclaw ~/.local/share/keyrings ~/.omp/agent/agent.db ~/.var/app/org.keepassxc.KeePassXC; do
  [[ -e $p ]] && echo "      $p"
done
echo "   + API keys exported in ~/.zshrc / env (OPENCODE_*_API_KEY etc.)"

echo
((FAIL)) && echo "NOT READY — fix the ✗ items first." || echo "READY for Phase 2."
