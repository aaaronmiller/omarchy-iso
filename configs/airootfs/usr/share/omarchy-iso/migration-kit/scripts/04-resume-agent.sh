#!/usr/bin/env zsh
# One-shot: launched by ~/.config/autostart/omarchy-resume-agent.desktop after the next login.
# Opens Claude in the migration folder with the hand-off prompt, then disarms the autostart
# (renamed to *.done, not deleted) so it only fires once. Re-arm: drop the .done suffix.
KIT=~/code/omarchy-migration
AUTOSTART=~/.config/autostart/omarchy-resume-agent.desktop
[[ -f $AUTOSTART ]] && mv "$AUTOSTART" "$AUTOSTART.done"

cd "$KIT" || exit 1
prompt="$(<NEXT-AGENT-PROMPT.md)

---
## You are starting automatically right after a reboot (launched by scripts/04-resume-agent.sh)

Do these post-reboot checks first, report results in one short table, then continue with Phase 1:
1. \`uname -r\` must be 6.19.8-3.surface.fc43.x86_64. If not, STOP and tell the user which kernel booted.
2. Keyboard + touchpad + touchscreen work (ask the user to confirm the touchscreen with a tap).
3. \`journalctl -b --user | grep -i quirks\` shows no 'Failed to load'; \`sudo libinput quirks list\` on the touchpad shows palm 80/70, thumb 60/55.
4. \`grep . /sys/class/powercap/intel-rapl:0/constraint_{0,1}_power_limit_uw\` = 28000000 / 45000000.
5. \`systemctl is-active surface-battery-watchdog thermald power-profiles-daemon\` all active; \`cat /sys/class/power_supply/{ADP1/online,BAT1/status,BAT1/capacity}\`.
6. \`podman ps\` shows sonarr/radarr/lidarr/prowlarr up with no crash loop.

## Then WORK AUTONOMOUSLY — perform every task, don't just report
- Don't stop after the checks. Fix anything that failed, then execute every remaining task that can be
  done from this running Fedora system, end to end, without asking permission step by step
  (bypass-permissions mode is on; the user said: perform all needed tasks).
- Keep a running task list (TodoWrite) and work it top to bottom. Verify each step's result before the next.
- Includes: the preflight script, any repo/backup/dotfile prep, removing the redundant touchpad-blocker /
  libinput-config autostarts if the now-working quirks make them redundant (test first), staging
  everything Omarchy will need, and re-syncing ~/code/omarchy-migration to the Ventoy stick if plugged in.
- Only stop for things that physically need the user: booting GParted/Omarchy from USB, the Surface UEFI
  (Secure Boot off), typing passwords. When you reach one, give exact numbered steps for it, then keep
  doing anything else that's still possible.
- Collect genuine decisions (chezmoi dotfiles repo name/visibility; merge vs reset for the 2 conflicted
  repos) and ask them together ONCE, as early as possible, while continuing other work. Pushing to GitHub
  is outward-facing: confirm before creating repos or pushing.
- Hard rules still apply: surface kernels only, Fedora is never removed, no rm -rf, steering = queue.
- Finish with a short table: done / needs the user / still queued."

exec claude "$prompt"
