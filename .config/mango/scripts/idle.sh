#!/usr/bin/env bash

# Idle timeout chain:
# 1. 300s (5 min)  → dim screen with dimland
# 2. 600s (10 min) → lock screen
# 3. 1800s (30 min) → turn off display via DPMS
# Resume from dim → kill dimland to restore brightness
# Resume from DPMS → turn display back on + restart wlsunset (night light)

swayidle \
	timeout 300 'dimland -a 0.3' \
		resume 'bash ~/.config/mango/scripts/exitdim.sh' \
	timeout 600 'swaylock -f -c 000000' \
	timeout 1800 'wlr-dpms off' \
		resume 'wlr-dpms on && ~/.config/mango/scripts/restart_wlsunset.sh'
