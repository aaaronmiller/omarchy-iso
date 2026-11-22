# Verify the install

Mode: read-only. Model: claude-sonnet-5-5.

Goal: confirm the Omarchy install on this Surface Laptop 4 is healthy. READ-ONLY: change nothing.
Check, with the command output for each:
1. `uname -r` contains surface; `lsmod` shows surface_aggregator, surface_hid; keyboard and touchpad appear in `libinput list-devices`.
2. Limine lists linux-surface first (`/boot/limine.conf` or the path `limine-mkinitcpio` uses); the stock kernel is gone only if finalize ran (`~/.local/state/omarchy-migration/state`).
3. `ls /var/lib/omarchy/migrations/1789325478` exists (blocks the migration that demotes linux-surface).
4. `iptsd@*.service` state (touchscreen), `hyprctl configerrors`, `pacman -Q qt6-declarative omarchy`, quickshell/shell running.
5. `systemctl --failed`, `journalctl -p err -b --no-pager | tail -40`.
6. Packages from packages/pacman-official.txt and aur.txt are installed (`pacman -Q`).
Write reports/verify-install.md: a table of check / result / evidence, then a list of problems with the exact fix command for each (do not run the fixes).

## Rules (apply to everything below)
- Never run rm -rf. No wildcards with rm. Deleting or overwriting: show the exact target and what is lost, and stop for the user.
- Never print, paste or store a secret, key or password. Do not read the contents of ~/.secrets or ~/.buttplug; copy by path only.
- Do not touch the Fedora partition except where this task says so, and then read-only.
- Do not start other headless or full-permission sessions. Do not send anything off the machine.
- Write multi-line scripts to a file first, then run the file. Stop processes by recorded PID, never `pkill -f`.
- Report: what you checked (with the command output), what you changed, what is still open. Never say "done" or "verified" without the output that proves it.
- Reports go to ~/code/omarchy-migration/reports/ (create it), not /tmp.
