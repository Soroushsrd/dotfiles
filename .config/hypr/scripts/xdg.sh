#!/bin/bash
# __  ______   ____
# \ \/ /  _ \ / ___|
#  \  /| | | | |  _
#  /  \| |_| | |_| |
# /_/\_\____/ \____|
#

# Setup Timers
_sleep1="0.1"
_sleep2="0.5"
_sleep3="2"

# Kill all possible running xdg-desktop-portals
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-gnome
killall -e xdg-desktop-portal-kde
killall -e xdg-desktop-portal-lxqt
killall -e xdg-desktop-portal-wlr
killall -e xdg-desktop-portal-gtk
killall -e xdg-desktop-portal

# Set required environment variables
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland

# Stop all services
#
# NOTE: pipewire / pipewire-pulse / wireplumber are deliberately NOT restarted
# here any more. This block used to read:
#
#     systemctl --user stop pipewire
#     systemctl --user stop wireplumber
#     ... (later) ...
#     systemctl --user start pipewire
#     systemctl --user start wireplumber
#
# which is stock ML4W 2.9.x and is wrong in three ways:
#
#   1. It never stopped pipewire-pulse, so the Pulse shim kept running against
#      a pipewire daemon that was being torn down underneath it.
#   2. pipewire.socket / pipewire-pulse.socket stay active across a `stop`, so
#      anything touching audio in that window socket-activates pipewire again
#      and races the explicit `start` below.
#   3. wireplumber is Requires= / After= pipewire.service. Stopping pipewire
#      already stops wireplumber, and restarting them by hand in this order
#      regularly left wireplumber attached to the wrong instance - devices
#      half-enumerated, defaults not applied, jack detection dead.
#
# None of it is necessary: all three units are socket- and bus-activated and
# come up with the session on their own. Removing this is what stops the audio
# stack from coming up broken at login.
systemctl --user stop xdg-desktop-portal
systemctl --user stop xdg-desktop-portal-gnome
systemctl --user stop xdg-desktop-portal-kde
systemctl --user stop xdg-desktop-portal-wlr
systemctl --user stop xdg-desktop-portal-hyprland
sleep $_sleep1

# Start xdg-desktop-portal-hyprland
/usr/lib/xdg-desktop-portal-hyprland &
sleep $_sleep1

# Start xdg-desktop-portal-gtk
if [ -f /usr/lib/xdg-desktop-portal-gtk ]; then
    /usr/lib/xdg-desktop-portal-gtk &
    sleep $_sleep1
fi

# Start xdg-desktop-portal
/usr/lib/xdg-desktop-portal &
sleep $_sleep2

# Start required services (see the note above re: pipewire / wireplumber)
systemctl --user start xdg-desktop-portal
systemctl --user start xdg-desktop-portal-hyprland

# Run waybar
sleep $_sleep3
# killall waybar
# waybar --config "$HOME/.config/waybar/config.jsonc" --style "$HOME/.config/waybar/style.css" &
~/.config/waybar/launch.sh
