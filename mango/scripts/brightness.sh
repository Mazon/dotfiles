#!/usr/bin/env bash

# Change brightness level with swayosd-client.
# Usage: brightness.sh [up|down]

case $1 in
up)
	swayosd-client --brightness +2
	;;
down)
	swayosd-client --brightness -2
	;;
esac
