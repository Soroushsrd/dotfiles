#!/usr/bin/env bash
#    ____         __       ____               __     __
#   /  _/__  ___ / /____ _/ / / __ _____  ___/ /__ _/ /____ ___
#  _/ // _ \(_-</ __/ _ `/ / / / // / _ \/ _  / _ `/ __/ -_|_-<
# /___/_//_/___/\__/\_,_/_/_/  \_,_/ .__/\_,_/\_,_/\__/\__/___/
#                                 /_/
#
# Opened by clicking the Waybar updates module.
# Restored from the ml4w dotfiles version; uses plain prompts instead of
# gum/figlet (not installed here).

clear
echo ":: System updates"
echo

read -rp ":: Start the update now? [Y/n] " answer
if [[ $answer =~ ^[Nn] ]]; then
    echo ":: Update canceled."
    sleep 1
    exit 0
fi

if command -v timeshift >/dev/null; then
    read -rp ":: Create a timeshift snapshot first? [y/N] " snap
    if [[ $snap =~ ^[Yy] ]]; then
        read -rp ":: Snapshot comment: " comment
        sudo timeshift --create --comments "$comment"
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
fi

aur_helper="$(cat ~/.config/ml4w/settings/aur.sh 2>/dev/null)"
if command -v "$aur_helper" >/dev/null; then
    "$aur_helper" -Syu        # official repos + AUR
else
    sudo pacman -Syu
fi
status=$?

if command -v flatpak >/dev/null; then
    flatpak upgrade
fi

# Refresh the Waybar counter now instead of waiting for the next interval.
pkill -RTMIN+8 waybar

echo
if ((status == 0)); then
    notify-send "Update complete"
    echo ":: Update complete"
else
    notify-send "Update finished with errors"
    echo ":: Update finished with errors (exit $status)"
fi
echo
read -rp "Press [ENTER] to close."
