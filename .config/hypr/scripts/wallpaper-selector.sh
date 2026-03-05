#!/bin/bash
wallpaper_dir="$HOME/Downloads/images"

# Get list of wallpapers
wallpapers=$(find "$wallpaper_dir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) -printf "%f\n" | sort)

# Show in rofi
selected=$(echo "$wallpapers" | rofi -dmenu -i -p "Select Wallpaper" -config ~/.config/rofi/config-wallpaper.rasi)

if [ ! -z "$selected" ]; then
    full_path=$(find "$wallpaper_dir" -name "$selected")
    ~/.config/hypr/scripts/wallpaper.sh "$full_path"
fi
