#!/bin/bash
if hyprctl monitors all | grep -q "eDP-1"; then
    if hyprctl monitors | grep -q "eDP-1"; then
        # eDP-1 exists and is active — disable it
        for i in {1..10}; do
            hyprctl dispatch "hl.dsp.workspace.move{workspace=$i,monitor=\"HDMI-A-1\"}" >/dev/null 2>&1
        done
        hyprctl dispatch 'hl.dsp.focus{monitor="HDMI-A-1"}'
        sleep 0.2
        # No dispatcher can enable/disable a real output, and `hyprctl output`
        # only manages virtual outputs, so this has to go through eval.
        hyprctl eval 'hl.monitor{output="eDP-1", disabled=true}'
        notify-send "Display" "Laptop screen disabled"
    else
        # eDP-1 exists but is inactive — enable it.
        # disabled=false is required: passing mode/position/scale alone
        # leaves the output disabled.
        hyprctl eval 'hl.monitor{output="eDP-1", mode="preferred", position="auto", scale=1, disabled=false}'
        sleep 0.2
        for i in {1..10}; do
            hyprctl dispatch "hl.dsp.workspace.move{workspace=$i,monitor=\"eDP-1\"}" >/dev/null 2>&1
        done
        hyprctl dispatch 'hl.dsp.focus{monitor="eDP-1"}'
        notify-send "Display" "Laptop screen enabled"
    fi
else
    notify-send "Display" "eDP-1 not found"
fi
