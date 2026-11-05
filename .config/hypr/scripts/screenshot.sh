#!/usr/bin/env bash
set -euo pipefail
choice=$(printf 'Capture Selection\nCapture Everything\nCapture Active Display\n' | rofi -dmenu -i -p Screenshot -config "$HOME/.config/rofi/config-screenshot.rasi") || exit 0
mkdir -p "$HOME/Screenshots"
file="$HOME/Screenshots/$(date +%Y-%m-%d_%H-%M-%S-%N).png"
case "$choice" in
  'Capture Selection') geometry=$(slurp) || exit 0; grim -g "$geometry" "$file" ;;
  'Capture Everything') grim "$file" ;;
  'Capture Active Display') output=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'); grim -o "$output" "$file" ;;
  *) exit 0 ;;
esac
wl-copy --type image/png < "$file"
notify-send Screenshot "Saved and copied: $file"
