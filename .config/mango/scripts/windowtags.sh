#!/usr/bin/env bash

# Get tag data from mango IPC
DATA=$(mmsg -g -t -c)

# Extract the AppID
APP_ID=$(echo "$DATA" | awk '/appid/ {print $NF}')

# Find occupied tags (single digit, column 6 == '1')
OCCUPIED=$(echo "$DATA" | awk '$2 == "tag" && $3 ~ /^[0-9]$/ && $6 == "1" {print $3}' | paste -sd "," -)

# Format output for Waybar
DISPLAY_TEXT="$APP_ID [$OCCUPIED]"

echo "{\"text\": \"$DISPLAY_TEXT\"}"
