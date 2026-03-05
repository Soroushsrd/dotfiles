#!/bin/bash

if hyprctl monitors | grep -q "eDP-1.*disabled"; then
    # eDP-1 is disabled, enable it
    hyprctl keyword monitor "eDP-1, preferred, auto, 1"
    notify-send "Display" "Laptop screen enabled"
else
    # eDP-1 is enabled, disable it (but move workspaces first)
    # Move all workspaces to HDMI
    for i in {1..10}; do
        hyprctl dispatch moveworkspacetomonitor $i HDMI-A-1 2>/dev/null
    done
    # Focus HDMI
    hyprctl dispatch focusmonitor HDMI-A-1
    sleep 0.2
    # Now disable eDP-1
    hyprctl keyword monitor "eDP-1, disable"
    notify-send "Display" "Laptop screen disabled"
fi
