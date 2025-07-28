#!/bin/bash

# AIAgent 安装脚本

set -e

echo "正在安装 AIAgent..."

# 默认安装路径
INSTALL_DIR="${1:-/usr/local/bin}"
CONFIG_DIR="${2:-/usr/local/etc/AIAgent}"

# 创建目录
sudo mkdir -p "$INSTALL_DIR"
sudo mkdir -p "$CONFIG_DIR"

# 复制可执行文件
sudo cp AIAgent "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/AIAgent"

# 复制配置文件
if [ -d "config" ]; then
    sudo cp -r config "$CONFIG_DIR/"
fi

echo "安装完成！"
echo "使用方法: AIAgent"
echo "配置文件位置: $CONFIG_DIR"
