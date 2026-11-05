#!/usr/bin/env bash
# No `set -e`: a failing service (e.g. swaync hitting systemd's start limit after
# the previous session crashed on logout) must not prevent waybar from starting.
set -uo pipefail
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE
# Units that crash-looped when the old compositor went away are stuck in
# 'start-limit-hit'; clear that so they can start in this session.
systemctl --user reset-failed swaync.service xdg-desktop-portal-hyprland.service xdg-desktop-portal.service 2>/dev/null
systemctl --user restart swaync.service
# A portal may already be running from the TTY before the Wayland session existed.
# Restart only its dispatcher after importing the session environment.
systemctl --user restart xdg-desktop-portal.service
exec "$HOME/.config/waybar/launch.sh"
