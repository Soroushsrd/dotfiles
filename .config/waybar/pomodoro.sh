#!/bin/bash
STATE_FILE="/tmp/pomodoro_state"
TIME_FILE="/tmp/pomodoro_time"

# Initialize if files don't exist
if [[ ! -f "$STATE_FILE" ]]; then
    echo "idle" > "$STATE_FILE"
    echo "0" > "$TIME_FILE"
fi

STATE=$(cat "$STATE_FILE")
TIME=$(cat "$TIME_FILE")

case "$1" in
    "start")
        echo "work" > "$STATE_FILE"
        echo "1500" > "$TIME_FILE"  # 25 minutes
        ;;
    "break")
        echo "break" > "$STATE_FILE"
        echo "300" > "$TIME_FILE"   # 5 minutes
        ;;
    "stop")
        echo "idle" > "$STATE_FILE"
        echo "0" > "$TIME_FILE"
        ;;
    *)
        if [[ "$STATE" != "idle" && "$TIME" -gt 0 ]]; then
            ((TIME--))
            echo "$TIME" > "$TIME_FILE"
        fi
        
        # Format time display
        MINUTES=$((TIME / 60))
        SECONDS=$((TIME % 60))
        
        case "$STATE" in
            "work") ICON="🍅" ;;
            "break") ICON="☕" ;;
            *) ICON="⏸️" ;;
        esac
        
        if [[ "$TIME" -eq 0 && "$STATE" != "idle" ]]; then
            echo "$ICON DONE!"
        else
            printf "%s %02d:%02d" "$ICON" "$MINUTES" "$SECONDS"
        fi
        ;;
esac
