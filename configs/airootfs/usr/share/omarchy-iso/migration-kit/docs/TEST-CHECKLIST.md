# Custom Omarchy ISO: test checklist (Surface Laptop 4)

Before flashing
- [ ] Build finished, ISO path and sha256 recorded
- [ ] ISO size fits the target (check the Ventoy stick free space first)

First boot of the live ISO (USB keyboard NOT plugged in)
- [ ] Built-in keyboard types at the Ventoy/GRUB menu
- [ ] Built-in keyboard types in the installer
- [ ] Touchpad moves the pointer

Install
- [ ] Free-space install, LUKS on
- [ ] Installer selects linux-surface (check the kernel line in the installer log)

First boot of the installed system
- [ ] LUKS prompt accepts typing from the built-in keyboard (test kernel parameter reboot=pci if it doesn't)
- [ ] Shows linux-surface in `uname -r`
- [ ] Touchpad and touchscreen work
- [ ] Limine lists Omarchy, snapshots and Fedora

Fallback if the built-in keyboard fails at LUKS
- USB keyboard for the prompt, then run scripts/10-omarchy-surface.sh

Round 2 additions (upstream drift check)
- [ ] Installed system: migration 1789325478.sh installs linux-omarchy on non-T2 x86 without its marker and rewrites BOOT_ORDER (demotes linux-surface). Check the marker and BOOT_ORDER before first reboot; keep linux-surface first.
- [ ] Initramfs size: our image is about 244 MB, the range where omarchy-iso #128 (GRUB OOM at 241 MiB) fails. If GRUB reports out of memory, use Ventoy GRUB2 mode or the dd route.
- [ ] surface_kbd is not in our zz- drop-in; upstream includes it. Compare with the installed modules (modinfo) before relying on ours.
