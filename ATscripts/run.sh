#!/bin/bash

# 检查 /etc/mihomo 是否存在 config.yaml 文件
function check_config_file() {
    if [ ! -f "/etc/mihomo/config.yaml" ]; then
        echo "错误：/etc/mihomo/config.yaml 文件不存在，请上传 config.yaml 文件！"
        return 1
    fi
    return 0
}

# 执行 systemctl 命令
function check_and_run() {
   
    echo "正在重新加载 systemd 配置..."
    sudo systemctl daemon-reload

    echo "正在启用自启动服务..."
    sudo systemctl enable mihomo

    echo "正在启动mihomo服务"
    sudo systemctl start mihomo

    echo "正在查看 mihomo 服务状态..."
    service_status=$(systemctl status mihomo)

    echo "$service_status"

    if echo "$service_status" | grep -q "Active: failed"; then
        echo "mihomo 服务启动失败，状态为 failed。"
        echo "$service_status"
        echo "返回主菜单..."
        return 1
    fi

    if echo "$service_status" | grep -q "Active: active (running)"; then
        echo "mihomo 服务已成功启动，状态为 active (running)。"

        # 启用 IPv4 和 IPv6 转发
        echo "正在启用 IPv4 和 IPv6 转发..."
        sudo sed -i '/net.ipv4.ip_forward/s/^#//;/net.ipv6.conf.all.forwarding/s/^#//' /etc/sysctl.conf
        sudo sysctl -p

        # 重启网络服务
        sudo chmod +x /etc/mihomo/scripts/restart_network.sh
        echo "正在重启网络..."
        restart_output=$(sudo /etc/mihomo/scripts/restart_network.sh)

        if echo "$restart_output" | grep -q "successfully"; then
            echo "网络服务已重启，配置已更新。"
        elif echo "$restart_output" | grep -q "No known network management service found"; then
            echo "未检测到有效的服务，请检查日志或重启系统。"
            return 1
        else
            echo "未知错误，请检查日志。"
            return 1
        fi
    fi
}

echo "正在执行 run.sh 脚本..."

check_config_file
if [ $? -ne 0 ]; then
    echo "返回主菜单..."
    exit 1
fi

check_and_run

echo "执行完毕，返回主菜单..."