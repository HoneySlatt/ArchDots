#!/bin/bash

BASE_CONFIG="DP-2, 3840x2160@240, 0x0, 1.5, bitdepth, 10"

current=$(hyprctl monitors -j | python3 -c "
import json, sys
monitors = json.load(sys.stdin)
for m in monitors:
    if m['name'] == 'DP-2':
        print(m['colorManagementPreset'])
")

if [ "$current" = "hdr" ]; then
    hyprctl keyword monitor "$BASE_CONFIG"
    notify-send "HDR" "Disabled"
else
    hyprctl keyword monitor "$BASE_CONFIG, cm, hdr,"
    notify-send "HDR" "Enabled"
fi
