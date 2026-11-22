# Migrate secrets from the Fedora partition

Mode: reads Fedora read-only, copies by path. Model: claude-sonnet-5-5.

Goal: bring the user's secrets across from the Fedora install, which is left untouched.
1. Find the Fedora root: `lsblk -f`; mount it READ-ONLY (`sudo mount -o ro,subvol=home ...` or the matching btrfs/ext4 form) at a new empty directory under /mnt. Show the user the mount command before running it.
2. List candidate files by NAME only: ~/.secrets, ~/.buttplug, ~/.ssh, ~/.gnupg, ~/.config/gh, ~/.aws, ~/.config/git. Never cat them. Ask the user which to copy.
3. Copy chosen paths with `cp -a --no-clobber` into the matching place in $HOME, then `chmod 600` files and `chmod 700` dirs (ssh, gnupg). Verify with `stat -c '%a %n'` and `ssh-keygen -lf <pubkey>` fingerprints only. Unmount.
4. Report names, modes and fingerprints in reports/secrets-migration.md, never contents.

## Rules (apply to everything below)
- Never run rm -rf. No wildcards with rm. Deleting or overwriting: show the exact target and what is lost, and stop for the user.
- Never print, paste or store a secret, key or password. Do not read the contents of ~/.secrets or ~/.buttplug; copy by path only.
- Do not touch the Fedora partition except where this task says so, and then read-only.
- Do not start other headless or full-permission sessions. Do not send anything off the machine.
- Write multi-line scripts to a file first, then run the file. Stop processes by recorded PID, never `pkill -f`.
- Report: what you checked (with the command output), what you changed, what is still open. Never say "done" or "verified" without the output that proves it.
- Reports go to ~/code/omarchy-migration/reports/ (create it), not /tmp.
