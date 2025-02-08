#!/bin/bash

LOG_FILE="/var/log/mihomo_install.log"

true > "$LOG_FILE"

function log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

log_message "===== 开始安装 ====="


if [ -f "/usr/local/bin/mihomo" ]; then
    log_message "/usr/local/bin/mihomo 已存在，是否删除？（y/n）"
    read -r choice
    if [ "$choice" == "y" ]; then
        log_message "正在删除现有的 /usr/local/bin/mihomo ..."
        sudo rm -f /usr/local/bin/mihomo || { log_message "删除失败！"; exit 1; }
        log_message "现有文件已删除"
    else
        log_message "用户选择不删除文件，退出安装"
        exit 0
    fi
fi

function get_github_versions() {
    local url=$1
    curl -s "$url" | jq -r '.assets[] | select(.name | test(".gz$")) | .name' 
}

# 解压并安装到 /usr/local/bin
function install_to_bin() {
    local file_name=$1

    # 解压文件到临时目录
    echo "正在解压 $file_name..."
    tar -xzf "$file_name" -C /tmp

    # 假设解压后文件是一个单一文件，我们把它重命名为 mihomo 并移动到 /usr/local/bin
    extracted_file=$(tar -tf "$file_name" | head -n 1)
    
    if [ -f "/tmp/$extracted_file" ]; then
        echo "正在将文件移动到 /usr/local/bin 并重命名为 mihomo..."
        sudo mv "/tmp/$extracted_file" /usr/local/bin/mihomo
        sudo chmod 755 /usr/local/bin/mihomo
        echo "安装完成，mihomo 已安装到 /usr/local/bin 并设置了 755 权限"

        # 创建 systemd 服务文件
        echo "正在创建 /etc/systemd/system/mihomo.service 文件..."
        sudo bash -c 'cat <<EOF > /etc/systemd/system/mihomo.service
[Unit]
Description=mihomo Daemon, Another Clash Kernel.
After=network.target NetworkManager.service systemd-networkd.service iwd.service

[Service]
Type=simple
LimitNPROC=500
LimitNOFILE=1000000
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
Restart=always
ExecStartPre=/usr/bin/sleep 1s
ExecStart=/usr/local/bin/mihomo -d /etc/mihomo
ExecReload=/bin/kill -HUP \$MAINPID

[Install]
WantedBy=multi-user.target
EOF'

        # 重新加载 systemd，启用 mihomo 服务
        echo "正在重新加载 systemd 服务，启用 mihomo 服务..."
        sudo systemctl daemon-reload
        sudo systemctl enable mihomo.service
        echo "mihomo 服务已设置为开机自启"
    else
        echo "解压后未找到文件，安装失败。"
        return 1
    fi
}

# 安装Alpha版本
function install_alpha() {
    echo "正在获取Alpha版版本信息..."
    alpha_versions=$(get_github_versions "https://api.github.com/repos/MetaCubeX/mihomo/releases?per_page=5")

    if [ -z "$alpha_versions" ]; then
        echo "未找到Alpha版的Linux系统.gz压缩包，返回上层..."
        return
    fi

    echo "请选择要安装的Alpha版本架构："
    select alpha_version in $alpha_versions; do
        if [ -n "$alpha_version" ]; then
            echo "正在下载 Alpha 版本: $alpha_version"
            curl -L "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/$alpha_version" -o "$alpha_version"
            echo "$alpha_version 下载完成"

            # 解压并安装到 /usr/local/bin
            install_to_bin "$alpha_version"
            break
        else
            echo "无效选择，请重新选择."
        fi
    done
}

# 安装发行版
function install_stable() {
    echo "正在获取发行版版本信息..."
    stable_versions=$(get_github_versions "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest")

    if [ -z "$stable_versions" ]; then
        echo "未找到发行版的Linux系统.gz压缩包，返回上层..."
        return
    fi

    echo "请选择要安装的发行版架构："
    select stable_version in $stable_versions; do
        if [ -n "$stable_version" ]; then
            echo "正在下载 发行版: $stable_version"
            curl -L "https://github.com/MetaCubeX/mihomo/releases/download/$stable_version/$stable_version" -o "$stable_version"
            echo "$stable_version 下载完成"

            # 解压并安装到 /usr/local/bin
            install_to_bin "$stable_version"
            break
        else
            echo "无效选择，请重新选择."
        fi
    done
}

# 安装主菜单
function show_menu() {
    clear
    echo "==============================="
    echo "       安装脚本菜单           "
    echo "==============================="
    echo "1) 安装Alpha"
    echo "2) 安装发行版"
    echo "3) 返回上层"
    echo -n "请输入你的选择 [1-3]: "
}

# 主控制逻辑
while true; do
    show_menu
    read -r -p "请输入选项: " choice
    case $choice in
        1) install_alpha ;;
        2) install_stable ;;
        3) echo "返回上层..."; break ;;
        *) echo "无效选项，请重新选择."; sleep 2 ;;
    esac
done