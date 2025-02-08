#!/bin/bash

# 子脚本文件列表
scripts=("install.sh" "uninstall.sh" "run.sh" "catlog.sh" "update-scripts")

# 子脚本检查函数
function check_scripts() {
    # 检查 scripts 数组是否为空
    if [ ${#scripts[@]} -eq 0 ]; then
        return
    fi

    missing_scripts=()
    for script in "${scripts[@]}"; do
        if [ ! -f "$script" ]; then
            missing_scripts+=("$script")
        fi
    done

    if [ ${#missing_scripts[@]} -gt 0 ]; then
        echo "下载缺失的脚本..."
        for missing_script in "${missing_scripts[@]}"; do
            if ! curl -O "https://ghfast.top/https://raw.githubusercontent.com/qljsyph/ATshell/main/ATscripts/$missing_script"; then
                # 输出 curl 命令的具体错误信息
                echo "下载 $missing_script 失败，错误信息: $?"
                echo "请检查网络连接或 URL 是否正确。"
                exit 1
            fi
        done
        echo "下载完成，继续执行后续操作..."
        # 这里可以根据需要决定是否退出脚本
        # 如果需要脚本继续执行后续逻辑，可以移除下面的 exit 语句
        # exit 1
    fi
}

# 主菜单
function show_menu() {
    clear
    echo "====================================================="
    echo "        欢迎使用虚空终端辅助工具 请遵守当地法律法规    "
    echo "             版本：1.0.0      作者：qljsyph       "
    echo " Github：https://github.com/qljsyph/ATshell/tree/main"
    echo "====================================================="
    echo "1) 安装"
    echo "2) 删除"
    echo "3) 运行"
    echo "4) 查看安装错误日志"
    echo "5) 更新脚本"
    echo "6) 退出"
    echo -n "请输入你的选择 [1-6]: "
}

# 安装功能
function install() {
    if [ -f /usr/local/bin/mihomo ]; then
        read -r -p "发现已安装的mihomo文件，是否删除并重新安装？(y/n): " confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            echo "删除现有的mihomo文件..."
            rm -f /usr/local/bin/mihomo
            echo "文件已删除，开始安装..."
            ./install.sh
        else
            echo "取消安装操作。"
        fi
    else
        echo "没有检测到已安装的mihomo文件，开始安装..."
        ./install.sh
    fi
}

# 删除功能
function uninstall() {
    ./uninstall.sh
}

# 运行功能
function run() {
    ./run.sh
}

# 查看日志
function view_log() {
    ./catlog.sh
}

# 更新脚本
function update_scripts() {
    ./update-scripts.sh
}

# 主控制逻辑
check_scripts # 在进入主菜单之前检查所有脚本是否齐全

while true; do
    show_menu
    read -r -p "请输入选项: " choice
    case $choice in
        1) install ;;
        2) uninstall ;;
        3) run ;;
        4) view_log ;;
        5) update_scripts ;;
        6) echo "退出程序..."; exit 0 ;;
        *) echo "无效选项，请重新选择."; sleep 2 ;;
    esac
done