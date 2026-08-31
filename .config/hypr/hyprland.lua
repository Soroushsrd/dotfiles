-- =====================================================================
-- Hyprland configuration — Lua entry point
-- Converted from hyprlang .conf (ML4W 2.9.8.3 derivative)
-- Target: Hyprland 0.56.2
--
-- See ../MIGRATION.md for the full old -> new mapping and open TODOs.
--
-- Load order matters. In the old config the same setting was written by
-- several files and the last `source` won (this is how conf/custom.conf
-- silently overrode conf/keyboard.conf). Here each setting is written
-- exactly once, in one module, so ordering is no longer load-bearing —
-- but keep monitors first and binds last for readability.
-- =====================================================================

require("env")        -- environment variables (must precede autostart)
require("monitors")   -- MACHINE-SPECIFIC: display layout
require("input")      -- keyboard, touchpad, pointer
require("appearance") -- general / decoration / animations / misc
require("rules")      -- window rules + layer rules
require("binds")      -- keybindings
require("autostart")  -- exec-once
