-- =====================================================================
-- Appearance — general / decoration / animations / layout / misc
-- from: old/conf/windows/no-border.conf
--       old/conf/decorations/rounding.conf
--       old/conf/animations/animations-fast.conf
--       old/conf/layouts/default.conf
--       old/conf/misc.conf
--       old/hyprland.conf (xwayland block)
--       + com.ml4w.hyprlandsettings/hyprctl.json  (MIGRATION.md §2)
-- =====================================================================

-- ---------------------------------------------------------------------
-- Colours
--
-- MIGRATION.md §5.2: the old config did
--     source = ~/.cache/wal/colors-hyprland.conf
-- and used `$color11` for the active border. That file is hyprlang and a
-- Lua config cannot source it, so the pywal pipeline is BROKEN by this
-- migration and cannot be carried over as-is.
--
-- It was, however, already having no effect: hyprctl.json overrode
-- col.active_border at runtime 3 seconds after every start. The literals
-- below are the hyprctl.json values — i.e. the colours actually on your
-- screen today — not the pywal ones.
--
-- Conversion note: hyprlang took 0xAARRGGBB; the Lua API takes rgba()
-- strings which are RRGGBBAA. The alpha moves from the front to the back.
--     0xffc64600  ->  rgba(c64600ff)
--     0xff613583  ->  rgba(613583ff)
--     0x66000000  ->  rgba(00000066)
--
-- TODO(decision): if you still want pywal driving your borders, the wal
-- template that generates colors-hyprland.conf must be replaced with one
-- that emits Lua (see ml4w-ref/dotfiles/.config/hypr/colors.lua for the
-- shape: bare globals assigned rgba() strings, then `require("colors")`).
-- That template lives outside this repo and I have not located it.
-- ---------------------------------------------------------------------
local col_active   = "rgba(c64600ff)"
local col_inactive = "rgba(613583ff)"

hl.config({
    general = {
        gaps_in  = 10,
        gaps_out = 14,
        -- no-border.conf said 0, hyprctl.json forced 1. 1 is what you have.
        border_size = 1,
        col = {
            active_border   = col_active,
            inactive_border = col_inactive,
        },
        layout = "dwindle",
        -- NOTE: resize_on_border with border_size = 0 would give a zero-width
        -- grab area (MIGRATION.md §5.6). Harmless at border_size = 1.
        resize_on_border = true,
    },

    decoration = {
        rounding           = 10,
        active_opacity     = 1.0,
        -- rounding.conf said 0.8, hyprctl.json forced 0.9. 0.9 is what you have.
        inactive_opacity   = 0.9,
        fullscreen_opacity = 1.0,

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 2,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = true,
        },

        shadow = {
            enabled      = true,
            range        = 30,
            render_power = 3,
            color        = "rgba(00000066)",
        },
    },

    dwindle = {
        preserve_split = true,
    },

    -- master{} in layouts/default.conf had its only key (new_status) commented
    -- out, so the block was empty and is not reproduced here.

    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles   = true,
        pass_mouse_when_bound    = false,
    },

    misc = {
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        initial_workspace_tracking = 1,
        -- folded in from hyprctl.json
        focus_on_activate          = false,
    },

    cursor = {
        -- folded in from hyprctl.json
        hide_on_key_press = true,
    },

    debug = {
        -- MIGRATION.md §4.1: hyprctl.json set `misc:vfr = true`. In 0.56 the
        -- key is `debug:vfr` — `misc.vfr` does not exist. Same value, new home.
        -- TODO(verify): it now lives under `debug`, which in Hyprland is
        -- generally not meant for everyday tuning. VFR defaults to on, so
        -- consider simply deleting this line rather than carrying it forward.
        vfr = true,
    },

    xwayland = {
        -- from old/hyprland.conf lines 78-80
        force_zero_scaling = true,
    },
})

-- DROPPED from hyprctl.json — these keys no longer exist in 0.56 and are
-- NOT silently translated (MIGRATION.md §4.1):
--
--   general:no_border_on_floating = true
--       Removed with no replacement in the stub. Floating windows will now
--       draw the same 1px border as tiled ones. This is a VISIBLE change and
--       the only one I could not avoid.
--
--   animations:first_launch_animation = true
--       Removed with no replacement in the stub. Cosmetic, start-up only.

-- ---------------------------------------------------------------------
-- Animations — from conf/animations/animations-fast.conf
--
-- Syntax change (MIGRATION.md §4.2.7/§4.2.8):
--   bezier = NAME, x1,y1,x2,y2          -> hl.curve(NAME, {points={{x1,y1},{x2,y2}}})
--   animation = LEAF, on, speed, curve, style
--                                       -> hl.animation({leaf=, enabled=, speed=, bezier=, style=})
-- The four bezier scalars become two coordinate pairs.
-- ---------------------------------------------------------------------
hl.config({ animations = { enabled = true } })

hl.curve("linear",        { type = "bezier", points = { {0, 0},      {1, 1} } })
hl.curve("md3_standard",  { type = "bezier", points = { {0.2, 0},    {0, 1} } })
hl.curve("md3_decel",     { type = "bezier", points = { {0.05, 0.7}, {0.1, 1} } })
hl.curve("md3_accel",     { type = "bezier", points = { {0.3, 0},    {0.8, 0.15} } })
hl.curve("overshot",      { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.1} } })
hl.curve("crazyshot",     { type = "bezier", points = { {0.1, 1.5},  {0.76, 0.92} } })
hl.curve("hyprnostretch", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })
hl.curve("fluent_decel",  { type = "bezier", points = { {0.1, 1},    {0, 1} } })
hl.curve("easeInOutCirc", { type = "bezier", points = { {0.85, 0},   {0.15, 1} } })
hl.curve("easeOutCirc",   { type = "bezier", points = { {0, 0.55},   {0.45, 1} } })
hl.curve("easeOutExpo",   { type = "bezier", points = { {0.16, 1},   {0.3, 1} } })

-- NOTE: md3_standard, md3_accel, overshot, crazyshot, hyprnostretch,
-- fluent_decel, easeInOutCirc, easeOutCirc and linear are all defined but
-- unused by the rules below — that is inherited from stock ML4W, kept so
-- switching animation styles by hand still works.

hl.animation({ leaf = "windows",          enabled = true, speed = 3,   bezier = "md3_decel",   style = "popin 60%" })
hl.animation({ leaf = "border",           enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "fade",             enabled = true, speed = 2.5, bezier = "md3_decel" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 3.5, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3,   bezier = "md3_decel",   style = "slidevert" })
