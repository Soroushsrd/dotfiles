#!/usr/bin/env bash
# Force "laptop screen only": disable every external output Hyprland still thinks
# is connected (e.g. a stale HDMI after the NVIDIA driver misses an unplug), make
# sure eDP-1 is on, and move all workspaces to it.
# Runtime-only: a config reload or relogin re-enables externals that are present.
set -uo pipefail
INTERNAL="eDP-1"

hyprctl eval "hl.monitor{output=\"$INTERNAL\", mode=\"1920x1080@144\", position=\"0x0\", scale=1, disabled=false}" >/dev/null
sleep 0.2

disabled=()
for out in $(hyprctl monitors -j | jq -r --arg i "$INTERNAL" '.[] | select(.name != $i and .name != "FALLBACK") | .name'); do
    hyprctl eval "hl.monitor{output=\"$out\", disabled=true}" >/dev/null
    disabled+=("$out")
done
sleep 0.2

for ws in $(hyprctl workspaces -j | jq -r '.[] | select(.id > 0) | .id'); do
    hyprctl dispatch "hl.dsp.workspace.move{workspace=$ws,monitor=\"$INTERNAL\"}" >/dev/null 2>&1
done
hyprctl dispatch "hl.dsp.focus{monitor=\"$INTERNAL\"}" >/dev/null 2>&1

if ((${#disabled[@]})); then
    notify-send "Display" "Laptop only — disabled ${disabled[*]}"
else
    notify-send "Display" "Laptop only — no external outputs were active"
fi
