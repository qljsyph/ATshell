#!/bin/bash

LOG_FILE="/var/log/mihomo_install.log"

# 检查日志文件是否存在
if [ ! -f "$LOG_FILE" ]; then
    echo "日志文件不存在！"
    exit 1
fi

# 输出日志文件内容
echo "===== Mihomo 安装日志 ====="
cat "$LOG_FILE"

# 提供返回主菜单的选项
echo ""
echo "按任意键返回主菜单..."
read -n 1 -s -r