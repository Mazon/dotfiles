#!/usr/bin/env bash

pkill -x wlsunset
nohup wlsunset -T 6500 -t 3500 >> /dev/null 2>&1 &