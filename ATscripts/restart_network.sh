#!/bin/bash

# 检测并重启网络服务的通用脚本

# 检测 NetworkManager 服务
if systemctl is-active --quiet NetworkManager; then
    echo "Restarting NetworkManager service..."
    sudo systemctl restart NetworkManager
    echo "NetworkManager restarted successfully."
elif systemctl is-active --quiet systemd-networkd; then
    # 检测 systemd-networkd 服务
    echo "Restarting systemd-networkd service..."
    sudo systemctl restart systemd-networkd
    echo "systemd-networkd restarted successfully."
elif systemctl is-active --quiet networking; then
    # 检测 networking 服务（较旧的系统可能使用）
    echo "Restarting networking service..."
    sudo systemctl restart networking
    echo "networking restarted successfully."
elif systemctl is-active --quiet netplan; then
    # 检测 netplan 服务（Ubuntu 18.04 及更高版本）
    echo "Applying netplan configuration..."
    sudo netplan apply
    echo "Netplan configuration applied successfully."
else
    # 如果没有检测到已知的网络管理服务
    echo "No known network management service found."
fi