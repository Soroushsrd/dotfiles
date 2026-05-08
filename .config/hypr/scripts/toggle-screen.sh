#!/bin/bash
if hyprctl monitors all | grep -q "eDP-1"; then
    if hyprctl monitors | grep -q "eDP-1"; then
        # eDP-1 exists and is active — disable it
        for i in {1..10}; do
            hyprctl dispatch moveworkspacetomonitor $i HDMI-A-1 2>/dev/null
        done
        hyprctl dispatch focusmonitor HDMI-A-1
        sleep 0.2
        hyprctl keyword monitor "eDP-1, disable"
        notify-send "Display" "Laptop screen disabled"
    else
        # eDP-1 exists but is inactive — enable it
        hyprctl keyword monitor "eDP-1, preferred, auto, 1"
        sleep 0.2
        for i in {1..10}; do
            hyprctl dispatch moveworkspacetomonitor $i eDP-1 2>/dev/null
        done
        hyprctl dispatch focusmonitor eDP-1
        notify-send "Display" "Laptop screen enabled"
    fi
else
    notify-send "Display" "eDP-1 not found"
fi
