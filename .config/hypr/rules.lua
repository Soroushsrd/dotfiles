-- =====================================================================
-- Window rules and layer rules
-- from: old/conf/ml4w.conf (19 windowrule + 2 layerrule)
--       old/conf/windowrule.conf -> old/conf/windowrules/default.conf (8 rules)
--
-- Syntax note: ml4w.conf was ALREADY using the newer hyprlang block form
-- (`windowrule { match:class = ... }`), so conversion here is mechanical:
--     match:class = X   ->   match = { class = "X" }
--     float = on        ->   float = true
--
-- ---------------------------------------------------------------------
-- IMPORTANT — limits of the stub (MIGRATION.md §4.3)
--
-- HL.WindowRuleSpec in /usr/share/hypr/stubs/hl.meta.lua (lines 597-601)
-- declares ONLY three fields: `enabled`, `match`, `name`. The actual rule
-- properties are not enumerated anywhere in the stub. So:
--
--   * float / size / center / pin  — not in the stub, but attested in
--     ml4w-ref/dotfiles/.config/hypr/conf/ml4w.lua, which is a working
--     upstream conversion. Used with reasonable confidence.
--
--   * move / tile                  — NOT in the stub AND NOT used anywhere
--     in ml4w-ref. I have no authoritative source for the argument shape.
--     Every use is marked TODO(unverified) below. I have written them in
--     the most plausible form (string, same text as the old config) rather
--     than guessing at a table shape, but DO verify these before relying
--     on them.
--
-- By contrast HL.LayerRuleSpec (stub lines 555-569) IS fully typed, so the
-- two layer rules at the bottom are solid.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Audio / system utilities
-- ---------------------------------------------------------------------

-- old: ml4w.conf "pavucontrol-float"
hl.window_rule({
    name  = "pavucontrol-float",
    match = { class = ".*org.pulseaudio.pavucontrol.*" },
    float = true, size = "700 600", center = true, pin = true,
})

-- old: ml4w.conf "mission-center-float"
hl.window_rule({
    name  = "mission-center-float",
    match = { class = "io.missioncenter.MissionCenter" },
    float = true, size = "900 600", center = true, pin = true,
})

-- old: ml4w.conf "mission-center-prefs" (two-key match: class AND title)
hl.window_rule({
    name  = "mission-center-prefs",
    match = { class = "missioncenter", title = "^(Preferences)$" },
    float = true, center = true, pin = true,
})

-- old: ml4w.conf "gnome-calc-float"
hl.window_rule({
    name  = "gnome-calc-float",
    match = { class = "org.gnome.Calculator" },
    float = true, size = "700 600", center = true,
})

-- old: ml4w.conf "share-picker-float"
hl.window_rule({
    name  = "share-picker-float",
    match = { class = "hyprland-share-picker" },
    float = true, size = "600 400", center = true, pin = true,
})

-- ---------------------------------------------------------------------
-- Appearance / theming tools
-- ---------------------------------------------------------------------

-- old: ml4w.conf "waypaper-float"
hl.window_rule({
    name  = "waypaper-float",
    match = { class = ".*waypaper.*" },
    float = true, size = "900 700", center = true, pin = true,
})

-- old: ml4w.conf "nwg-look-float"
hl.window_rule({
    name  = "nwg-look-float",
    match = { class = "nwg-look" },
    float = true, size = "700 600", pin = true,
    -- TODO(unverified): `move` is not in the stub and not used in ml4w-ref.
    -- Old value: `move = 10% 20%`. Percentage-relative placement.
    move = "10% 20%",
})

-- old: ml4w.conf "nwg-displays-float"
hl.window_rule({
    name  = "nwg-displays-float",
    match = { class = "nwg-displays" },
    float = true, size = "900 600", pin = true,
    -- TODO(unverified): see above. Old value: `move = 10% 20%`.
    move = "10% 20%",
})

-- ---------------------------------------------------------------------
-- ML4W applications
--
-- TODO(dependency): all four of these match ML4W app window classes. Three
-- of them (calendar, sidebar, welcome) are GTK/flatpak apps from ML4W 2.9.x.
-- In 2.16 the sidebar and calendar were reimplemented in Quickshell and are
-- driven by `qs ipc call sidebar toggle` / `qs ipc call calendar toggle`,
-- with different window classes. If you ever take the ML4W upgrade, these
-- four rules stop matching. See MIGRATION.md §1.
-- ---------------------------------------------------------------------

-- old: ml4w.conf "ml4w-calendar"  (note: no float=on in the original —
-- only move+pin, so it stays tiled unless something else floats it)
hl.window_rule({
    name  = "ml4w-calendar",
    match = { class = "com.ml4w.calendar" },
    pin   = true,
    -- TODO(unverified): `move` shape. Old value: `move = 100%-w-16 66`
    -- ("16px in from the right edge, 66px down"). This arithmetic form is
    -- the one I am least confident survives verbatim.
    move  = "100%-w-16 66",
})

-- old: ml4w.conf "ml4w-sidebar"  (also no float=on in the original)
hl.window_rule({
    name  = "ml4w-sidebar",
    match = { class = "com.ml4w.sidebar" },
    pin   = true,
    -- TODO(unverified): as above.
    move  = "100%-w-16 66",
})

-- old: ml4w.conf "ml4w-welcome"
hl.window_rule({
    name  = "ml4w-welcome",
    match = { class = "com.ml4w.welcome" },
    float = true, size = "700 600", center = true, pin = true,
})

-- old: ml4w.conf "ml4w-settings"
hl.window_rule({
    name  = "ml4w-settings",
    match = { class = "com.ml4w.settings" },
    float = true, size = "700 600",
    -- TODO(unverified): `move` shape. Old value: `move = 10% 20%`.
    move  = "10% 20%",
})

-- ---------------------------------------------------------------------
-- Browser / web app windows
-- ---------------------------------------------------------------------

-- old: ml4w.conf "chatgpt-title-float"
hl.window_rule({
    name  = "chatgpt-title-float",
    match = { title = "ChatGPT.*" },
    float = true,
})

-- old: ml4w.conf "chatgpt-openai-float"
hl.window_rule({
    name  = "chatgpt-openai-float",
    match = { title = ".*chat.openai.com.*" },
    float = true, size = "500 50%",
    -- TODO(unverified): `move` shape. Old value: `move = 20 70` (absolute px).
    move  = "20 70",
})

-- old: windowrules/default.conf "pip-settings"
-- This one is CORRECT as a title match — "Picture-in-Picture" really is the
-- window title Firefox/Chromium give the PiP window.
hl.window_rule({
    name  = "pip-float",
    match = { title = "^(Picture-in-Picture)$" },
    float = true, pin = true,
    -- TODO(unverified): `move` shape. Old value: `move = 69.5% 4%`.
    move  = "69.5% 4%",
})

-- ---------------------------------------------------------------------
-- Browser tiling rules
--
-- BUGFIX #3 (MIGRATION.md §7.3) — these three matched on `title` in
-- windowrules/default.conf:
--     match:title = ^(Microsoft-edge)$
--     match:title = ^(Brave-browser)$
--     match:title = ^(Chromium)$
-- "Microsoft-edge", "Brave-browser" and "Chromium" are window CLASS names.
-- A browser window title is the page title ("Inbox — Gmail"), never the
-- literal string "Brave-browser". These three rules have never fired once.
-- Changed to match on `class`, which is what was obviously intended.
--
-- This is a real behaviour change: these browsers will now actually be
-- forced to tile. Since `dwindle` tiles by default anyway, the practical
-- effect should be nil unless something else was floating them.
-- ---------------------------------------------------------------------

-- old: windowrules/default.conf "edge-tile"  (was match:title)
hl.window_rule({
    name  = "edge-tile",
    match = { class = "^(Microsoft-edge)$" },
    -- TODO(unverified): `tile` is not in the stub and not used in ml4w-ref.
    tile  = true,
})

-- old: windowrules/default.conf "brave-tile"  (was match:title)
hl.window_rule({
    name  = "brave-tile",
    match = { class = "^(Brave-browser)$" },
    -- TODO(unverified): as above.
    tile  = true,
})

-- old: windowrules/default.conf "chromium-tile"  (was match:title)
hl.window_rule({
    name  = "chromium-tile",
    match = { class = "^(Chromium)$" },
    -- TODO(unverified): as above.
    tile  = true,
})

-- ---------------------------------------------------------------------
-- Legacy float rules from windowrules/default.conf
--
-- TODO(decision): these four have the SAME title-vs-class problem as the
-- three tiling rules above, but you asked me to fix "the three title-vs-class
-- window rules", so I have left these exactly as they were. They may fire
-- occasionally by coincidence — some GTK apps do set a title matching their
-- binary name — which is presumably why nobody noticed.
--
-- Also note `pavucontrol-legacy-float` is redundant: the correct class-based
-- pavucontrol rule at the top of this file already covers it.
-- ---------------------------------------------------------------------

hl.window_rule({
    name  = "pavucontrol-legacy-float",
    match = { title = "^(pavucontrol)$" },
    float = true,
})

hl.window_rule({
    name  = "blueman-float",
    match = { title = "^(blueman-manager)$" },
    float = true,
})

hl.window_rule({
    name  = "nm-connection-float",
    match = { title = "^(nm-connection-editor)$" },
    float = true,
})

hl.window_rule({
    name  = "qalculate-float",
    match = { title = "^(qalculate-gtk)$" },
    float = true,
})

-- ---------------------------------------------------------------------
-- Misc
-- ---------------------------------------------------------------------

-- old: ml4w.conf "dotfiles-float"
-- Matches the `--class dotfiles-floating` used by the (now dead) XF86Tools
-- bind. Kept because you may still launch things with that class by hand.
hl.window_rule({
    name  = "dotfiles-float",
    match = { class = "dotfiles-floating" },
    float = true, size = "700 1000", center = true,
})

-- NOT PORTED — old: ml4w.conf "kitty-float" (lines 161-169).
-- Every property in that rule was commented out; only the name and the
-- class match remained, making it a no-op. Dropped rather than carried
-- forward as an empty rule. To restore, uncomment in old/conf/ml4w.conf.

-- NOT PORTED — old: windowrules/default.conf "fullscreen-idleinhibit"
-- (lines 66-72). Entirely commented out in the original.
-- Note `idleinhibit` is also not in the stub, so it would need verifying.

-- ---------------------------------------------------------------------
-- Layer rules — from ml4w.conf
-- HL.LayerRuleSpec IS fully typed in the stub, so these are solid.
-- ---------------------------------------------------------------------

hl.layer_rule({
    name         = "swaync-control-blur",
    match        = { namespace = "swaync-control-center" },
    blur         = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name         = "swaync-notification-blur",
    match        = { namespace = "swaync-notification-window" },
    blur         = true,
    ignore_alpha = 0.5,
})
