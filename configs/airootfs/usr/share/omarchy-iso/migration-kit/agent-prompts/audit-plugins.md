# Audit Omarchy plugins for the Qt 6.12 hazard

Mode: read-only. Model: claude-sonnet-5-5.

Goal: before any third-party Omarchy/Quickshell plugin is installed, check it. Hazard: Qt 6.12 breaks QML that uses a bare `Color.` (needs the Commons.Color fix, omarchy #14469/#15069/#15265). Check `pacman -Si qt6-declarative` vs installed, and `pacman -Q omarchy`.
For each plugin the user names (default: ai-usagebar, pb3975/omarchy-face-auth): clone into a NEW EMPTY directory under ~/code/plugin-audit/, do not run its code, `rg -n '\bColor\.' --glob '*.qml'`, read install scripts and any hooks it writes, list the files it would create and the commands it would run with sudo. Verdict per plugin: safe / needs patch (show the diff) / do not install. Write reports/plugin-audit.md. Install nothing.

## Rules (apply to everything below)
- Never run rm -rf. No wildcards with rm. Deleting or overwriting: show the exact target and what is lost, and stop for the user.
- Never print, paste or store a secret, key or password. Do not read the contents of ~/.secrets or ~/.buttplug; copy by path only.
- Do not touch the Fedora partition except where this task says so, and then read-only.
- Do not start other headless or full-permission sessions. Do not send anything off the machine.
- Write multi-line scripts to a file first, then run the file. Stop processes by recorded PID, never `pkill -f`.
- Report: what you checked (with the command output), what you changed, what is still open. Never say "done" or "verified" without the output that proves it.
- Reports go to ~/code/omarchy-migration/reports/ (create it), not /tmp.
