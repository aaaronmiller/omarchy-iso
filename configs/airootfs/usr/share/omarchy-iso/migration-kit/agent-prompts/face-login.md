# Set up face login (gaze)

Mode: interactive, each system change approved by the user. Model: claude-sonnet-5-5.

Decision (user, 2026-10-18): face login YES, with gaze. The pb3975/omarchy-face-auth plugin stays off (bare `Color.` breaks on Qt 6.12, lock patch stale); the Howdy script scripts/20-face-login.sh is superseded.
Source: ~/code/omarchy-iso/research/omp-recovered/r3-face.md (omp, 2026-10-17). Camera: USB-UVC IR at /dev/video2, GREY 480x480, strobing emitter; TPM2 present.

Preflight (stop and report if any fails; print the output of each):
1. `v4l2-ctl --list-devices` and `v4l2-ctl -d /dev/video2 --all`: confirm the IR node. `ls /dev/tpmrm0`. `grep -m1 -o avx2 /proc/cpuinfo`.
2. `pacman -Si opencv | rg '^Version'`: gaze-bin pins opencv >=5.0,<5.1. If the repo has another version, stop and report; do not force it.
3. Back up /etc/pam.d/sudo and /etc/pam.d/polkit-1 with a timestamp. Ask the user to open a second TTY (Ctrl+Alt+F3) logged in as root and keep it open until the end. gaze-bin's installer rewrites those two PAM files (opt out via /etc/gaze/pam-sudo.optout if the user prefers).

Install (use the -bin names ONLY; an unrelated AUR package called `gaze` is a file watcher):
`omarchy-pkg-aur-add gaze-bin gaze-gui-bin gaze-omarchy-bin`, then `systemctl status gazed`, `gaze config` (IR device, emitter, TPM-encrypted templates), `gaze add-face default` (the user must be in front of the camera), `gaze-omarchy enable`, `gaze-omarchy doctor`.
Test in this order, each with the password fallback still working: `sudo -k; sudo -v`, polkit prompt, lock screen. Do NOT touch SDDM/login-screen PAM until the three above work.

Rollback: `gaze-omarchy disable` BEFORE removing packages (the package refuses otherwise), restore the PAM backups, `systemctl disable --now gazed`, `pacman -Rns` the trio. Enrollments in /var/lib/gaze survive.
Write reports/face-login.md: preflight outputs, what you changed, test results, rollback commands.

## Rules (apply to everything below)
- Never run rm -rf. No wildcards with rm. Deleting or overwriting: show the exact target and what is lost, and stop for the user.
- Never print, paste or store a secret, key or password. Do not read the contents of ~/.secrets or ~/.buttplug; copy by path only.
- Do not touch the Fedora partition except where this task says so, and then read-only.
- Do not start other headless or full-permission sessions. Do not send anything off the machine.
- Write multi-line scripts to a file first, then run the file. Stop processes by recorded PID, never `pkill -f`.
- Report: what you checked (with the command output), what you changed, what is still open. Never say "done" or "verified" without the output that proves it.
- Reports go to ~/code/omarchy-migration/reports/ (create it), not /tmp.
