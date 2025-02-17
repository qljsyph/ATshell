#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

CONFIG_DIR="/etc/mihomo"
BACKUP_DIR="/etc/mihomo/backup_yaml"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

mkdir -p "$CONFIG_DIR"
mkdir -p "$BACKUP_DIR"

backup_config() {
    if [ -f "$CONFIG_FILE" ]; then
        timestamp=$(date +"%Y%m%d%H%M%S")
        backup_file="$BACKUP_DIR/config_$timestamp.yaml"
        cp "$CONFIG_FILE" "$backup_file"
        printf "${YELLOW}旧文件已备份到${NC} $backup_file\n"
    fi
}


restore_backup() {
    backup_files=$(ls $BACKUP_DIR 2>/dev/null)
    if [ -z "$backup_files" ]; then
        printf "${RED}没有可用的备份文件。${NC}\n"
        return 1
    fi
    printf "可用的备份文件：\n"
    select backup_file in $backup_files; do
        if [ -n "$backup_file" ]; then
            cp "$BACKUP_DIR/$backup_file" "$CONFIG_FILE"
            printf "${GREEN}配置文件已还原${NC}\n"
            break
        else
            printf "${RED}无效的选择，请重新选择。${NC}\n"
        fi
    done
}

download_default_config() {
    GITHUB_REPO="https://ghfast.top/https://raw.githubusercontent.com/qljsyph/ATAsst/refs/heads/main/config.yaml"  
    TEMP_FILE="/tmp/temp_config.yaml"

    if ! wget -q --show-progress "$GITHUB_REPO" -O $TEMP_FILE; then
        printf "${RED}下载失败，请检查网络或仓库地址。详细错误信息如下：${NC}\n"
        wget "$GITHUB_REPO" -O $TEMP_FILE 2>&1 | tail -n 5
        rm -f "$TEMP_FILE"
        return 1
    fi

    
    if [ -f "$CONFIG_FILE" ]; then
        printf "${RED}配置文件已存在，是否覆盖？(y/n):${NC} "
        read -r answer
        if [ "$answer" != "y" ]; then
            rm -f "$TEMP_FILE"
            printf "${RED}取消覆盖，退出下载${NC}\n"
            return 1
        fi
        backup_config
    fi

    mv "$TEMP_FILE" "$CONFIG_FILE"
    printf "${GREEN}默认配置文件已下载${NC}\n"
}


manual_upload() {
    read -r -p "请输入远程存储地址: " raw_url
    TEMP_FILE="/tmp/temp_config.yaml"
    if ! wget --show-progress "$raw_url" -O $TEMP_FILE; then
        printf "${RED}下载失败，请检查网络或地址。详细错误信息如下：${NC}\n"
        wget "$raw_url" -O $TEMP_FILE 2>&1 | tail -n 5
        rm -f "$TEMP_FILE"
        return 1
    fi
    if [ -f "$CONFIG_FILE" ]; then
        printf "${RED}配置文件已存在，是否覆盖？(y/n):${NC} "
        read -r answer
        if [ "$answer" != "y" ]; then
            rm -f "$TEMP_FILE"
            printf "${YELLOW}取消覆盖，退出下载。${NC}\n"
            return 1
        fi
        backup_config
    fi
    mv $TEMP_FILE $CONFIG_FILE
    printf "${GREEN}配置文件下载成功${NC}\n"
}


delete_config() {
    if [ -f "$CONFIG_FILE" ]; then
        printf "${RED}确定要删除配置吗？(y/n): ${NC}"
        read -r answer
        if [ "$answer" == "y" ]; then
            rm "$CONFIG_FILE"
            rm -r "${BACKUP_DIR:?}"/*
            printf "${GREEN}配置已删除。${NC}\n"
        else
            printf "${YELLOW}取消删除。${NC}\n"
        fi
    else
        printf "配置文件不存在。\n"
    fi
}


modify_subscription() {
    if [ ! -f "$CONFIG_FILE" ]; then
        printf "${RED}配置文件不存在，无法修改。${NC}\n"
        return 1
    fi

    read -r -p "请输入订阅地址1(留空skip): " sub1_url
    if [ -n "$sub1_url" ]; then
        sed -i "s|url: \"订阅1\"|url: \"$sub1_url\"|" "$CONFIG_FILE"
        printf "${GREEN}订阅地址1已更新。${NC}\n"
    fi

    read -r -p "请输入订阅地址2(留空skip): " sub2_url
    if [ -n "$sub2_url" ]; then
        sed -i "s|url: \"订阅2\"|url: \"$sub2_url\"|" "$CONFIG_FILE"
        printf "${GREEN}订阅地址2已更新。${NC}\n"
    fi
}


echo "==============================="
echo "        配置文件工具           "
echo "==============================="

while true; do
    printf "请选择操作:\n"
    printf "1. 使用基础配置\n"
    printf "2. 使用自定义配置\n"
    printf "3. 修改基础订阅地址\n"
    printf "4. 删除配置及备份\n"
    printf "5. 还原备份\n"
    printf "6. 返回主菜单\n"
    printf "输入选项 (1-6): "
    read -r option
    case $option in
        1)
            download_default_config
            ;;
        2)
            manual_upload
            ;;
        3)
            modify_subscription
            ;;
        4)
            delete_config
            ;;
        5)
            restore_backup
            ;;
        6)
            printf "返回主菜单。\n"
            break
            ;;
        *)
            printf "无效的选项，请输入 1-6。\n"
            ;;
    esac
done