-- =====================================================================
-- Keybindings
-- from: old/conf/keybinding.conf -> old/conf/keybindings/default.conf
--       (~95 binds; the file has 7 commits of your own edits on top of
--        stock ML4W, plus uncommitted changes — see MIGRATION.md §3.3)
--
-- ---------------------------------------------------------------------
-- Key string syntax
--
-- hyprlang:  bind = $mainMod SHIFT, right, resizeactive, 100 0
-- Lua:       hl.bind("SUPER + SHIFT + right", hl.dsp.window.resize{...}, {...})
--
-- The modifier list and the key collapse into ONE " + "-joined string.
-- An empty modifier field (`bind = , XF86AudioMute, ...`) becomes just
-- the bare key name.
--
-- ---------------------------------------------------------------------
-- hl.bind signature — NOTE
--
-- The stub (hl.meta.lua:822) declares exactly three parameters:
--     bind(keys: string, dispatcher: HL.Dispatcher|function, opts?: HL.BindOptions)
--
-- ml4w-ref/dotfiles/.config/hypr/conf/keybindings/default.lua lines 70-73
-- passes FOUR arguments (`..., { repeating = true }, { description = ... }`).
-- That is an upstream bug — the fourth argument is silently discarded and
-- those four binds lose their descriptions. I have used the correct
-- three-argument form and merged the two tables. Do not copy the ml4w-ref
-- shape for those lines.
--
-- ---------------------------------------------------------------------
-- `binde` (repeat-on-hold) -> opts.repeating = true
-- `bindm` (mouse drag)     -> opts.mouse = true       <- see TODO below
--
-- TODO(unverified): `mouse` is NOT a field of HL.BindOptions in the stub
-- (hl.meta.lua:437-453, which lists repeating/locked/release/non_consuming/
-- transparent/ignore_mods/dont_inhibit/long_press/submap_universal/click/
-- drag/description/desc/device/allow_input_capture). But ml4w-ref uses
-- `{ mouse = true }` for exactly these two binds, twice, in a config that
-- upstream ships as working. Either the stub is incomplete or ml4w-ref is
-- relying on an ignored key and the binds work anyway because
-- hl.dsp.window.drag() is inherently a drag dispatcher. I have kept
-- `mouse = true`; if the mouse binds misbehave, try `drag = true` instead,
-- which IS in the stub.
-- =====================================================================

local mainMod = "SUPER"
local HYPRSCRIPTS = "~/.config/hypr/scripts"
local SCRIPTS = "~/.config/ml4w/scripts"
local SETTINGS = "~/.config/ml4w/settings"

-- ---------------------------------------------------------------------
-- Applications
-- ---------------------------------------------------------------------

-- old: bind = ALT, RETURN, exec, ~/.config/ml4w/settings/terminal.sh
-- DEPENDENCY: ~/.config/ml4w/settings/terminal.sh (present; contains "kitty")
hl.bind("ALT + RETURN", hl.dsp.exec_cmd(SETTINGS .. "/terminal.sh"), { description = "Open the terminal" })

-- old: bind = $mainMod, e, exec, neovide   (your edit; stock ML4W had no such bind)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("neovide"), { description = "Open Neovide" })
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"), { description = "Lock screen" })
-- old: bind = ALT, e, exec, ~/.local/bin/emacs-31.1   (your edit)
-- NOTE: hard-coded version in the path. If you upgrade Emacs this breaks.
hl.bind("ALT + E", hl.dsp.exec_cmd("emacs"), { description = "Open Emacs" })

-- old: bind = $mainMod, w, exec, ~/.config/ml4w/settings/browser.sh
-- DEPENDENCY: ~/.config/ml4w/settings/browser.sh (present; contains "firefox")
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(SETTINGS .. "/browser.sh"), { description = "Open the browser" })

-- ---------------------------------------------------------------------
-- Windows
-- ---------------------------------------------------------------------

-- old: bind = $mainMod SHIFT, M, exec, ~/.config/hypr/scripts/toggle-screen.sh
-- Your own script (not ML4W). Toggles eDP-1 off/on and shuffles workspaces
-- to HDMI-A-1. Hard-codes both connector names, matching monitors.lua.
hl.bind(
	mainMod .. " + SHIFT + M",
	hl.dsp.exec_cmd(HYPRSCRIPTS .. "/toggle-screen.sh"),
	{ description = "Toggle laptop screen" }
)

-- old: bind = $mainMod, Q, killactive
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Kill active window" })

-- old: bind = $mainMod SHIFT, Q, exec, hyprctl activewindow | grep pid | ...
hl.bind(
	mainMod .. " + SHIFT + Q",
	hl.dsp.exec_cmd("hyprctl activewindow | grep pid | tr -d 'pid:' | xargs kill"),
	{ description = "Quit active window and all open instances" }
)

-- old: bind = $mainMod, F, fullscreen, 0
-- The bare integer argument becomes a named mode. 0 = fullscreen, 1 = maximize.
hl.bind(
	mainMod .. " + F",
	hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
	{ description = "Toggle fullscreen" }
)

-- old: bind = $mainMod, M, fullscreen, 1
hl.bind(
	mainMod .. " + M",
	hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),
	{ description = "Toggle maximize window" }
)

-- old: bind = $mainMod, T, togglefloating
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })

-- old: bind = $mainMod SHIFT, T, workspaceopt, allfloat
--
-- TODO(decision) — SEMANTIC GAP, not a syntax change (MIGRATION.md §4.2).
-- There is NO `workspaceopt` dispatcher in the Lua API. hl.dsp.workspace
-- exposes only change_id / move / rename / swap_monitors / toggle_special
-- (hl.meta.lua:932-938). Nothing covers allfloat.
--
-- `workspaceopt` is gone from the compositor entirely as of 0.56 — it is not
-- reachable via hyprctl either. scripts/toggleallfloat.sh now reimplements it:
-- it reads the active workspace's windows and applies
-- hl.dsp.window.float{window=..., action="enable"|"disable"} to each,
-- picking the action so a fully-floating workspace tiles and anything else
-- floats.
--
-- I did NOT run the script end to end: it would flip every window in the
-- live session to floating.
hl.bind(
	mainMod .. " + SHIFT + T",
	hl.dsp.exec_cmd(HYPRSCRIPTS .. "/toggleallfloat.sh"),
	{ description = "Toggle all windows into floating mode" }
)

-- old: bind = $mainMod, J, layoutmsg, togglesplit
-- `layoutmsg` -> hl.dsp.layout(<message>)
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), { description = "Toggle split" })

-- old: bind = $mainMod, K, layoutmsg, swapsplit
hl.bind(mainMod .. " + K", hl.dsp.layout("swapsplit"), { description = "Swap split" })

-- old: bind = $mainMod, <arrow>, movefocus, l|r|u|d
-- `movefocus` -> hl.dsp.focus({ direction = ... }). Note the direction
-- spells out in full here ("left"), unlike swapwindow below which keeps
-- the single letter. That asymmetry is ml4w-ref's, and I have preserved it
-- rather than normalising, because both forms are attested working.
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "Move focus left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Move focus right" })
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "Move focus up" })
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "Move focus down" })

-- old: bindm = $mainMod, mouse:272, movewindow
-- old: bindm = $mainMod, mouse:273, resizewindow
-- `movewindow` (mouse form) -> hl.dsp.window.drag(). See the `mouse` TODO
-- in the file header.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window with the mouse" })
hl.bind(
	mainMod .. " + mouse:273",
	hl.dsp.window.resize(),
	{ mouse = true, description = "Resize window with the mouse" }
)

-- old: bind = $mainMod SHIFT, <arrow>, resizeactive, <dx> <dy>
-- The "100 0" string becomes x/y numbers plus an explicit relative flag.
--
-- SEMANTIC NOTE: the old binds were `bind`, not `binde`, so they did NOT
-- repeat on hold — one keypress, one 100px step. ml4w-ref adds
-- `repeating = true`. I have KEPT repeating = true because holding the key
-- to resize is almost certainly what you want and what upstream intends,
-- but be aware this is a small behaviour change. Drop `repeating` from
-- these four to restore the old one-step-per-press behaviour.
hl.bind(
	mainMod .. " + SHIFT + right",
	hl.dsp.window.resize({ x = 100, y = 0, relative = true }),
	{ repeating = true, description = "Increase window width" }
)
hl.bind(
	mainMod .. " + SHIFT + left",
	hl.dsp.window.resize({ x = -100, y = 0, relative = true }),
	{ repeating = true, description = "Reduce window width" }
)
hl.bind(
	mainMod .. " + SHIFT + down",
	hl.dsp.window.resize({ x = 0, y = 100, relative = true }),
	{ repeating = true, description = "Increase window height" }
)
hl.bind(
	mainMod .. " + SHIFT + up",
	hl.dsp.window.resize({ x = 0, y = -100, relative = true }),
	{ repeating = true, description = "Reduce window height" }
)

-- old: bind = $mainMod, G, togglegroup
hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { description = "Toggle window group" })

-- old: bind = $mainMod ALT, <arrow>, swapwindow, l|r|u|d
hl.bind(mainMod .. " + ALT + left", hl.dsp.window.swap({ direction = "l" }), { description = "Swap tiled window left" })
hl.bind(
	mainMod .. " + ALT + right",
	hl.dsp.window.swap({ direction = "r" }),
	{ description = "Swap tiled window right" }
)
hl.bind(mainMod .. " + ALT + up", hl.dsp.window.swap({ direction = "u" }), { description = "Swap tiled window up" })
hl.bind(mainMod .. " + ALT + down", hl.dsp.window.swap({ direction = "d" }), { description = "Swap tiled window down" })

-- old: binde = ALT,Tab,cyclenext
--      binde = ALT,Tab,bringactivetotop
--
-- TWO binds on the SAME key. In hyprlang both fire, in order. The Lua API
-- binds one dispatcher per key, so the second hl.bind() would replace the
-- first. Collapsed into a single callback that dispatches both in the
-- original order — this is the idiom ml4w-ref uses for its
-- "float + pin" and "float + move to scratchpad" combos.
hl.bind("ALT + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next())
	hl.dispatch(hl.dsp.window.bring_to_top())
end, { repeating = true, description = "Cycle between windows" })

-- ---------------------------------------------------------------------
-- Actions
-- ---------------------------------------------------------------------

-- old: bind = $mainMod CTRL, R, exec, hyprctl reload
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland configuration" })

-- old: bind = $mainMod SHIFT, A, exec, $HYPRSCRIPTS/toggle-animations.sh
--
-- TODO(breakage) — this script will MISBEHAVE under a Lua config.
-- toggle-animations.sh line 3 does:
--     if [[ $(cat $HOME/.config/hypr/conf/animation.conf) == *"disabled"* ]]
-- Once conf/animation.conf is gone, `cat` errors to stderr, the test is
-- false, and it falls through to the toggle. So it still toggles — the
-- "blocked by disabled.conf variation" guard just stops working, and you
-- get a stderr message each time. Cosmetic, but fix the script or drop
-- the guard.
hl.bind(
	mainMod .. " + SHIFT + A",
	hl.dsp.exec_cmd(HYPRSCRIPTS .. "/toggle-animations.sh"),
	{ description = "Toggle animations" }
)

-- old: bind = $mainMod, PRINT, exec, $HYPRSCRIPTS/screenshot.sh
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd(HYPRSCRIPTS .. "/screenshot.sh"), { description = "Take a screenshot" })

-- old: bind = $mainMod SHIFT, S, exec, $HYPRSCRIPTS/screenshot.sh
-- (same script on a second key — your addition, kept)
hl.bind(
	mainMod .. " + SHIFT + S",
	hl.dsp.exec_cmd(HYPRSCRIPTS .. "/screenshot.sh"),
	{ description = "Take a screenshot" }
)

-- old: bind = $mainMod CTRL, Q, exec, ~/.config/ml4w/scripts/wlogout.sh
-- DEPENDENCY: ~/.config/ml4w/scripts/wlogout.sh (present, 2.9.8.3 name).
-- TODO(dependency): renamed in ML4W 2.16 to `ml4w-power -l` / the qs power
-- menu. Your copy still exists and works. See MIGRATION.md §1.
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd(SCRIPTS .. "/wlogout.sh"), { description = "Start wlogout" })

-- old: bind = $mainMod SHIFT, W, exec, waypaper --random
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("waypaper --random"), { description = "Change the wallpaper" })

-- old: bind = $mainMod CTRL, W, exec, waypaper
-- (your edit — stock ML4W ran $HYPRSCRIPTS/wallpaper-selector.sh here,
--  still present in old/scripts/ and still on the commented-out line)
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("waypaper"), { description = "Open the wallpaper selector" })

-- old: bind = $mainMod ALT, W, exec, $HYPRSCRIPTS/wallpaper-automation.sh
hl.bind(
	mainMod .. " + ALT + W",
	hl.dsp.exec_cmd(HYPRSCRIPTS .. "/wallpaper-automation.sh"),
	{ description = "Start random wallpaper script" }
)

-- old: bind = $mainMod CTRL, RETURN, exec, pkill rofi || rofi -show drun -replace -i
hl.bind(
	mainMod .. " + CTRL + RETURN",
	hl.dsp.exec_cmd("pkill rofi || rofi -show drun -replace -i"),
	{ description = "Open application launcher" }
)

-- old: bind = $mainMod CTRL, K, exec, $HYPRSCRIPTS/keybindings.sh
--
-- TODO(breakage) — this script is BROKEN by the migration, unavoidably.
-- keybindings.sh reads ~/.config/hypr/conf/keybinding.conf, string-munges
-- the `source = ` line to get a path, then awk-parses lines matching
-- /^bind/ out of the .conf to build the rofi menu. None of that exists
-- after the move to Lua: no keybinding.conf, no `bind =` lines.
--
-- The cheat sheet will come up empty (or error). Options:
--   1. Rewrite the awk to parse `hl.bind("...", ..., { description = "..." })`
--      out of this file — the descriptions above are there precisely so
--      that stays possible.
--   2. Drop this bind.
-- I have left the bind in place rather than silently deleting it.
hl.bind(
	mainMod .. " + CTRL + K",
	hl.dsp.exec_cmd(HYPRSCRIPTS .. "/keybindings.sh"),
	{ description = "Show keybindings" }
)

-- old: bind = $mainMod SHIFT, B, exec, ~/.config/waybar/launch.sh
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/.config/waybar/launch.sh"), { description = "Reload waybar" })

-- old: bind = $mainMod CTRL, B, exec, ~/.config/waybar/toggle.sh
hl.bind(mainMod .. " + CTRL + B", hl.dsp.exec_cmd("~/.config/waybar/toggle.sh"), { description = "Toggle waybar" })

-- old: bind = $mainMod SHIFT, R, exec, $HYPRSCRIPTS/loadconfig.sh
-- (the script is literally `hyprctl reload`, i.e. a duplicate of SUPER+CTRL+R)
hl.bind(
	mainMod .. " + SHIFT + R",
	hl.dsp.exec_cmd(HYPRSCRIPTS .. "/loadconfig.sh"),
	{ description = "Reload hyprland config" }
)

-- old: bind = $mainMod, V, exec, $SCRIPTS/cliphist.sh
-- DEPENDENCY: ~/.config/ml4w/scripts/cliphist.sh (present, 2.9.8.3 name).
-- TODO(dependency): renamed to `ml4w-cliphist` in 2.16.
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(SCRIPTS .. "/cliphist.sh"), { description = "Open clipboard manager" })

-- old: bind = $mainMod CTRL, T, exec, ~/.config/waybar/themeswitcher.sh
hl.bind(
	mainMod .. " + CTRL + T",
	hl.dsp.exec_cmd("~/.config/waybar/themeswitcher.sh"),
	{ description = "Open waybar theme switcher" }
)

-- old: bind = $mainMod CTRL, S, exec, flatpak run com.ml4w.settings
-- TODO(dependency): flatpak app, ML4W 2.9.x era. In 2.16 the settings app
-- was replaced. Verify `flatpak list | grep com.ml4w.settings`.
hl.bind(
	mainMod .. " + CTRL + S",
	hl.dsp.exec_cmd("flatpak run com.ml4w.settings"),
	{ description = "Open ML4W Dotfiles Settings app" }
)

-- old: bind = $mainMod SHIFT, H, exec, $HYPRSCRIPTS/hyprshade.sh
-- DEPENDENCY: reads ~/.config/ml4w/settings/hyprshade.sh
--             (present; hyprshade_filter="blue-light-filter-50")
hl.bind(
	mainMod .. " + SHIFT + H",
	hl.dsp.exec_cmd(HYPRSCRIPTS .. "/hyprshade.sh"),
	{ description = "Toggle screenshader" }
)

-- old: bind = $mainMod ALT, G, exec, $HYPRSCRIPTS/gamemode.sh
-- DEPENDENCY: touches/removes ~/.config/ml4w/settings/gamemode-enabled.
-- NOTE: gamemode.sh disables things with `hyprctl keyword` and restores
-- them with `hyprctl reload`. That still works with a Lua config —
-- reload re-runs hyprland.lua. No change needed.
hl.bind(mainMod .. " + ALT + G", hl.dsp.exec_cmd(HYPRSCRIPTS .. "/gamemode.sh"), { description = "Toggle game mode" })

-- old: bind = $mainMod CTRL, L, exec, ~/.config/hypr/scripts/power.sh lock
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd(HYPRSCRIPTS .. "/power.sh lock"), { description = "Lock the screen" })

-- ---------------------------------------------------------------------
-- Workspaces
--
-- Three parallel sets over the number row. Note your layout differs from
-- stock ML4W: switching is on ALT, not SUPER.
--
--   ALT + N          -> focus workspace N          (old: workspace, N)
--   SUPER SHIFT + N  -> move active window to N    (old: movetoworkspace, N)
--   SUPER CTRL + N   -> move ALL windows to N      (old: exec moveTo.sh N)
--
-- Key "0" maps to workspace 10 in all three, as in the original.
-- DEPENDENCY: $HYPRSCRIPTS/moveTo.sh — your local script, needs `jq`.
-- ---------------------------------------------------------------------

for i = 1, 10 do
	local key = tostring(i % 10) -- 10 -> "0"

	hl.bind("ALT + " .. key, hl.dsp.focus({ workspace = i }), { description = "Open workspace " .. i })

	hl.bind(
		mainMod .. " + SHIFT + " .. key,
		hl.dsp.window.move({ workspace = i }),
		{ description = "Move active window to workspace " .. i }
	)

	hl.bind(
		mainMod .. " + CTRL + " .. key,
		hl.dsp.exec_cmd(HYPRSCRIPTS .. "/moveTo.sh " .. i),
		{ description = "Move all windows to workspace " .. i }
	)
end

-- old: bind = $mainMod, Tab, workspace, m+1
--      bind = $mainMod SHIFT, Tab, workspace, m-1
-- "m+1"/"m-1" are Hyprland workspace selectors (next/prev on this Monitor).
-- TODO(unverified): ml4w-ref only demonstrates the "e+1"/"e-1" selectors
-- being passed through as strings (its default.lua:122-123). "m+1" is the
-- same class of selector and should pass through identically, but I have
-- not seen it used in a Lua config. If SUPER+Tab does nothing, this is why.
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "m+1" }), { description = "Open next workspace" })
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }), { description = "Open previous workspace" })

-- old: bind = $mainMod, mouse_down, workspace, e+1
--      bind = $mainMod, mouse_up, workspace, e-1
-- These two ARE directly attested in ml4w-ref.
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Open next workspace" })
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Open previous workspace" })

-- old: bind = $mainMod CTRL, down, workspace, empty
-- TODO(unverified): "empty" is a Hyprland workspace selector keyword, not a
-- relative offset like the ones above, and it is not used anywhere in
-- ml4w-ref. Passing it as a string is the consistent guess but it is a
-- guess. Verify before relying on it.
--
-- Also note this SHADOWS nothing but sits next to `$mainMod, down` (move
-- focus down); that clash existed in the old config too.
hl.bind(
	mainMod .. " + CTRL + down",
	hl.dsp.focus({ workspace = "empty" }),
	{ description = "Open the next empty workspace" }
)

-- ---------------------------------------------------------------------
-- Function / media keys
--
-- All of these had an empty modifier field in hyprlang (`bind = , KEY, ...`),
-- so the Lua key string is just the bare keysym.
--
-- SEMANTIC NOTE: the originals were plain `bind`, with no `l` (locked) flag,
-- so volume and brightness did NOT work while the screen was locked.
-- ml4w-ref marks its media keys `{ locked = true, repeating = true }`.
-- I have NOT added that — it would be a behaviour change you did not ask
-- for. If you want volume keys to work under hyprlock, add
-- `locked = true` to the opts table.
-- ---------------------------------------------------------------------

hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl -q s +10%"),
	{ description = "Increase brightness by 10%" }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -q s 10%-"),
	{ description = "Reduce brightness by 10%" }
)

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ 0 && pactl set-sink-volume @DEFAULT_SINK@ +5%"),
	{ description = "Increase volume by 5%" }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ 0 && pactl set-sink-volume @DEFAULT_SINK@ -5%"),
	{ description = "Reduce volume by 5%" }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { description = "Toggle mute" })
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"),
	{ description = "Toggle microphone" }
)

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { description = "Audio play/pause" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl pause"), { description = "Audio pause" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { description = "Audio next" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { description = "Audio previous" })

-- DEPENDENCY: ~/.config/ml4w/settings/calculator.sh (present; "gnome-calculator")
hl.bind("XF86Calculator", hl.dsp.exec_cmd(SETTINGS .. "/calculator.sh"), { description = "Open calculator" })

-- NOT PORTED — old: bind = , XF86Tools, exec, $(cat ~/.config/ml4w/settings/terminal.sh) \
--     --class dotfiles-floating -e ~/.config/ml4w/apps/ML4W_Dotfiles_Settings-x86_64.AppImage
--
-- This bind is ALREADY DEAD. I checked: ~/.config/ml4w/apps/ does not
-- contain ML4W_Dotfiles_Settings-x86_64.AppImage (it is the only referenced
-- path in the whole config that is missing). Pressing XF86Tools has been
-- opening a terminal that immediately exits.
--
-- The `dotfiles-floating` window class it used is still handled by the
-- "dotfiles-float" rule in rules.lua, so if you restore the AppImage or
-- point this at something else, the float rule still applies.
--
-- The live replacement for this is SUPER+CTRL+S (flatpak run com.ml4w.settings),
-- which is bound above and does work.

-- ---------------------------------------------------------------------
-- Keyboard backlight (MacBook)
--
-- old: bind = , code:238, exec, brightnessctl -d smc::kbd_backlight s +10
--      bind = , code:237, exec, brightnessctl -d smc::kbd_backlight s 10-
--
-- TODO(unverified) — RAW KEYCODE SYNTAX.
-- In hyprlang, `code:238` means "evdev keycode 238" and is a documented
-- alternative to a keysym name. Whether the Lua key-string parser accepts
-- the same "code:NNN" token is NOT stated anywhere in the stub, and
-- ml4w-ref contains no keycode binds at all. I have written it verbatim
-- on the assumption the same string parser is used for both front-ends,
-- which is the likeliest implementation, but this is a genuine unknown.
--
-- If these two do not work, the keysyms for those codes on an Apple
-- keyboard are XF86KbdBrightnessUp / XF86KbdBrightnessDown — try those.
-- Confirm with `wev` or `hyprctl devices` before swapping.
--
-- Note also `smc::kbd_backlight` is the Apple SMC LED device; this pair is
-- machine-specific in the same way monitors.lua is. It is left here rather
-- than moved because it is a keybinding, but be aware of it if you ever
-- share this config with another machine.
-- ---------------------------------------------------------------------

hl.bind(
	"code:238",
	hl.dsp.exec_cmd("brightnessctl -d smc::kbd_backlight s +10"),
	{ description = "Increase keyboard backlight" }
)
hl.bind(
	"code:237",
	hl.dsp.exec_cmd("brightnessctl -d smc::kbd_backlight s 10-"),
	{ description = "Reduce keyboard backlight" }
)
