#!/bin/bash
#     _    _ _  __ _             _
#    / \  | | |/ _| | ___   __ _| |_
#   / _ \ | | | |_| |/ _ \ / _` | __|
#  / ___ \| | |  _| | (_) | (_| | |_
# /_/   \_\_|_|_| |_|\___/ \__,_|\__|
#

# There is no `workspaceopt` dispatcher in the Lua API, so do it by hand:
# if every window on the active workspace is already floating, tile them all,
# otherwise float them all. hl.dsp.window.float takes action=enable/disable/
# toggle; enable/disable are idempotent, so no need to filter by current state.
ws=$(hyprctl activeworkspace -j | jq -r '.id')

mapfile -t addrs < <(hyprctl clients -j | jq -r --argjson ws "$ws" \
    '.[] | select(.workspace.id == $ws) | .address')

if [ ${#addrs[@]} -eq 0 ]; then
    notify-send "Windows" "No windows on this workspace"
    exit 0
fi

all_floating=$(hyprctl clients -j | jq -r --argjson ws "$ws" \
    '[.[] | select(.workspace.id == $ws) | .floating] | all')

if [ "$all_floating" = "true" ]; then
    action=disable
else
    action=enable
fi

for address in "${addrs[@]}"; do
    hyprctl dispatch "hl.dsp.window.float{window=\"address:$address\",action=\"$action\"}" >/dev/null
done

notify-send "Windows on this workspace toggled to floating/tiling"
