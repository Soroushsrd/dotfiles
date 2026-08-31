-- =====================================================================
-- Input — keyboard, touchpad, pointer
-- from: old/conf/keyboard.conf  +  old/conf/custom.conf (input block)
--       + 2 keys from com.ml4w.hyprlandsettings/hyprctl.json
--
-- MIGRATION.md §5.1: the old config declared `input {}` TWICE.
-- hyprland.conf sourced keyboard.conf (line 31) then custom.conf (line 76),
-- and the later one won. Verified against the running compositor:
--     hyprctl getoption input:kb_layout  -> "us,ir"
--     hyprctl getoption input:kb_options -> "grp:alt_shift_toggle"
-- so keyboard.conf's `caps:super` has NOT been active.
--
-- You did not answer which behaviour you actually want, so this file
-- reproduces what your machine is DOING TODAY, not what keyboard.conf
-- appears to say. That is the conservative choice for a migration:
-- nothing changes under you. See the TODO below to get caps:super back.
-- =====================================================================

hl.config({
    input = {
        -- ---- from custom.conf (the winner at runtime) ----
        kb_layout  = "us,ir",
        kb_variant = "",
        kb_model   = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules   = "",

        -- TODO(decision): keyboard.conf asked for `caps:super`, which has been
        -- dead since custom.conf started overriding it. XKB accepts both at
        -- once. If you want the Caps->Super remap back alongside the layout
        -- toggle, change kb_options to:
        --     kb_options = "caps:super,grp:alt_shift_toggle"
        -- If you no longer use the Persian layout, drop ",ir" from kb_layout
        -- and the grp: option becomes pointless too.

        -- ---- from keyboard.conf (survived; custom.conf didn't mention these) ----
        numlock_by_default = true,
        mouse_refocus      = false, -- also set by hyprctl.json to the same value
        follow_mouse       = 1,     -- also set by hyprctl.json to the same value
        sensitivity        = 0,     -- -1.0 .. 1.0, 0 = no modification

        touchpad = {
            -- keyboard.conf set natural_scroll twice: `false` (desktop) then
            -- `yes` (laptop). Last wins, so this was true. Preserved.
            natural_scroll = true,
            scroll_factor  = 1.0,
            -- folded in from hyprctl.json (MIGRATION.md §2)
            disable_while_typing = true,
        },
    },
})

-- NOTE: gestures were NOT enabled in the old config — `gestures { workspace_swipe }`
-- was commented out in both keyboard.conf and layouts/default.conf, so nothing
-- to port. Be aware that the plain `gestures:workspace_swipe` on/off flag no
-- longer exists in 0.56 (MIGRATION.md §4.1); the replacement is the hl.gesture{}
-- API. Example, if you ever want it:
--
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
