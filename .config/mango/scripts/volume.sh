#!/usr/bin/env bash

# Change volume of the default sink with swayosd-client.
# Provides visual OSD feedback and removes pamixer dependency.
# Usage: volume.sh [up|down|mute]

case $1 in
    up)
		swayosd-client --output-volume +2
	;;
    down)
		swayosd-client --output-volume -2
	;;
    mute)
		swayosd-client --output-volume mute-toggle
	;;
esac
