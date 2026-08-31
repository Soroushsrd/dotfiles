-- =====================================================================
-- MACHINE-SPECIFIC — display layout
-- from: old/conf/monitor.conf -> old/conf/monitors/default.conf
--
-- This is the only file that should differ between machines.
-- The old config had 11 other monitor variations under conf/monitors/;
-- they were never sourced. See MIGRATION.md §3.2 — note that the
-- 1920x1080 and 1920x1200 variants had local edits you may want back.
-- =====================================================================

-- old: monitor = eDP-1, 1920x1080@60, 0x0, 1
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})

-- old: monitor = HDMI-A-1,1920x1080@120,-1920x0,1
-- Positioned to the LEFT of the internal panel (negative x).
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@120",
    position = "-1920x0",
    scale    = 1,
})

-- NOTE: the old config had no catch-all `monitor=,preferred,auto,1` line
-- (it was commented out in conf/monitors/default.conf). Any third display
-- will therefore get Hyprland's built-in default rather than an explicit
-- rule. Uncomment below if you want the ML4W-style fallback:
--
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
