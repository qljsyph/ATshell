#!/bin/bash

# 设置基础路径和脚本存放目录
BASE_URL="https://ghfast.top/https://raw.githubusercontent.com/qljsyph/ATshell/refs/heads/main/ATscripts"
SCRIPTS_DIR="/etc/mihomo/scripts"
LOG_FILE="/var/log/mihomo_update.log"
TEMP_DIR="/tmp/mihomo_update_temp"

# 最大重试次数
MAX_RETRIES=3

# 用于输出日志
function log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

# 带重试机制的 curl 函数
function curl_with_retry() {
    local url="$1"
    local retries=0
    while [ $retries -lt $MAX_RETRIES ]; do
        result=$(curl -s "$url")
        if [ $? -eq 0 ] && [ -n "$result" ]; then
            echo "$result"
            return 0
        fi
        log_message "curl 下载 $url 失败，正在进行第 $((retries + 1)) 次重试..."
        retries=$((retries + 1))
        sleep 2
    done
    log_message "curl 下载 $url 失败，达到最大重试次数。"
    return 1
}

# 带重试机制的 wget 函数
function wget_with_retry() {
    local url="$1"
    local output="$2"
    local retries=0
    while [ $retries -lt $MAX_RETRIES ]; do
        if wget -O "$output" "$url"; then
            return 0
        fi
        log_message "wget 下载 $url 失败，正在进行第 $((retries + 1)) 次重试..."
        retries=$((retries + 1))
        sleep 2
    done
    log_message "wget 下载 $url 失败，达到最大重试次数。"
    return 1
}

# 清空旧的日志文件
true > "$LOG_FILE"

log_message "===== 开始更新脚本 ====="

# 检查脚本目录是否存在
if [ ! -d "$SCRIPTS_DIR" ]; then
    log_message "脚本目录不存在，正在创建目录..."
    sudo mkdir -p "$SCRIPTS_DIR" || { log_message "创建目录失败！"; exit 1; }
fi

# 获取当前本地脚本版本（从 menu.sh 中提取版本号）
if [ -f "$SCRIPTS_DIR/menu.sh" ]; then
    local_current_version=$(grep -oP '(?<=版本:)[0-9.]+' "$SCRIPTS_DIR/menu.sh" | head -n1)
    log_message "当前本地版本：$local_current_version"
else
    log_message "未找到本地 menu.sh，假设当前版本为 0.0.0"
    local_current_version="0.0.0"
fi

# 获取远程版本信息
log_message "获取远程版本信息..."
remote_version=$(curl_with_retry "$BASE_URL/menu.sh" | grep -oP '(?<=版本:)[0-9.]+' | head -n1)

if [ -z "$remote_version" ]; then
    log_message "获取远程版本信息失败，退出脚本。"
    exit 1
fi

log_message "远程版本：$remote_version"

# 对比版本号，如果不同则提示更新
if [ "$local_current_version" != "$remote_version" ]; then
    echo "当前版本：$local_current_version"
    echo "远程版本：$remote_version"
    read -r -p "发现新版本，是否更新脚本？(y/n): " update_choice

    if [ "$update_choice" != "y" ]; then
        log_message "用户选择不更新，返回主菜单。"
        "$SCRIPTS_DIR/menu.sh"
        exit 0
    fi
else
    log_message "当前已是最新版本，无需更新。"
    echo "当前已是最新版本，无需更新。"
    "$SCRIPTS_DIR/menu.sh"
    exit 0
fi

# 删除旧版本脚本
log_message "删除旧版本脚本..."

for file in "$SCRIPTS_DIR"/*; do
    if [ -f "$file" ]; then
        log_message "删除 $file ..."
        sudo rm -f "$file" || { log_message "删除文件 $file 失败！"; exit 1; }
    fi
done

# 进入脚本目录
cd "$SCRIPTS_DIR" || { log_message "无法进入脚本目录！"; exit 1; }

# 下载最新的脚本文件
log_message "下载最新的脚本文件..."
files=("menu.sh" "install.sh" "uninstall.sh" "run.sh" "catlog.sh" "update_scripts.sh")

for file in "${files[@]}"; do
    log_message "正在下载 $file ..."
    if ! wget_with_retry "$BASE_URL/$file" "$SCRIPTS_DIR/$file"; then
        log_message "下载 $file 失败，退出脚本。"
        exit 1
    fi
done

# 设置脚本权限
log_message "设置脚本文件权限为 755 ..."
sudo chmod -R 755 "$SCRIPTS_DIR"/* || { log_message "设置脚本权限失败！"; exit 1; }

# 清除临时目录
if [ -d "$TEMP_DIR" ]; then
    log_message "清除临时目录 $TEMP_DIR ..."
    sudo rm -rf "$TEMP_DIR" || { log_message "清除临时目录 $TEMP_DIR 失败！"; exit 1; }
fi

log_message "===== 脚本更新完成 ====="

# 提示用户完成更新
echo "脚本更新完成！请检查日志文件：$LOG_FILE"

# 返回主菜单
echo "返回主菜单..."
"$SCRIPTS_DIR/menu.sh"