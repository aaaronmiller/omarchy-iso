# Review this migration kit

Mode: read-only. Model: claude-sonnet-5-5.

Goal: independent review of ~/code/omarchy-migration. Read scripts/, dotfiles/, configs/, packages/ and ~/code/omarchy-iso/research/LEDGER.md. Find: commands that would fail on Omarchy 4, unsafe steps, prompts that block --auto, duplicated config between dotfiles/ and what Omarchy ships (the user wants the best of each, no duplicates), stale claims. Run `bash -n` and `shellcheck` on every script, and `scripts/test-postinstall.sh`. Write reports/kit-review.md with file:line for each finding, severity, and a proposed patch (do not apply).

## Rules (apply to everything below)
- Never run rm -rf. No wildcards with rm. Deleting or overwriting: show the exact target and what is lost, and stop for the user.
- Never print, paste or store a secret, key or password. Do not read the contents of ~/.secrets or ~/.buttplug; copy by path only.
- Do not touch the Fedora partition except where this task says so, and then read-only.
- Do not start other headless or full-permission sessions. Do not send anything off the machine.
- Write multi-line scripts to a file first, then run the file. Stop processes by recorded PID, never `pkill -f`.
- Report: what you checked (with the command output), what you changed, what is still open. Never say "done" or "verified" without the output that proves it.
- Reports go to ~/code/omarchy-migration/reports/ (create it), not /tmp.
