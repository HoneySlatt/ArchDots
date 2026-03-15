#!/bin/bash

# Check if ProtonVPN interface (proton0) is active
if ip link show | grep -q "proton0:"; then
    # VPN connected → disconnect
    protonvpn disconnect
    notify-send "ProtonVPN" "Disconnecting..." -i network-vpn-disconnected
else
    # VPN disconnected → connect to fastest server
    protonvpn connect
    notify-send "ProtonVPN" "Connecting..." -i network-vpn
fi
