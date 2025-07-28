#!/bin/bash

# EulerOS SP5 依赖检查脚本

echo "检查 EulerOS SP5 系统依赖..."

# 检查系统信息
if [[ -f "/etc/euleros-release" ]]; then
    echo "✓ EulerOS 系统: $(cat /etc/euleros-release)"
    if grep -q "SP5" /etc/euleros-release; then
        echo "✓ 检测到 EulerOS SP5"
    else
        echo "⚠ 未检测到 EulerOS SP5"
    fi
elif [[ -f "/etc/redhat-release" ]]; then
    echo "✓ RedHat 兼容系统: $(cat /etc/redhat-release)"
else
    echo "✗ 未检测到 EulerOS 或 RedHat 兼容系统"
fi

# 检查 glibc 版本
echo ""
echo "检查 glibc 版本:"
ldd --version | head -n1

# 检查 libstdc++ 版本
echo ""
echo "检查 libstdc++ 版本:"
strings /lib64/libstdc++.so.6 | grep GLIBCXX | tail -5

# 检查基本库
echo ""
echo "检查基本库:"
LIBS=("libcurl.so.4" "libssl.so.10" "libcrypto.so.10" "libstdc++.so.6" "libc.so.6")

for lib in "${LIBS[@]}"; do
    if ldconfig -p | grep -q "$lib"; then
        echo "✓ $lib"
    else
        echo "✗ $lib (缺失)"
    fi
done

echo ""
echo "如果缺少依赖，请运行:"
echo "  sudo yum update"
echo "  sudo yum install libcurl openssl-libs libstdc++"
echo ""
echo "EulerOS SP5 特定命令:"
echo "  sudo yum install libcurl-devel openssl-devel"
echo ""
echo "注意: 此版本针对 EulerOS SP5 进行了兼容性优化"
