#!/usr/bin/env bash
set -euo pipefail
cache="$HOME/.config/ml4w/cache"
mkdir -p "$cache/wallpaper-generated" "$HOME/.cache/wal"
image=${1:-}
if [[ -z "$image" && -s "$cache/current_wallpaper" ]]; then IFS= read -r image < "$cache/current_wallpaper"; fi
[[ -f "$image" ]] || image="$HOME/wallpaper/default.jpg"
[[ -f "$image" ]] || { printf 'Wallpaper not found: %s\n' "$image" >&2; exit 1; }
printf '%s\n' "$image" > "$cache/current_wallpaper"
# Daemon starts independently; wait briefly for its socket.
if command -v awww >/dev/null; then
 for i in {1..30}; do awww query >/dev/null 2>&1 && break; sleep 0.1; done
 awww img "$image" --transition-type fade --transition-duration 2 || true
fi
wal -q -n -i "$image"
magick "$image" -resize 75% -blur 50x30 "$cache/blurred_wallpaper.png"
magick "$image" -gravity Center -extent 1:1 "$cache/square_wallpaper.png"
printf '* { current-image: url("%s", height); }\n' "$cache/blurred_wallpaper.png" > "$cache/current_wallpaper.rasi"
pkill -USR2 -x waybar || true
swaync-client -rs >/dev/null 2>&1 || true
