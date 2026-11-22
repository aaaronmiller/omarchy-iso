# Two-finger tap = right click (touchscreen)

Reviewed 2026-10-18. Installed by default by `00-postinstall.sh` (the user delegated the decision, 2026-10-18); or run `scripts/60-two-finger-click.sh`. Remove: `scripts/60-two-finger-click.sh --uninstall`.

## What it does
`two-finger-right-click.py` reads the touchscreen (never grabs it, so normal touch is untouched), waits for exactly two fingers down within 150 ms, nearly still (3% of the axis range), lifted within 350 ms, then moves a virtual absolute pointer to the midpoint and sends one right-click. It skips Chrome/Firefox-family windows, which already have their own two-finger-tap menu.

## Review findings (source: the script, 291 lines, read in full)
- **Passive read path:** only `evdev` reads; no grab. Good.
- **Privilege drop:** `hyprctl` is run as the session user (`user=`/`group=`), not root, so a planted socket in the runtime dir cannot make root connect somewhere else. Good.
- **Device detection:** picks multitouch devices with `INPUT_PROP_DIRECT` only, so the touchpad is never bound. Run against this Surface Laptop 4 (Fedora, read-only, 2026-10-18) it found exactly one device: `IPTSD Virtual Touchscreen 045E:0C31` at `/dev/input/event17`, axes 0-9600 x 0-7200. The stylus device has no multitouch slots and is not picked. [verified by running `_touchscreens()`]
- **Weak point (fixed here):** the old unit ran as unrestricted root. The new `two-finger-rightclick.service` drops every capability except `CAP_SETUID/CAP_SETGID` (needed to run hyprctl as the user), makes the filesystem read-only, hides /home, removes network, and allows only `/dev/input*` and `/dev/uinput`. `systemd-analyze verify` is clean and `systemd-analyze security --offline` scores 3.1 OK (an unhardened root service scores in the UNSAFE range). [verified]
- **Not verified:** the actual click injection on real hardware (it needs root to open `/dev/uinput`, and I would not run a root service from a user-writable path on the Fedora box). The installer therefore health-checks the service (active, and the log line `Watching /dev/input/...` within 12 s) and removes itself if that fails.

## Check it works (after install)
1. `systemctl status two-finger-rightclick` shows active; `journalctl -u two-finger-rightclick -b` shows `Watching /dev/input/event... (IPTSD Virtual Touchscreen ...)`.
2. In a non-browser app (Ghostty, a file manager) tap with two fingers: the context menu should open at the touch point. In Chrome/Firefox the log says `skipping` and the browser's own gesture is used.
3. If a normal tap or scroll misbehaves, run `scripts/60-two-finger-click.sh --uninstall`.
