-- ~/.config/hypr/input.lua  (Omarchy loads this after its defaults)
-- Ported from Fedora GNOME settings + the old hyprland.conf on 2026-10-17.
--
-- Source values (inventory/gsettings):
--   keyboard: repeat delay 500ms, interval 30ms (~33/s); caps:escape
--   touchpad: speed 0.80, natural scroll, tap-to-click, tap-and-drag, clickfinger,
--             disable-while-typing, edge scroll off
--   mouse:    flat accel, speed 1.0, no natural scroll
--   old quirks file wanted scroll factor 0.5 (it never applied, see libinput quirks note)

hl.config({
  input = {
    kb_layout = "us",
    -- Caps->Escape only. Omarchy's Shift+Caps compose option is NOT included here, so it is off.
    kb_options = "caps:escape,compose:ralt",

    repeat_delay = 500,
    repeat_rate = 33,

    follow_mouse = 1,

    -- External mice: GNOME had flat accel at max speed (1.0); Omarchy sensitivity
    -- scale tops out lower, so 0.6 is the closest available equivalent. VERIFY by feel on first boot.
    sensitivity = 0.6,

    touchpad = {
      natural_scroll = true,
      tap_to_click = true,
      tap_and_drag = true,
      drag_lock = 0,
      disable_while_typing = true,
      clickfinger_behavior = true, -- GNOME click-method 'fingers'
      middle_button_emulation = false,
      scroll_factor = 0.5,         -- "fast movement, slower scroll"
    },
  },
})

-- VERIFY on first boot: per-device overrides in Hyprland's Lua API.
-- Goal: touchpad keeps adaptive accel at 0.8, mice stay flat. Get exact names
-- with `hyprctl devices`. If hl.device isn't the right call, check
-- https://wiki.hypr.land/Configuring/Basics/Devices/ and fix the line below.
hl.device({
  name = "microsoft-surface-045e:09af-touchpad",
  accel_profile = "adaptive",
  sensitivity = 0.8,
})

-- 3-finger gestures, same as your old setup.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "vertical", action = "fullscreen" })

