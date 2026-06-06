#!/usr/bin/env bash

options="Shutdown\nReboot\nSleep\nLogout"

selection=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu:")

case "$selection" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Sleep")
        systemctl suspend
        ;;
    "Logout")
        awesome-client 'awesome.quit()'
        ;;
esac
