#!/bin/bash

# 定义配置文件路径和备份文件夹路径
CONFIG_DIR="/etc/mihomo"
BACKUP_DIR="/etc/mihomo/backup_yaml"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色
# 创建必要的文件夹
mkdir -p $CONFIG_DIR
mkdir -p $BACKUP_DIR

# 函数：备份旧的配置文件
backup_config() {
    if [ -f "$CONFIG_FILE" ]; then
        timestamp=$(date +"%Y%m%d%H%M%S")
        backup_file="$BACKUP_DIR/config_$timestamp.yaml"
        cp "$CONFIG_FILE" "$backup_file"
        echo -e "${YELLOW}旧文件已备份到${NC}"
    fi
}

# 函数：下载默认配置文件
download_default_config() {
    GITHUB_REPO="https://github.com/your-repo/your-config.yaml"  # 替换为实际的 GitHub 仓库地址
    TEMP_FILE="/tmp/temp_config.yaml"

    # 下载文件
    wget -q $GITHUB_REPO -O $TEMP_FILE
    if [ $? -ne 0 ]; then
        echo "${RED}下载失败，请检查网络或仓库地址。${NC}"
        rm -f $TEMP_FILE
        return 1
    fi

    # 检查文件名
    if [ -f "$CONFIG_FILE" ]; then
        read -r -p "${RED}配置文件已存在，是否覆盖？(y/n):${NC} " answer
        if [ "$answer" != "y" ]; then
            rm -f $TEMP_FILE
            echo "${RED}取消覆盖，退出下载${NC}"
            return 1
        fi
        backup_config
    fi

    mv $TEMP_FILE $CONFIG_FILE
    echo "${GREEN}默认配置文件已下载${NC}"
}

# 函数：手动上传配置文件
manual_upload() {
    read -r -p "选择上传方式 (1: 本地上传, 2: 远程下载): " choice
    case $choice in
        1)
            read -r -p "请输入本地文件的路径: " local_file
            if [ ! -f "$local_file" ]; then
                echo "${RED}文件不存在，请检查路径。${NC}"
                return 1
            fi
            if [ -f "$CONFIG_FILE" ]; then
                read -r -p "${RED}配置已存在，是否覆盖？(y/n): ${NC}" answer
                if [ "$answer" != "y" ]; then
                    echo "${YELLOW}取消覆盖，退出上传。${NC}"
                    return 1
                fi
                backup_config
            fi
            cp "$local_file" "$CONFIG_FILE"
            echo "${GREEN}配置文件上传成功${NC}"
            ;;
        2)
            read -r -p "请输入远程地址: " raw_url
            TEMP_FILE="/tmp/temp_config.yaml"
            wget -q "$raw_url" -O $TEMP_FILE
            if [ $? -ne 0 ]; then
                echo "${RED}下载失败，请检查网络或地址。${NC}"
                rm -f $TEMP_FILE
                return 1
            fi
            if [ -f "$CONFIG_FILE" ]; then
                read -r -p "配置文件已存在，是否覆盖？(y/n): " answer
                if [ "$answer" != "y" ]; then
                    rm -f $TEMP_FILE
                    echo "${YELLOW}取消覆盖，退出下载。${NC}"
                    return 1
                fi
                backup_config
            fi
            mv $TEMP_FILE $CONFIG_FILE
            echo "${GREEN}配置文件下载成功${NC}"
            ;;
        *)
            echo "无效的选择，请输入 1 或 2。"
            return 1
            ;;
    esac
}

# 函数：删除配置文件
delete_config() {
    if [ -f "$CONFIG_FILE" ]; then
        read -r -p "${RED}确定要删除配置吗？(y/n): ${NC}" answer
        if [ "$answer" == "y" ]; then
            rm "$CONFIG_FILE"
            echo "${GREEN}配置已删除。${NC}"
        else
            echo "${YELLOW}取消删除。${NC}"
        fi
    else
        echo "config.yaml 文件不存在。"
    fi
}

# 函数：修改订阅地址
modify_subscription() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "${RED}文件不存在，无法修改订阅地址。${NC}"
        return 1
    fi

    read -r -p "请输入订阅地址1（留空skip）: " sub1_url
    if [ -n "$sub1_url" ]; then
        sed -i "s/url: \"订阅1\"/url: \"$sub1_url\"/" "$CONFIG_FILE"
        echo "${GREEN}订阅地址1已更新。${NV}"
    fi

    read -r -p "请输入订阅地址2（留空skip）: " sub2_url
    if [ -n "$sub2_url" ]; then
        sed -i "s/url: \"订阅2\"/url: \"$sub2_url\"/" "$CONFIG_FILE"
        echo "${GREEN}订阅地址2已更新。${NV}"
    fi
}

# 主菜单
while true; do
    echo "请选择操作:"
    echo "1. 使用默认 yaml 下载"
    echo "2. 手动上传"
    echo "3. 删除 config.yaml"
    echo "4. 修改订阅地址"
    echo "5. 退出"
    read -r -p "输入选项 (1-5): " option
    case $option in
        1)
            download_default_config
            ;;
        2)
            manual_upload
            ;;
        3)
            delete_config
            ;;
        4)
            modify_subscription
            ;;
        5)
            echo "退出脚本。"
            break
            ;;
        *)
            echo "无效的选项，请输入 1-5。"
            ;;
    esac
done