#!/usr/bin/env bash
# Called on monitor.removed. If no real external display is still active and the
# laptop panel is disabled (e.g. via toggle-screen.sh), re-enable the panel and
# bring every workspace back to it, so unplugging never leaves you on a black screen.
set -uo pipefail
INTERNAL="eDP-1"

sleep 0.3 # let Hyprland finish tearing down the removed output

externals=$(hyprctl monitors -j | jq -r --arg i "$INTERNAL" \
    '[.[] | select(.name != $i and .name != "FALLBACK")] | length')
internal_disabled=$(hyprctl monitors all -j | jq -r --arg i "$INTERNAL" \
    '.[] | select(.name == $i) | .disabled')

[[ "$externals" == "0" && "$internal_disabled" == "true" ]] || exit 0

# disabled=false is required; mode/position/scale alone leave the output off.
hyprctl eval "hl.monitor{output=\"$INTERNAL\", mode=\"1920x1080@144\", position=\"0x0\", scale=1, disabled=false}"
sleep 0.2
for ws in $(hyprctl workspaces -j | jq -r '.[] | select(.id > 0) | .id'); do
    hyprctl dispatch "hl.dsp.workspace.move{workspace=$ws,monitor=\"$INTERNAL\"}" >/dev/null 2>&1
done
hyprctl dispatch "hl.dsp.focus{monitor=\"$INTERNAL\"}" >/dev/null 2>&1
notify-send "Display" "External display disconnected — laptop screen re-enabled"
