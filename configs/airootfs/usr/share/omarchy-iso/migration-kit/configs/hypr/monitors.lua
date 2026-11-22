-- ~/.config/hypr/monitors.lua
-- Surface Laptop 4 13.5": 2256x1504 @ 60Hz, 201 PPI.
-- 1.333333 divides the panel cleanly (1692x1128 logical), so nothing goes blurry.
-- Old hyprland.conf used 1.33; GNOME used 1.0 with text scale 1.04.
-- VERIFY syntax against Omarchy's shipped ~/.config/hypr/monitors.lua and keep its style.
hl.monitor({ output = "eDP-1", mode = "2256x1504@60", position = "0x0", scale = 1.333333 })

-- Any external display: preferred mode, auto placement to the right.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
