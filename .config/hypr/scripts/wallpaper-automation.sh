#!/bin/bash
#     _         _         __        ______
#    / \  _   _| |_ ___   \ \      / /  _ \
#   / _ \| | | | __/ _ \   \ \ /\ / /| |_) |
#  / ___ \ |_| | || (_) |   \ V  V / |  __/
# /_/   \_\__,_|\__\___/     \_/\_/  |_|
#
sec=$(cat ~/.config/ml4w/settings/wallpaper-automation.sh)
wallpaper_dir="$HOME/wallpaper"

_setWallpaperRandomly() {
    # Get random wallpaper from directory
    random_wallpaper=$(find "$wallpaper_dir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
    ~/.config/hypr/scripts/wallpaper.sh "$random_wallpaper"
    echo ":: Next wallpaper in $sec seconds..."
    sleep $sec
    _setWallpaperRandomly
}

if [ ! -f ~/.config/ml4w/cache/wallpaper-automation ]; then
    touch ~/.config/ml4w/cache/wallpaper-automation
    echo ":: Start wallpaper automation script"
    notify-send "Wallpaper automation process started" "Wallpaper will be changed every $sec seconds."
    _setWallpaperRandomly
else
    rm ~/.config/ml4w/cache/wallpaper-automation
    notify-send "Wallpaper automation process stopped."
    echo ":: Wallpaper automation script process $wp stopped"
    wp=$(pgrep -f wallpaper-automation.sh)
    kill -KILL $wp
fi
