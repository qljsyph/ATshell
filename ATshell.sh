#!/bin/bash

# 日志文件
LOG_FILE="/var/log/mihomo_install.log"

# 用于输出日志
function log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

# 清空旧的日志文件
true > "$LOG_FILE"

log_message "===== 开始安装脚本 ====="

# 检查并安装 sudo
if ! command -v sudo &> /dev/null; then
    log_message "未检测到 sudo，正在安装..."
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get update && sudo apt-get install -y sudo || { log_message "安装 sudo 失败！"; exit 1; }
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y sudo || { log_message "安装 sudo 失败！"; exit 1; }
    else
        log_message "无法通过 apt-get 或 yum 安装 sudo，请手动安装！"
        exit 1
    fi
else
    log_message "已安装 sudo"
fi

# 检查并安装解压工具 tar
if ! command -v tar &> /dev/null; then
    log_message "未检测到 tar，正在安装..."
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y tar || { log_message "安装 tar 失败！"; exit 1; }
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y tar || { log_message "安装 tar 失败！"; exit 1; }
    else
        log_message "无法通过 apt-get 或 yum 安装 tar，请手动安装！"
        exit 1
    fi
else
    log_message "已安装 tar"
fi

# 检查并安装 wget
if ! command -v wget &> /dev/null; then
    log_message "未检测到 wget，正在安装..."
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y wget || { log_message "安装 wget 失败！"; exit 1; }
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y wget || { log_message "安装 wget 失败！"; exit 1; }
    else
        log_message "无法通过 apt-get 或 yum 安装 wget，请手动安装！"
        exit 1
    fi
else
    log_message "已安装 wget"
fi

# 检查并安装 curl
if ! command -v curl &> /dev/null; then
    log_message "未检测到 curl，正在安装..."
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y curl || { log_message "安装 curl 失败！"; exit 1; }
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y curl || { log_message "安装 curl 失败！"; exit 1; }
    else
        log_message "无法通过 apt-get 或 yum 安装 curl，请手动安装！"
        exit 1
    fi
else
    log_message "已安装 curl"
fi
# 检查并安装 jq
if ! command -v jq &> /dev/null; then
    log_message "未检测到 jq，正在安装..."
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y jq || { log_message "安装 jq 失败！"; exit 1; }
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y jq || { log_message "安装 jq 失败！"; exit 1; }
    else
        log_message "无法通过 apt-get 或 yum 安装 jq，请手动安装！"
        exit 1
    fi
else
    log_message "已安装 jq"
fi

# 确保脚本目录存在
SCRIPTS_DIR="/etc/mihomo/scripts"
if [ ! -d "$SCRIPTS_DIR" ]; then
    log_message "脚本目录不存在，正在创建目录..."
    sudo mkdir -p "$SCRIPTS_DIR" || { log_message "创建脚本目录失败！"; exit 1; }
fi

# 设置脚本目录权限为 755
log_message "设置脚本目录权限为 755 ..."
sudo chmod -R 755 "$SCRIPTS_DIR" || { log_message "设置脚本目录权限失败！"; exit 1; }

# 下载主脚本 menu.sh
log_message "下载主脚本 menu.sh ..."
wget -O "$SCRIPTS_DIR/menu.sh" "https://raw.githubusercontent.com/qljsyph/ATshell/refs/heads/main/ATscripts/menu.sh" || { log_message "下载 menu.sh 失败！"; exit 1; }

# 创建快捷脚本 /usr/local/bin/AT
log_message "创建快捷脚本 /usr/local/bin/AT ..."
echo "#!/bin/bash" | sudo tee /usr/local/bin/AT > /dev/null
echo "bash /etc/mihomo/scripts/menu.sh" | sudo tee -a /usr/local/bin/AT > /dev/null
sudo chmod +x /usr/local/bin/AT || { log_message "创建快捷脚本失败！"; exit 1; }

log_message "===== 安装完成 ====="

# 提示用户完成安装并使用快捷命令
echo "安装完成！现在你可以在终端中输入 'AT' 来执行主脚本。"