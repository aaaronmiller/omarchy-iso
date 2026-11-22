# Tune scroll and pointer

Mode: edits user config after backup. Model: claude-sonnet-5-5.

Goal: make touchpad, mouse wheel and touchscreen feel right on Hyprland. Known state: Fedora ended on libinput flat profile, touchpad scroll natural, Ghostty `mouse-scroll-multiplier = precision:1,discrete:3`; touchscreen scroll in Ghostty and wofi was unexplained (Chrome scrolls by touch).
Steps: read ~/.config/hypr/input.lua (our overlay: drag_lock = 0), `hyprctl devices`, `libinput list-devices`. Ask the user which one feels wrong (fast, slow, jumpy, palm touches) before changing anything.
Change only through ~/.config/hypr/input.lua and ~/.config/ghostty/surface.conf (back up first with a timestamp), then `hyprctl reload && hyprctl configerrors`. Hyprland facts: `drag_lock` is an integer 0-2; `input:scroll_factor` is for external mice, touchpad has its own block `scroll_factor`.
Do NOT install libinput-config or any shim (it was removed on Fedora on purpose). Record each change and how to undo it in reports/tune-input.md.

## Rules (apply to everything below)
- Never run rm -rf. No wildcards with rm. Deleting or overwriting: show the exact target and what is lost, and stop for the user.
- Never print, paste or store a secret, key or password. Do not read the contents of ~/.secrets or ~/.buttplug; copy by path only.
- Do not touch the Fedora partition except where this task says so, and then read-only.
- Do not start other headless or full-permission sessions. Do not send anything off the machine.
- Write multi-line scripts to a file first, then run the file. Stop processes by recorded PID, never `pkill -f`.
- Report: what you checked (with the command output), what you changed, what is still open. Never say "done" or "verified" without the output that proves it.
- Reports go to ~/code/omarchy-migration/reports/ (create it), not /tmp.
