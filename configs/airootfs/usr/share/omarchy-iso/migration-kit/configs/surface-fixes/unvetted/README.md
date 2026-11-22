# Unvetted Surface fixes (from the omp sweep, javon27/omarchy-surface-touch patterns)

Moved here and disabled in scripts/10-omarchy-surface.sh on 2026-10-18 after review. Not deleted.
Reasons, checked against this laptop (Surface Laptop 4, Intel):

- iptsd-override.conf: a full service unit installed as a drop-in for iptsd.service. This system runs
  iptsd@.service (template, one instance per hidraw device), so the drop-in targets a unit that does not exist.
  A working version would be a drop-in at /etc/systemd/system/iptsd@.service.d/restart.conf with
  [Service] Restart=always and RestartSec=1. Untested.
- 99-surface-touchpad.rules: fires on ANY Microsoft USB device (the Surface Dock hubs are 045e), and wants
  rebind-surface-touchpad.service, which does not exist. Its own comment says it targets the Pro 7+ and Go.
- rebind-surface-touchpad.sh: unbinds USB HID devices (bus 0003). The Laptop 4 keyboard and touchpad use the
  Surface Aggregator (surface_hid), not USB.
- two-finger right-click: REVIEWED 2026-10-18 and moved to ../two-finger-click/ (hardened unit, opt-in installer scripts/60-two-finger-click.sh).

Re-enable only after reading the code and testing on the laptop.
