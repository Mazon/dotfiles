#!/usr/bin/env bash

# Change volume of the default sink with pamixer.
# Usage: volume.sh [up|down|mute]

case $1 in
    up)
		pamixer -i 2
	;;
    down)
		pamixer -d 2
	;;
    mute)
		pamixer -t
	;;
esac
