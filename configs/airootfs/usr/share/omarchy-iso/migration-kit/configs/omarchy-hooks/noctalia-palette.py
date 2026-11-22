#!/usr/bin/env python3
"""Omarchy theme-set hook: mirror the active Omarchy theme into Noctalia v5, live.

Install:  omarchy hook install theme-set ./50-noctalia-palette
Runs after every `omarchy theme set <name>` (Super+Ctrl+Shift+Space), with the theme name in argv[1].

Omarchy keeps owning app theming (terminal, btop, nvim, Chromium, GTK...). Noctalia only
takes the palette, so both shells look identical and you never theme anything twice.
Leave Noctalia's own builtin_ids = [] so its templates don't fight Omarchy's.
"""
import json, os, re, shutil, subprocess, sys, tomllib
from pathlib import Path

home = Path.home()
theme_dir = home / ".local/state/omarchy/current/theme"
colors_file = theme_dir / "colors.toml"
pal_dir = home / ".config/noctalia/palettes"
cfg_file = home / ".config/noctalia/config.toml"  # VERIFY path on first Noctalia run
PALETTE = "omarchy"

if not colors_file.exists():
    sys.exit(0)
c = tomllib.loads(colors_file.read_text())
g = lambda *keys: next((c[k] for k in keys if k in c), "#888888")

bg, fg = g("background"), g("foreground")
side = {
    "mPrimary": g("accent", "blue"),
    "mOnPrimary": bg,
    "mSecondary": g("magenta", "bright_magenta"),
    "mOnSecondary": bg,
    "mTertiary": g("cyan", "bright_cyan"),
    "mOnTertiary": bg,
    "mError": g("red"),
    "mOnError": bg,
    "mSurface": bg,
    "mOnSurface": fg,
    "mSurfaceVariant": g("lighter_background", "selection"),
    "mOnSurfaceVariant": g("light_foreground", "foreground"),
    "mOutline": g("muted", "dark_foreground"),
    "mShadow": g("darker_background", "dark_background", "background"),
    "mHover": g("selection", "lighter_background"),
    "mOnHover": fg,
    "terminal": {
        "background": bg, "foreground": fg, "cursor": fg, "cursorText": bg,
        "selectionBg": g("selection"), "selectionFg": fg,
        "normal": {"black": g("lighter_background"), "red": g("red"), "green": g("green"),
                   "yellow": g("yellow"), "blue": g("blue"), "magenta": g("magenta"),
                   "cyan": g("cyan"), "white": g("light_foreground", "foreground")},
        "bright": {"black": g("muted"), "red": g("bright_red", "red"), "green": g("bright_green", "green"),
                   "yellow": g("bright_yellow", "yellow"), "blue": g("bright_blue", "blue"),
                   "magenta": g("bright_magenta", "magenta"), "cyan": g("bright_cyan", "cyan"),
                   "white": g("bright_foreground", "foreground")},
    },
}
mode = c.get("mode", "dark")
pal_dir.mkdir(parents=True, exist_ok=True)
# Same colours for both variants; Omarchy themes are single-mode.
(pal_dir / f"{PALETTE}.json").write_text(json.dumps({"dark": side, "light": side}, indent=2))

# Point Noctalia at the palette (idempotent edit of the [theme] table only).
# Creates a minimal config.toml when Noctalia hasn't run yet (else palette is never selected).
# NOTE: GUI overrides in ~/.local/state/noctalia/settings.toml load last and win over this file.
if not cfg_file.exists():
    cfg_file.parent.mkdir(parents=True, exist_ok=True)
    cfg_file.write_text("[theme]\n")
txt = cfg_file.read_text()
want = {"source": '"custom"', "custom_palette": f'"{PALETTE}"', "mode": f'"{mode}"'}
m = re.search(r"(?ms)^\[theme\]\s*\n(.*?)(?=^\[|\Z)", txt)
block = m.group(1) if m else ""
for k, v in want.items():
    line = f"{k} = {v}"
    block = re.sub(rf"(?m)^{k}\s*=.*$", line, block) if re.search(rf"(?m)^{k}\s*=", block) else block + line + "\n"
txt = txt[: m.start(1)] + block + txt[m.end(1):] if m else txt + f"\n[theme]\n{block}"
cfg_file.write_text(txt)

# A GUI-written [theme] in Noctalia's state file loads last and overrides config.toml. Warn, never edit it.
state_file = home / ".local/state/noctalia/settings.toml"
if state_file.exists():
    try:
        state = tomllib.loads(state_file.read_text())
    except Exception:
        state = {}
    if "theme" in state:
        print(f"warning: {state_file} sets its own [theme]; it overrides the Omarchy palette. "
              "Remove that table (or reset the theme in Noctalia's settings) for the hook to take effect.", file=sys.stderr)

# Noctalia hot-reloads config/palette files; nudge it in case. `config-reload` is the documented verb (`theme-reload` does not exist).
if shutil.which("noctalia"):
    subprocess.run(["noctalia", "msg", "config-reload"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
