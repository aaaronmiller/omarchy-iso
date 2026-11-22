#!/usr/bin/env bash
# Rebind hid-multitouch after resume (javon27/omarchy-surface-touch pattern).
# Triggered by 99-surface-touchpad.rules for Microsoft USB devices.
set -euo pipefail
for d in /sys/bus/hid/drivers/hid-multitouch/0003:045E:*; do
  [[ -e $d ]] || continue
  id=$(basename "$d")
  echo "$id" | sudo tee /sys/bus/hid/drivers/hid-multitouch/unbind >/dev/null
  echo "$id" | sudo tee /sys/bus/hid/drivers/hid-multitouch/bind >/dev/null
done
