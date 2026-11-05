#!/usr/bin/env bash
set -euo pipefail
# Reuse the existing launcher theme without requiring the legacy wlogout package.
choice=$(printf 'Lock\nSuspend\nLog out\nReboot\nShut down\n' | rofi -dmenu -i -p 'Power') || exit 0
case "$choice" in
 Lock) exec hyprlock ;;
 Suspend) loginctl lock-session; exec systemctl suspend ;;
 'Log out'|Reboot|'Shut down')
  answer=$(printf 'Cancel\nConfirm\n' | rofi -dmenu -i -p "$choice?") || exit 0
  [[ "$answer" == Confirm ]] || exit 0
  case "$choice" in
   'Log out') hyprctl dispatch 'hl.dsp.exit()' ;;
   Reboot) systemctl reboot ;;
   'Shut down') systemctl poweroff ;;
  esac ;;
esac
