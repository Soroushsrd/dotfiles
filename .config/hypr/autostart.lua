-- =====================================================================
-- Autostart
-- from: old/conf/autostart.conf   (12 exec-once + 1 exec)
--       old/conf/cursor.conf      (1 exec-once — the whole file)
--       old/hyprland.conf:62      (dbus-update-activation-environment)
--
-- ---------------------------------------------------------------------
-- Conversion
--
--   exec-once = CMD   ->   hl.exec_cmd("CMD") inside hl.on("hyprland.start")
--
-- `hyprland.start` fires once per compositor start, which is exactly
-- exec-once's semantics. This is the idiom ml4w-ref uses
-- (ml4w-ref/dotfiles/.config/hypr/conf/autostart.lua).
--
-- Order within the callback is preserved from autostart.conf. hl.exec_cmd
-- does not block, so this is launch order, not completion order — same as
-- before.
--
-- ---------------------------------------------------------------------
-- `exec` vs `exec-once` — the one line that is NOT exec-once
--
-- autostart.conf had ONE `exec =` (no -once), which in hyprlang re-runs on
-- every config reload:
--     exec = ~/.config/com.ml4w.hyprlandsettings/hyprctl.sh
-- That is the hidden override layer described in MIGRATION.md §2. It is
-- deliberately NOT reproduced here — see the long note at the bottom.
--
-- For reference, if you ever need the every-reload behaviour, the stub
-- lists a `config.reloaded` event (hl.meta.lua:7) alongside
-- `hyprland.start`, so the mapping would be
-- hl.on("config.reloaded", ...). TODO(unverified): I have not confirmed
-- whether `config.reloaded` also fires on the initial load, which is what
-- would make it a true `exec` equivalent.
-- =====================================================================

hl.on("hyprland.start", function()
	-- -----------------------------------------------------------------
	-- from old/hyprland.conf:62 — was at the top level, not in
	-- autostart.conf. Kept first because everything downstream that talks
	-- to systemd user services wants these in the activation environment.
	-- -----------------------------------------------------------------
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

	-- -----------------------------------------------------------------
	-- XDG portals + waybar
	--
	-- old: exec-once = ~/.config/hypr/scripts/xdg.sh
	--
	-- NOTE — this one script does three jobs: it killalls every portal
	-- implementation, restarts pipewire/wireplumber/portals, and then at
	-- the very end (after `sleep 2`) runs ~/.config/waybar/launch.sh.
	-- So your status bar start is buried inside the portal script. That is
	-- stock ML4W 2.9.x behaviour, not something you did.
	--
	-- ML4W 2.16 unpicked this: it inlines the two systemctl calls in
	-- autostart.lua and starts waybar as its own line. I have NOT
	-- restructured it — xdg.sh is unchanged and still does both, and
	-- splitting it would be a behaviour change beyond the migration.
	-- Just be aware that if waybar fails to start, look in xdg.sh.
	-- -----------------------------------------------------------------
	hl.exec_cmd("~/.config/hypr/scripts/xdg.sh")

	-- -----------------------------------------------------------------
	-- Polkit authentication agent
	-- old: exec-once=/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
	-- Verified present.
	-- -----------------------------------------------------------------
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

	-- -----------------------------------------------------------------
	-- Wallpaper
	--
	-- old: exec-once = swww-daemon
	--      exec-once = ~/.config/hypr/scripts/wallpaper-restore.sh
	--
	-- TODO(dependency): you are on `swww`. ML4W 2.16 moved to `awww-daemon`
	-- (see ml4w-ref autostart.lua) and to `ml4w-wallpaper-app --restore`.
	-- Your swww + wallpaper-restore.sh pair is installed and working, so it
	-- is carried over as-is. Do not mix the two.
	--
	-- wallpaper-restore.sh reads ~/.config/ml4w/cache/current_wallpaper and
	-- falls back to ~/wallpaper/default.jpg, then calls
	-- ~/.config/hypr/scripts/wallpaper.sh.
	-- -----------------------------------------------------------------
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("~/.config/hypr/scripts/wallpaper-restore.sh")

	-- -----------------------------------------------------------------
	-- Notification daemon
	-- old: exec-once = swaync
	-- The two layer rules in rules.lua (swaync-control-center /
	-- swaync-notification-window) depend on this being swaync specifically.
	-- -----------------------------------------------------------------
	hl.exec_cmd("swaync")

	-- -----------------------------------------------------------------
	-- GTK settings (theme, icons, font, dark-mode preference)
	-- old: exec-once = ~/.config/hypr/scripts/gtk.sh
	-- -----------------------------------------------------------------
	hl.exec_cmd("~/.config/hypr/scripts/gtk.sh")

	-- -----------------------------------------------------------------
	-- Cursor theme
	-- old: old/conf/cursor.conf — that file's ENTIRE contents was this one
	-- exec-once line, so the file has no separate module here.
	--
	-- NOTE: the size 24 must stay in step with XCURSOR_SIZE in env.lua.
	-- -----------------------------------------------------------------
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")

	-- -----------------------------------------------------------------
	-- Idle daemon (starts hyprlock)
	-- old: exec-once = hypridle
	-- Per your instruction, hypridle.conf / hyprlock.conf are left as .conf
	-- and untouched. hypridle reads its own config, independent of this
	-- migration, so nothing to do.
	-- -----------------------------------------------------------------
	hl.exec_cmd("hypridle")

	-- -----------------------------------------------------------------
	-- Clipboard history
	-- old: exec-once = wl-paste --watch cliphist store
	-- Feeds the SUPER+V bind (cliphist.sh) in binds.lua.
	-- -----------------------------------------------------------------
	hl.exec_cmd("wl-paste --watch cliphist store")

	-- -----------------------------------------------------------------
	-- ML4W autostart
	-- old: exec-once = ~/.config/ml4w/scripts/ml4w-autostart.sh
	--
	-- DEPENDENCY: ~/.config/ml4w/scripts/ml4w-autostart.sh (present,
	-- 2.9.8.3 name). It does two things:
	--   1. runs ~/.config/ml4w/version/compare.sh (version nag)
	--   2. `flatpak run com.ml4w.welcome` unless
	--      ~/.cache/ml4w-welcome-autostart exists
	--
	-- TODO(dependency): renamed to `ml4w-autostart` (no .sh) in 2.16, and
	-- 2.16 additionally redirects its output to a log. Your 2.9.8.3 copy
	-- exists and works. See MIGRATION.md §1.
	--
	-- TODO(decision): step 1 compares your installed ML4W version against
	-- upstream. Since this migration hand-converts the config, that nag is
	-- now actively unhelpful — accepting an ML4W update would overwrite
	-- ~/.config/hypr with 2.16's Lua files and discard this work. Consider
	-- `touch ~/.cache/ml4w-welcome-autostart` to silence the welcome app,
	-- or dropping this line entirely.
	-- -----------------------------------------------------------------
	hl.exec_cmd("~/.config/ml4w/scripts/ml4w-autostart.sh")

	-- -----------------------------------------------------------------
	-- Cleanup
	-- old: exec-once = ~/.config/hypr/scripts/cleanup.sh
	--
	-- NOTE: cleanup.sh removes ~/.cache/gamemode. But gamemode.sh (bound to
	-- SUPER+ALT+G) writes its flag to ~/.config/ml4w/settings/gamemode-enabled,
	-- NOT ~/.cache/gamemode. The two have drifted apart, so this cleanup is
	-- a no-op and a gamemode session that ends uncleanly will still think
	-- it is enabled at next login. Pre-existing; not touched, since you did
	-- not list it among the bugs to fix.
	-- -----------------------------------------------------------------
	hl.exec_cmd("~/.config/hypr/scripts/cleanup.sh")

	-- -----------------------------------------------------------------
	-- Dock
	-- old: exec-once = ~/.config/nwg-dock-hyprland/launch.sh
	--
	-- NOTE: this is currently a NO-OP on your machine. launch.sh checks for
	-- ~/.config/ml4w/settings/dock-disabled and that flag file exists (I
	-- verified it, 0 bytes). It prints ":: Dock disabled" and exits.
	-- Carried over anyway so that deleting the flag restores the dock.
	-- -----------------------------------------------------------------
	hl.exec_cmd("~/.config/nwg-dock-hyprland/launch.sh")
end)

-- =====================================================================
-- NOT PORTED — the ML4W Hyprland Settings runtime override layer
--
-- old: exec = ~/.config/com.ml4w.hyprlandsettings/hyprctl.sh
--
-- This is MIGRATION.md §2, and it is the single most consequential
-- omission in this whole conversion, so read this before deciding.
--
-- What it did: sleep 3, then walk hyprctl.json and replay all 13 entries
-- through `hyprctl keyword`. Three seconds after every login your config
-- was silently overwritten in 13 places. That is why `hyprctl getoption
-- general:border_size` returned 1 while no-border.conf said 0.
--
-- I have folded all 13 values into the static Lua config instead:
--   -> appearance.lua : col.active_border, col.inactive_border,
--                       border_size, animations.enabled,
--                       decoration.inactive_opacity, cursor.hide_on_key_press,
--                       misc.focus_on_activate, debug.vfr
--   -> input.lua      : touchpad.disable_while_typing, follow_mouse,
--                       mouse_refocus
--   -> DROPPED        : general.no_border_on_floating,
--                       animations.first_launch_animation
--                       (both removed in Hyprland 0.56 — see appearance.lua)
--
-- Consequences of not running hyprctl.sh:
--   + No 3-second window at login where your borders/opacity are wrong.
--   + The config file is now the truth. `hyprctl reload` gives you what
--     the file says.
--   - The ML4W Hyprland Settings GUI (SUPER+CTRL+S -> the settings app)
--     writes to hyprctl.json. Its changes will no longer take effect.
--     If you use that GUI, you must now edit appearance.lua by hand.
--
-- TODO(decision): if you would rather keep the GUI working, re-add
--     hl.exec_cmd("~/.config/com.ml4w.hyprlandsettings/hyprctl.sh")
-- inside the callback above — but first strip no_border_on_floating and
-- first_launch_animation from hyprctl.json, or you will get two
-- "unknown keyword" errors from hyprctl at every login.
-- =====================================================================

-- ---------------------------------------------------------------------
-- NOT PORTED — old/hyprland.conf:67
--     # exec-once = wal -f ~/.config/wal-themes/mytheme.json -n
-- Commented out in the original. Related to the broken pywal pipeline
-- described in appearance.lua / MIGRATION.md §5.2.
-- ---------------------------------------------------------------------
