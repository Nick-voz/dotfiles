#!/bin/bash
MONITOR=1

OPTIONS="0%\n25%\n50%\n100%\nCustom"
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "Monitor Brightness" -i)

case "$CHOICE" in
    "0%")
        ddcutil setvcp 10 0 --display "$MONITOR"
        ;;
    "25%")
        ddcutil setvcp 10 25 --display "$MONITOR"
        ;;
    "50%")
        ddcutil setvcp 10 50 --display "$MONITOR"
        ;;
    "100%")
        ddcutil setvcp 10 100 --display "$MONITOR"
        ;;
    "%")
        LEVEL=$(rofi -dmenu -p "Enter Brightness (0-100):")
        if [[ "$LEVEL" =~ ^[0-9]+$ ]] && [ "$LEVEL" -le 100 ]; then
            ddcutil setvcp 10 "$LEVEL" --display "$MONITOR"
        fi
        ;;
esac
