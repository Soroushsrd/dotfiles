#!/usr/bin/env bash
set -euo pipefail
image="$HOME/wallpaper/default.jpg"
cache="$HOME/.config/ml4w/cache/current_wallpaper"
if [[ -s "$cache" ]]; then IFS= read -r image < "$cache"; fi
[[ -f "$image" ]] || exit 0
for i in {1..30}; do
 if awww query >/dev/null 2>&1; then
  awww img "$image" --transition-type fade --transition-duration 1
  exit 0
 fi
 sleep 0.1
done
