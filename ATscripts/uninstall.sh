#!/bin/bash

function remove_mihomo_bin() {
    if [ -f "/usr/local/bin/mihomo" ]; then
        echo "正在删除核心"
        sudo rm -f /usr/local/bin/mihomo
        echo "核心已删除"
    else
        echo "核心不存在，跳过删除"
    fi
}

function remove_mihomo_service() {
    if [ -f "/etc/systemd/system/mihomo.service" ]; then
        echo "正在删除服务"
        sudo rm -f /etc/systemd/system/mihomo.service
        echo "服务文件已删除"
        # 重新加载 systemd
        sudo systemctl daemon-reload
    else
        echo "服务文件不存在，跳过删除"
    fi
}

function remove_mihomo_config() {
    if [ -d "/etc/mihomo" ]; then
        echo "正在删除配置文件"
        sudo rm -rf /etc/mihomo
        echo "配置已删除"
    else
        echo "配置不存在，跳过删除"
    fi
}

function uninstall() {
    echo "正在卸载 mihomo..."

    remove_mihomo_bin
    remove_mihomo_service
    remove_mihomo_config

    echo "卸载完成，返回主菜单..."
}

uninstall