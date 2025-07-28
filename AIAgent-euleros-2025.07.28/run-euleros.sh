#!/bin/bash

# EulerOS 专用运行脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXECUTABLE="$SCRIPT_DIR/AIAgent"

# 检查可执行文件
if [ ! -f "$EXECUTABLE" ]; then
    echo "错误: 找不到可执行文件 $EXECUTABLE"
    exit 1
fi

# 检查 EulerOS 环境
if [[ -f "/etc/euleros-release" ]]; then
    echo "检测到 EulerOS 系统: $(cat /etc/euleros-release)"
elif [[ -f "/etc/redhat-release" ]]; then
    echo "检测到 RedHat 兼容系统: $(cat /etc/redhat-release)"
else
    echo "警告: 未检测到 EulerOS 系统"
fi

# 检查配置文件
if [ ! -d "$SCRIPT_DIR/config" ]; then
    echo "警告: 找不到配置文件目录"
fi

echo "启动 AIAgent..."
"$EXECUTABLE"
