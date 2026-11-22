#!/usr/bin/env bash
# Post-install runner for the freshly installed Omarchy system. Safe to re-run; finished steps are skipped.
#
#   00-postinstall.sh                interactive: asks before every step
#   00-postinstall.sh --auto         no prompts; resumes itself after the reboot that stage 1 needs
#   00-postinstall.sh --dry-run      print the plan, change nothing
# Flags: --no-finalize (never remove the stock kernel), --include-optional (also install opt-in packages),
#        --reboot (reboot by itself after stage 1; 15 s countdown), --resume (used by the autostart entry),
#        --agent (after the steps, run the read-only verify-install agent; needs claude logged in)
# Env:   STATE_DIR (default ~/.local/state/omarchy-migration), KERNEL_RELEASE (test override for uname -r)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATE_DIR="${STATE_DIR:-$HOME/.local/state/omarchy-migration}"
STATE="$STATE_DIR/state"
AUTOSTART="${AUTOSTART_FILE:-$HOME/.config/autostart/omarchy-migration-resume.desktop}"
KREL="${KERNEL_RELEASE:-$(uname -r)}"

export ASSUME_YES=0 INCLUDE_OPTIONAL=0
DRY=0 NO_FINALIZE=0 DO_REBOOT=0 RESUME=0 WITH_AGENT=0
for a in "$@"; do
  case $a in
    --auto) ASSUME_YES=1 ;;
    --dry-run) DRY=1 ;;
    --no-finalize) NO_FINALIZE=1 ;;
    --include-optional) INCLUDE_OPTIONAL=1 ;;
    --reboot) DO_REBOOT=1 ;;
    --resume) RESUME=1; ASSUME_YES=1 ;;
    --agent) WITH_AGENT=1 ;;
    -h|--help) sed -n 2,10p "$0"; exit 0 ;;
    *) echo "unknown flag: $a" >&2; exit 2 ;;
  esac
done
source "$ROOT/scripts/lib-auto.sh"

step() { printf '\n== %s\n' "$*"; }
done_step() { grep -qx "$1" "$STATE" 2>/dev/null; }
mark() { ((DRY)) || { mkdir -p "$STATE_DIR"; echo "$1" >>"$STATE"; }; }
run() { if ((DRY)); then echo "   DRY: $*"; else "$@"; fi; }
FAILED=()
# attempt NAME CMD...: run a step command, record it as done, or record the failure loudly (never silently).
attempt() { local n=$1; shift; if run "$@"; then mark "$n"; else FAILED+=("$n"); echo "!! step failed: $n" >&2; return 1; fi; }

if ((DRY)); then echo "DRY RUN: nothing below is executed or written."
else command -v omarchy-pkg-add >/dev/null || { echo "This is for the installed Omarchy system (omarchy-pkg-add not found)." >&2; exit 1; }; fi

# Disarm the resume entry as soon as we run again, so a failure cannot loop at every login.
if ((RESUME)) && [[ -f $AUTOSTART ]]; then rm -- "$AUTOSTART"; echo "resume entry removed: $AUTOSTART"; fi

# One password prompt up front, kept alive for the whole run (auto mode only).
if ((ASSUME_YES && !DRY)); then
  sudo -v
  ( while true; do sudo -n true 2>/dev/null || exit; sleep 50; done ) &
  KEEPALIVE=$!
  trap 'kill "$KEEPALIVE" 2>/dev/null || true' EXIT
fi

step "1. Surface kernel and drivers"
if [[ $KREL == *surface* ]]; then
  echo "Running on $KREL."
  if done_step tweaks; then echo "Surface tweaks already applied"
  elif confirm "Apply the Surface tweaks (initramfs modules, Limine boot order, power limits, libinput quirks, watchdogs)?"; then
    attempt tweaks bash "$ROOT/scripts/10-omarchy-surface.sh" --tweaks || true
  fi
  if done_step finalized; then echo "already finalized"
  elif ((NO_FINALIZE)); then echo "skipped (--no-finalize): stock kernel stays"
  elif confirm "Run --finalize (snapshot, then remove the stock kernel after safety checks)?"; then
    attempt finalized bash "$ROOT/scripts/10-omarchy-surface.sh" --finalize || true
  fi
else
  echo "Running on $KREL, not linux-surface."
  if done_step stage1; then
    echo "Stage 1 already done. Reboot and pick linux-surface in Limine, then run this script again."; exit 0
  elif confirm "Run stage 1 (adds linux-surface; a reboot follows)?"; then
    attempt stage1 bash "$ROOT/scripts/10-omarchy-surface.sh" || { echo "Stage 1 failed; not scheduling a reboot." >&2; exit 1; }
    if ((ASSUME_YES)); then
      echo "   resume entry: $AUTOSTART (Omarchy itself ships ~/.config/autostart entries, e.g. limine-snapper-notify.desktop; if nothing opens after login, run: $0 --auto)"
      if ((!DRY)); then
        mkdir -p "$(dirname "$AUTOSTART")"
        printf '[Desktop Entry]\nType=Application\nName=Omarchy migration resume\nExec=%q %q --resume\n' "$ROOT/scripts/launch-terminal.sh" "$ROOT/scripts/00-postinstall.sh" >"$AUTOSTART"
      else echo "   DRY: write $AUTOSTART"; fi
    fi
    echo "Reboot into linux-surface, then run this script again."
    if ((DO_REBOOT)); then
      echo "Rebooting in 15 s (Ctrl-C cancels)"; ((DRY)) || { sleep 15; systemctl reboot; }
    fi
    exit 0
  fi
fi

step "2. Packages (lists in packages/*.txt; extras are opt-in)"
if done_step packages; then echo "already done"
elif confirm "Install the verified package lists?"; then attempt packages bash "$ROOT/scripts/40-overlay.sh" || true; fi

step "3. Dotfiles overlay (stow; dry run first)"
if done_step dotfiles; then echo "already done"; else
  (cd "$ROOT/dotfiles" && ./install.sh) || { FAILED+=(dotfiles-dryrun); echo "!! dotfiles dry run failed" >&2; }
  if confirm "Apply the overlay (existing files are moved aside with a timestamp)?"; then
    attempt dotfiles bash -c "cd '$ROOT/dotfiles' && ./install.sh --apply" || true
  fi
fi

step "4. Noctalia palette hook (keeps Noctalia's colours in step with the Omarchy theme)"
hook_dir="$HOME/.config/omarchy/hooks"
if done_step hook; then echo "already done"
elif confirm "Install the hook?"; then
  run mkdir -p "$hook_dir"
  run install -m755 "$ROOT/configs/omarchy-hooks/noctalia-palette.py" "$hook_dir/noctalia-palette.py"
  if ((DRY)) || omarchy hook --help >/dev/null 2>&1; then
    run omarchy hook install theme-set "$ROOT/configs/omarchy-hooks/theme-set.d/50-noctalia-palette"
  else
    echo "'omarchy hook' not available here. Install the wrapper yourself:"
    echo "  $ROOT/configs/omarchy-hooks/theme-set.d/50-noctalia-palette  ->  Omarchy's theme-set hook folder"
  fi
  mark hook
fi

step "5. Two-finger right-click on the touchscreen (hardened root service, health-checked, rolls itself back if unhealthy; remove: scripts/60-two-finger-click.sh --uninstall)"
if done_step twofinger; then echo "already done"
elif confirm "Install it?"; then attempt twofinger bash "$ROOT/scripts/60-two-finger-click.sh" || true; fi

step "Done"
if ((!DRY)); then
  mkdir -p "$ROOT/reports"
  {
    echo "# Post-install summary ($(date -Is))"
    echo "Kernel: $KREL"
    echo "Steps recorded in $STATE:"; sed 's/^/- /' "$STATE" 2>/dev/null || echo "- none"
    echo
    if ((${#FAILED[@]})); then echo; echo "FAILED STEPS (re-run this script to retry): ${FAILED[*]}"; fi
    echo "Still yours to do: face login (agent-assist.sh run face-login --agent), secrets from Fedora (migrate-secrets), repos (restore-repos), extras (scripts/50-extras.sh --list), theme/shell switching ($ROOT/dotfiles/APPEARANCE.md)."
  } >"$ROOT/reports/postinstall-summary.md"
  echo "summary: $ROOT/reports/postinstall-summary.md"
  command -v notify-send >/dev/null && notify-send "Omarchy post-install finished" "Summary: $ROOT/reports/postinstall-summary.md" || true
fi
if ((WITH_AGENT)); then
  if command -v claude >/dev/null; then run "$ROOT/scripts/agent-assist.sh" run verify-install --agent
  else echo "claude not installed; skipping the verify agent"; fi
fi
if ((${#FAILED[@]})); then echo "FAILED STEPS: ${FAILED[*]}  (details above; re-run to retry only those)" >&2; fi
echo "Appearance switching: $ROOT/dotfiles/APPEARANCE.md"
echo "Agent help (verify, scroll tuning, plugin audit, face login, secrets, repos):  $ROOT/scripts/agent-assist.sh list"
((ASSUME_YES)) && ((!DRY)) && read -rp "Press Enter to close" _ || true
((${#FAILED[@]} == 0))
