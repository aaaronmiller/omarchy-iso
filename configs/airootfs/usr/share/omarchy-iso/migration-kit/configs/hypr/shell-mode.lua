-- ~/.config/hypr/shell-mode.lua
-- Lets you flip between the Omarchy shell (Quickshell) and Noctalia v5.
-- Add `require("hypr.shell-mode")` at the END of ~/.config/hypr/hyprland.lua.
-- Switch with:  shell-switch noctalia | shell-switch omarchy
--
-- How it works: Omarchy autostarts `omarchy-launch-shell` from PATH and forces its
-- own bin dir to the front. We re-prepend a shim dir AFTER Omarchy's defaults, so
-- the shim decides which shell to start based on ~/.config/shell-mode.

local home = os.getenv("HOME")
local shim_dir = home .. "/.local/share/shell-switch/bin"

local function read_mode()
  local f = io.open(home .. "/.config/shell-mode", "r")
  if not f then return "omarchy" end
  local m = (f:read("*l") or "omarchy"):gsub("%s+", "")
  f:close()
  return m
end

hl.env("PATH", shim_dir .. ":" .. (os.getenv("PATH") or "/usr/local/bin:/usr/bin"))

if read_mode() ~= "noctalia" then return end

-- Noctalia mode: point the main bindings at Noctalia's IPC instead of omarchy-shell.
local ipc = "noctalia msg "
o.rebind("SUPER + SPACE", "Launcher", ipc .. "panel-toggle launcher")
o.rebind("SUPER + S", "Control center", ipc .. "panel-toggle control-center")
o.rebind("SUPER + comma", "Noctalia settings", ipc .. "settings-toggle")  -- Omarchy key string is case-sensitive: "comma"
o.rebind("SUPER + CTRL + L", "Lock", ipc .. "session lock")  -- verb per Noctalia docs; VERIFY with `noctalia msg --help`
-- Media and brightness: o.rebind replaces Omarchy's binds on these keys (plain hl.bind stacked on top and double-fired).
local repeat_opts = { locked = true, repeating = true }
o.rebind("XF86AudioRaiseVolume", "Volume up", ipc .. "volume-up", repeat_opts)
o.rebind("XF86AudioLowerVolume", "Volume down", ipc .. "volume-down", repeat_opts)
o.rebind("XF86AudioMute", "Mute", ipc .. "volume-mute", repeat_opts)
o.rebind("XF86MonBrightnessUp", "Brightness up", ipc .. "brightness-up", repeat_opts)
o.rebind("XF86MonBrightnessDown", "Brightness down", ipc .. "brightness-down", repeat_opts)

hl.window_rule({ match = { class = "dev.noctalia.Noctalia" }, float = true, size = { 1080, 920 } })
hl.layer_rule({
  name = "noctalia",
  match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
  no_anim = true,
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true,
})
