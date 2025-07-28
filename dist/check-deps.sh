#!/bin/bash

# 检查系统依赖

echo "检查 AIAgent 运行依赖..."

# 检查基本库
LIBS=("libcurl.so.4" "libssl.so.3" "libcrypto.so.3" "libstdc++.so.6" "libc.so.6")

for lib in "${LIBS[@]}"; do
    if ldconfig -p | grep -q "$lib"; then
        echo "✓ $lib"
    else
        echo "✗ $lib (缺失)"
    fi
done

echo ""
echo "如果缺少依赖，请运行:"
echo "  Ubuntu/Debian: sudo apt-get install libcurl4 libssl3 libstdc++6"
echo "  CentOS/RHEL: sudo yum install libcurl openssl-libs libstdc++"
