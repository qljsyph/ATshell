#!/bin/bash

# 删除 /usr/local/bin/mihomo
function remove_mihomo_bin() {
    if [ -f "/usr/local/bin/mihomo" ]; then
        echo "正在删除 /usr/local/bin/mihomo..."
        sudo rm -f /usr/local/bin/mihomo
        echo "/usr/local/bin/mihomo 已删除"
    else
        echo "/usr/local/bin/mihomo 不存在，跳过删除"
    fi
}

# 删除 /etc/systemd/system/mihomo.service
function remove_mihomo_service() {
    if [ -f "/etc/systemd/system/mihomo.service" ]; then
        echo "正在删除 /etc/systemd/system/mihomo.service..."
        sudo rm -f /etc/systemd/system/mihomo.service
        echo "/etc/systemd/system/mihomo.service 已删除"
        # 重新加载 systemd
        sudo systemctl daemon-reload
    else
        echo "/etc/systemd/system/mihomo.service 不存在，跳过删除"
    fi
}

# 删除 /etc/mihomo
function remove_mihomo_config() {
    if [ -d "/etc/mihomo" ]; then
        echo "正在删除 /etc/mihomo..."
        sudo rm -rf /etc/mihomo
        echo "/etc/mihomo 已删除"
    else
        echo "/etc/mihomo 不存在，跳过删除"
    fi
}

# 执行卸载操作
function uninstall() {
    echo "正在卸载 mihomo..."

    remove_mihomo_bin
    remove_mihomo_service
    remove_mihomo_config

    echo "卸载完成，返回主菜单..."
}

# 主控制逻辑
uninstall