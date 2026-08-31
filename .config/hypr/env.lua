-- =====================================================================
-- Environment variables
-- from: old/conf/ml4w.conf (env block, lines 181-207)
--       old/conf/custom.conf (SDL_VIDEODRIVER, line 15)
--
-- Split into its own module because the env block is substantial (17 vars)
-- and unrelated to appearance or autostart. Say the word if you'd rather
-- it lived in autostart.lua.
--
-- These must be set before anything is exec'd, hence require("env") first
-- in hyprland.lua.
--
-- old/conf/environments/default.conf contained only a comment pointing here,
-- so there is nothing else to merge.
-- =====================================================================

-- XDG / session identification
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Qt
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- BUGFIX #2 (MIGRATION.md §7.2) — was set twice in ml4w.conf:
--     env = QT_QPA_PLATFORMTHEME,qt6ct     (line 187)
--     env = QT_QPA_PLATFORMTHEME,qt5ct     (line 188)   <- won
-- Same variable, so qt5ct silently clobbered qt6ct and the qt6ct setting
-- never applied. Collapsed to a single assignment. Keeping qt6ct: you are
-- on Hyprland 0.56 where the Qt6 stack is the relevant one, and upstream
-- ML4W ships a qt6ct config directory.
-- To revert to the old EFFECTIVE behaviour, change this to "qt5ct".
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR",         "1")

-- GTK / GDK
hl.env("GDK_SCALE",   "1")
hl.env("GDK_BACKEND", "wayland,x11,*")

-- Clutter
hl.env("CLUTTER_BACKEND", "wayland")

-- Mozilla
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- SDL — from custom.conf
hl.env("SDL_VIDEODRIVER", "wayland")

-- Cursor size for xcursor
-- NOTE: kept at 24 to match `hyprctl setcursor Bibata-Modern-Ice 24` in
-- autostart.lua. If you change one, change the other.
hl.env("XCURSOR_SIZE", "24")

-- Electron / Chromium (Ozone)
hl.env("OZONE_PLATFORM", "wayland")

-- BUGFIX #1 (MIGRATION.md §7.1) — was `waylandd` (two d's) in ml4w.conf:207.
-- Not a valid value, so every Electron app has been ignoring this hint and
-- falling back to its default backend. Corrected to "wayland".
-- This is a REAL behaviour change: Electron apps that were running on X11
-- via XWayland will now start as native Wayland clients. If an Electron app
-- misbehaves after this migration, this line is the first thing to revert.
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
