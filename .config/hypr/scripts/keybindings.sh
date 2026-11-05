#!/usr/bin/env bash
set -euo pipefail
hyprctl binds -j | jq -r '.[] | select(.description != "") | "\(.modmask) + \(.key)  →  \(.description)"' | rofi -dmenu -i -p 'Keybindings (modifier bitmask)'
