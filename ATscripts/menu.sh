#!/bin/bash

# 设置基础路径和脚本存放目录
BASE_URL="https://ghfast.top/https://raw.githubusercontent.com/qljsyph/ATshell/refs/heads/main/ATscripts"
SCRIPTS_DIR="/etc/mihomo/scripts"

# 版本号
VERSION="1.0.7"

# 需要的脚本文件列表
files=("menu.sh" "install.sh" "uninstall.sh" "run.sh" "tools.sh" "catlog.sh" "update_scripts.sh")

# 检查并下载缺失的脚本文件
function check_and_download_scripts() {
    echo "检查并下载缺失的脚本文件..."

    for file in "${files[@]}"; do
        if [ ! -f "$SCRIPTS_DIR/$file" ]; then
            echo "依赖文件不存在，正在下载..."
            wget -O "$SCRIPTS_DIR/$file" "$BASE_URL/$file" > /dev/null 2>&1 || { echo "下载 $file 失败！"; exit 1; }
        else
            echo "文件已存在，无需下载。"
        fi
    done

    # 设置脚本权限
    echo "设置脚本文件权限为 755 ..."
    sudo chmod -R 755 "$SCRIPTS_DIR"/* || { echo "设置脚本权限失败！"; exit 1; }
}

# 主菜单显示
function show_menu() {
    echo "======================================================="
    echo "         欢迎使用虚空终端辅助工具   致谢MetaCubeX     "
    echo "             版本:1.0.7      工具作者:qljsyph       "
    echo " Github：https://github.com/qljsyph/ATshell/tree/main"
    echo "======================================================="
    echo "版本:$VERSION"
    echo "1. 安装"
    echo "2. 删除"
    echo "3. 运行"
    echo "4. 常用工具"
    echo "5. 查看安装日志"
    echo "6. 更新脚本"
    echo "7. 退出"
}

# 主逻辑
# 在显示菜单之前先检查并下载缺失的子脚本
check_and_download_scripts

while true; do
    show_menu
    read -r -p "请输入选项: " choice

    case $choice in
        1)
            echo "执行安装..."
            sudo bash "$SCRIPTS_DIR/install.sh"
            ;;
        2)
            echo "执行删除..."
            sudo bash "$SCRIPTS_DIR/uninstall.sh"
            ;;
        3)
            echo "执行运行..."
            sudo bash "$SCRIPTS_DIR/run.sh"
            ;;
        4) 
            echo "常用工具..."
            sudo bash "$SCRIPTS_DIR/tools.sh"
            ;;
        5)
            echo "查看安装错误日志..."
            sudo bash "$SCRIPTS_DIR/catlog.sh"
            ;;
        6)
            # 直接执行更新脚本 update_scripts.sh
            echo "执行脚本更新..."
            sudo bash "$SCRIPTS_DIR/update_scripts.sh"
            ;;
        7)
            echo "退出程序"
            break
            ;;
        *)
            echo "无效选项，请重新选择！"
            ;;
    esac
done