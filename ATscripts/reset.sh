#!/bin/bash

if systemctl is-active --quiet NetworkManager; then
    echo "Restarting NetworkManager service..."
    sudo systemctl restart NetworkManager
    echo "NetworkManager restarted successfully."
elif systemctl is-active --quiet systemd-networkd; then
    echo "Restarting systemd-networkd service..."
    sudo systemctl restart systemd-networkd
    echo "systemd-networkd restarted successfully."
elif systemctl is-active --quiet networking; then
    echo "Restarting networking service..."
    sudo systemctl restart networking
    echo "networking restarted successfully."
elif systemctl is-active --quiet netplan; then
    echo "Applying netplan configuration..."
    sudo netplan apply
    echo "Netplan configuration applied successfully."
else
    echo "No known network management service found."
fi