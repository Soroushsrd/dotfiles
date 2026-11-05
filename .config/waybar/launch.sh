#!/usr/bin/env bash
set -euo pipefail
pkill -x waybar || true
[[ ! -f "$HOME/.config/ml4w/settings/waybar-disabled" ]] || exit 0
exec waybar -c "$HOME/.config/waybar/themes/mochaPower/config" -s "$HOME/.config/waybar/themes/mochaPower/style.css"
