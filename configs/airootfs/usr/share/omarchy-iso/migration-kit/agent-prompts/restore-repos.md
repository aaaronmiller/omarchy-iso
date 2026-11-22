# Restore repos

Mode: copies from Fedora read-only. Model: claude-sonnet-5-5.

Goal: restore ~/code from the Fedora partition and report state. Mount the Fedora home read-only as in migrate-secrets (reuse it if mounted). Compare `~/code` on Fedora with the new home; copy missing repos with `cp -a --no-clobber`. For each repo list: branch, dirty or clean (`git status --porcelain | wc -l`), ahead/behind. Known: two repos diverged from upstream (stash, compare, advise; discarding is likely for unused ones) and nine are dirty. Do not pull, reset, stash or discard anything: present a plan per repo in reports/repos.md and wait for the user.

## Rules (apply to everything below)
- Never run rm -rf. No wildcards with rm. Deleting or overwriting: show the exact target and what is lost, and stop for the user.
- Never print, paste or store a secret, key or password. Do not read the contents of ~/.secrets or ~/.buttplug; copy by path only.
- Do not touch the Fedora partition except where this task says so, and then read-only.
- Do not start other headless or full-permission sessions. Do not send anything off the machine.
- Write multi-line scripts to a file first, then run the file. Stop processes by recorded PID, never `pkill -f`.
- Report: what you checked (with the command output), what you changed, what is still open. Never say "done" or "verified" without the output that proves it.
- Reports go to ~/code/omarchy-migration/reports/ (create it), not /tmp.
