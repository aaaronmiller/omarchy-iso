#!/usr/bin/env bash
# SUPERSEDED 2026-10-18: face login now uses gaze via agent-prompts/face-login.md. Kept for reference only.
# Windows-Hello-style face login with Howdy + the Surface Laptop 4 IR camera.
#
# PREFERRED: install the pb3975/omarchy-face-auth plugin for sudo/polkit/lock (README Phase 7a),
# then run ONLY step 5 here for the SDDM login screen. Steps 1-4 are the manual fallback.
# IR camera verified 2026-10-17: /dev/video2, GREY 480x480, emitter strobes alternate frames.
# Run on OMARCHY, after 10-omarchy-surface.sh and a reboot into linux-surface.
# DRAFT: untested on target. Writes /etc/howdy and /etc/pam.d — keep a root shell
# open in another TTY (Ctrl+Alt+F3) until you've confirmed password login still works.
set -euo pipefail
IR=/dev/v4l/by-path/pci-0000:00:14.0-usb-0:6:1.2-video-index0

step() { echo; echo "── $*"; read -rp "   run this step? [y/N] " a; [[ $a == y ]]; }

if step "1/5 install howdy-git from AUR (read the PKGBUILD when the helper shows it)"; then
  omarchy-pkg-aur-add howdy-git
fi

if step "2/5 point Howdy at the IR camera + Surface-friendly thresholds"; then
  # howdy 3.x config lives at /etc/howdy/config.ini
  sudo sed -i \
    -e "s|^device_path\s*=.*|device_path = $IR|" \
    -e "s|^dark_threshold\s*=.*|dark_threshold = 90|" \
    -e "s|^timeout\s*=.*|timeout = 6|" \
    -e "s|^certainty\s*=.*|certainty = 3.5|" \
    /etc/howdy/config.ini
  grep -E '^(device_path|dark_threshold|timeout|certainty)' /etc/howdy/config.ini
  echo "   If the IR emitter stays dark during 'sudo howdy test': yay -S linux-enable-ir-emitter && sudo linux-enable-ir-emitter configure"
fi

if step "3/5 enroll your face (do it 3x: normal light, dim light, with glasses if you wear them)"; then
  sudo howdy add
  sudo howdy add
  sudo howdy add
  sudo howdy test
fi

# Lid closed → skip the camera and go straight to password, same idea as Omarchy's fingerprint gate.
GATE='auth      [success=1 default=ignore] pam_exec.so quiet /usr/share/omarchy/bin/omarchy-hw-laptop-closed'
LINE='auth      sufficient pam_howdy.so'
add_face() { # $1 = pam service file
  local f=$1
  [[ -f $f ]] || { echo "   skip $f (missing)"; return; }
  grep -q pam_howdy.so "$f" && { echo "   $f already has howdy"; return; }
  sudo cp -a "$f" "$f.pre-howdy"
  sudo sed -i "1i $LINE" "$f"
  sudo sed -i "/pam_howdy\.so/i $GATE" "$f"
  echo "   ✓ $f (backup: $f.pre-howdy)"
}

if step "4/5 face for sudo, admin prompts, and the lock screen"; then
  add_face /etc/pam.d/sudo
  add_face /etc/pam.d/polkit-1
  add_face /etc/pam.d/omarchy-lock-password
  echo "   Test NOW in a new terminal: sudo -k && sudo true   (look at the camera)"
fi

if step "5/5 login screen: turn off SDDM autologin, add face to the SDDM greeter"; then
  add_face /etc/pam.d/sddm
  # Omarchy writes its autologin into /etc/sddm.conf.d/; disable it (backed up, not deleted).
  for c in /etc/sddm.conf.d/*.conf; do
    if grep -q '^\[Autologin\]' "$c" 2>/dev/null; then
      sudo mv "$c" "$c.disabled-by-face-login"
      echo "   disabled autologin file: $c"
    fi
  done
  echo "   At the SDDM screen: pick your user, press Enter on the empty password field → Howdy scans."
  echo "   That Enter is an SDDM limitation; there's no greeter that starts the scan by itself yet."
fi

echo
echo "Undo any service: sudo mv /etc/pam.d/<name>.pre-howdy /etc/pam.d/<name>"
