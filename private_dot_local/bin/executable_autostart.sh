#/usr/bin/env bash
#exec dwlb -font "monospace:size=16" &
mako &
waybar &
blueman-applet &
kdeconnect-indicator &
swaybg -i /home/mazon/images/wallpapers/background.png &
#wlr-randr --output HDMI-A-1 --mode 3840x2160@120.000000 &
wlr-randr --output HDMI-A-1 --scale 1.5 &
/home/mazon/.local/bin/evcape.py &
