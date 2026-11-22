#!/usr/bin/env bash
# Run on FEDORA if, after installing Omarchy, the laptop boots straight into Fedora.
# omacom/omarchy #10598 (open, 4.0.2+): free-space installs can finish without registering
# Limine in UEFI NVRAM. The files are all on Omarchy's ESP — only the boot entry is missing.
# Also covers #7867: the installer may create its own ESP instead of reusing Fedora's.
set -euo pipefail

echo "→ looking for an ESP that holds Limine"
found=""
while read -r dev parttype; do
  [[ ${parttype,,} == c12a7328-f81f-11d2-ba4b-00a0c93ec93b ]] || continue   # EFI System Partition
  mnt=$(mktemp -d)
  if sudo mount -o ro "$dev" "$mnt" 2>/dev/null; then
    loader=$(sudo find "$mnt/EFI" -maxdepth 2 -iname 'limine_x64.efi' 2>/dev/null | head -1)
    sudo umount "$mnt"
    if [[ -n $loader ]]; then found="$dev|${loader#"$mnt"}"; fi
  fi
  rmdir "$mnt"
done < <(lsblk -rno PATH,PARTTYPE /dev/nvme0n1)

[[ -n $found ]] || { echo "No ESP with limine_x64.efi found — Omarchy install didn't write its bootloader." >&2; exit 1; }
dev=${found%%|*}; path=${found#*|}
part=$(cat "/sys/class/block/$(basename "$dev")/partition")
efipath=$(echo "$path" | tr '/' '\\')
echo "   Limine on $dev (partition $part): $efipath"

if efibootmgr | grep -qi 'limine\|omarchy'; then
  echo "   An Omarchy/Limine NVRAM entry already exists:"; efibootmgr | grep -i 'limine\|omarchy'
else
  read -rp "Register it as 'Omarchy' and put it first in the boot order? [y/N] " a; [[ $a == y ]] || exit 0
  sudo efibootmgr --create --disk /dev/nvme0n1 --part "$part" --label "Omarchy" --loader "$efipath"
fi

new=$(efibootmgr | awk '/Omarchy|[Ll]imine/{sub(/^Boot/,"",$1); sub(/\*$/,"",$1); print $1; exit}')
order=$(efibootmgr | awk -F': ' '/^BootOrder/{print $2}')
sudo efibootmgr --bootorder "$new,$(echo "$order" | tr ',' '\n' | grep -v "^$new$" | paste -sd,)"
efibootmgr | head -4
echo "Reboot → Limine. Fedora stays reachable from Limine (auto-detected or via limine-fedora-entry) and from the Surface boot menu."
