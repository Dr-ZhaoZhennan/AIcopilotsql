#!/bin/bash

# AIAgent EulerOS 专用安装脚本

set -e

echo "正在为 EulerOS 安装 AIAgent..."

# 默认安装路径
INSTALL_DIR="${1:-/usr/local/bin}"
CONFIG_DIR="${2:-/usr/local/etc/AIAgent}"

# 检查是否为 EulerOS
if [[ ! -f "/etc/euleros-release" ]] && [[ ! -f "/etc/redhat-release" ]]; then
    echo "警告: 未检测到 EulerOS 系统"
fi

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

# 创建系统服务文件（可选）
cat > /tmp/aiagent.service << 'SERVICE_EOF'
[Unit]
Description=AIAgent SQL Optimization Tool
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/AIAgent
Restart=on-failure

[Install]
WantedBy=multi-user.target
SERVICE_EOF

echo "安装完成！"
echo "使用方法: AIAgent"
echo "配置文件位置: $CONFIG_DIR"
echo ""
echo "可选: 安装为系统服务"
echo "sudo cp /tmp/aiagent.service /etc/systemd/system/"
echo "sudo systemctl enable aiagent.service"
echo "sudo systemctl start aiagent.service"
