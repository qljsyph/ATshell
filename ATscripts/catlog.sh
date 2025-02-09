#!/bin/bash

LOG_FILE="/var/log/mihomo_install.log"


if [ ! -f "$LOG_FILE" ]; then
    echo "日志文件不存在！"
    exit 1
fi


echo "===== Mihomo 安装日志 ====="
cat "$LOG_FILE"


echo ""
echo "按任意键返回主菜单..."
read -n 1 -s -r