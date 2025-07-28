#!/bin/bash

# AIAgent EulerOS 兼容性编译脚本
# 专门解决 EulerOS release 2.0 (SP5) 的库版本兼容性问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检测 EulerOS 版本
detect_euleros_version() {
    if [[ -f "/etc/euleros-release" ]]; then
        EULEROS_VERSION=$(cat /etc/euleros-release)
        print_info "检测到 EulerOS: $EULEROS_VERSION"
        
        # 提取版本信息
        if echo "$EULEROS_VERSION" | grep -q "SP5"; then
            EULEROS_SP="SP5"
            print_info "检测到 EulerOS SP5，使用兼容性编译选项"
        elif echo "$EULEROS_VERSION" | grep -q "SP4"; then
            EULEROS_SP="SP4"
            print_info "检测到 EulerOS SP4，使用兼容性编译选项"
        else
            EULEROS_SP="base"
            print_info "检测到 EulerOS 基础版本，使用兼容性编译选项"
        fi
        
        return 0
    elif [[ -f "/etc/redhat-release" ]] && grep -q "EulerOS" /etc/redhat-release; then
        EULEROS_VERSION=$(cat /etc/redhat-release)
        print_info "检测到 EulerOS: $EULEROS_VERSION"
        return 0
    else
        print_warning "未检测到 EulerOS 系统，但将继续编译"
        return 0
    fi
}

# 检查 EulerOS 依赖
check_euleros_deps() {
    print_info "检查 EulerOS 系统依赖..."
    
    # 检查编译器
    if ! command -v g++ &> /dev/null; then
        print_error "找不到 g++ 编译器"
        print_info "EulerOS 安装命令: sudo yum install gcc-c++"
        exit 1
    fi
    
    # 检查 make
    if ! command -v make &> /dev/null; then
        print_error "找不到 make"
        print_info "EulerOS 安装命令: sudo yum install make"
        exit 1
    fi
    
    # 检查 nlohmann/json
    if [ ! -f "third_party/json.hpp" ]; then
        print_error "找不到 nlohmann/json 库"
        exit 1
    fi
    
    print_success "EulerOS 依赖检查完成！"
}

# 安装 EulerOS 依赖
install_euleros_deps() {
    print_info "安装 EulerOS 系统依赖..."
    
    # 更新包管理器
    sudo yum update -y
    
    # 安装编译工具
    sudo yum groupinstall -y "Development Tools"
    
    # 安装必要的开发库
    sudo yum install -y \
        gcc-c++ \
        make \
        libcurl-devel \
        openssl-devel \
        pkg-config \
        wget
    
    print_success "EulerOS 依赖安装完成！"
}

# EulerOS 兼容性编译
compile_for_euleros_compatible() {
    local target_name="$1"
    local build_type="$2"
    
    print_info "为 EulerOS SP5 编译兼容性版本..."
    
    # EulerOS SP5 兼容性编译选项
    local euleros_flags=""
    
    # 检测 CPU 架构
    local arch=$(uname -m)
    if [[ "$arch" == "x86_64" ]]; then
        euleros_flags="-march=x86-64 -mtune=generic"
    elif [[ "$arch" == "aarch64" ]]; then
        euleros_flags="-march=armv8-a"
    fi
    
    # 兼容性编译选项 - 针对 EulerOS SP5 的旧版本库
    local cxxflags="-std=c++11 -Wall -Wextra -O2 -DNDEBUG $euleros_flags"
    local includes="-Iinclude -Ithird_party"
    
    # 使用静态链接标准库以避免版本冲突
    local libs="-lcurl -lssl -lcrypto -lz -ldl -lpthread"
    
    # 添加兼容性标志
    local compat_flags="-static-libgcc -static-libstdc++"
    
    print_info "使用兼容性编译选项..."
    print_info "编译选项: $cxxflags"
    print_info "兼容性标志: $compat_flags"
    
    # 编译
    g++ $cxxflags $compat_flags $includes \
        -o "$target_name" \
        main.cpp \
        src/agent1_input/agent1_input.cpp \
        src/agent2_diagnose/agent2_diagnose.cpp \
        src/agent3_strategy/agent3_strategy.cpp \
        src/agent4_report/agent4_report.cpp \
        src/agent5_interactive/agent5_interactive.cpp \
        src/ai_engine/ai_engine.cpp \
        src/utils/utils.cpp \
        $libs
    
    if [ $? -eq 0 ]; then
        print_success "EulerOS 兼容性编译成功！"
        return 0
    else
        print_error "EulerOS 兼容性编译失败！"
        return 1
    fi
}

# 创建 EulerOS 兼容性包
create_euleros_compatible_package() {
    local version="$1"
    local build_type="$2"
    
    print_info "创建 EulerOS SP5 兼容性包: AIAgent-euleros-sp5-${version}"
    
    # 编译
    if ! compile_for_euleros_compatible "AIAgent" "$build_type"; then
        exit 1
    fi
    
    # 创建发布目录
    local package_dir="dist/AIAgent-euleros-sp5-${version}"
    mkdir -p "$package_dir"
    
    # 复制文件
    cp AIAgent "$package_dir/"
    chmod +x "$package_dir/AIAgent"
    
    if [ -d "config" ]; then
        cp -r config "$package_dir/"
    fi
    
    # 创建 EulerOS SP5 专用安装脚本
    cat > "$package_dir/install-euleros-sp5.sh" << 'EOF'
#!/bin/bash

# AIAgent EulerOS SP5 专用安装脚本

set -e

echo "正在为 EulerOS SP5 安装 AIAgent..."

# 默认安装路径
INSTALL_DIR="${1:-/usr/local/bin}"
CONFIG_DIR="${2:-/usr/local/etc/AIAgent}"

# 检查是否为 EulerOS SP5
if [[ -f "/etc/euleros-release" ]] && grep -q "SP5" /etc/euleros-release; then
    echo "✓ 检测到 EulerOS SP5 系统"
else
    echo "⚠ 警告: 未检测到 EulerOS SP5 系统"
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
EOF
    
    chmod +x "$package_dir/install-euleros-sp5.sh"
    
    # 创建 EulerOS SP5 依赖检查脚本
    cat > "$package_dir/check-euleros-sp5-deps.sh" << 'EOF'
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
EOF
    
    chmod +x "$package_dir/check-euleros-sp5-deps.sh"
    
    # 创建 EulerOS SP5 运行脚本
    cat > "$package_dir/run-euleros-sp5.sh" << 'EOF'
#!/bin/bash

# EulerOS SP5 专用运行脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXECUTABLE="$SCRIPT_DIR/AIAgent"

# 检查可执行文件
if [ ! -f "$EXECUTABLE" ]; then
    echo "错误: 找不到可执行文件 $EXECUTABLE"
    exit 1
fi

# 检查 EulerOS SP5 环境
if [[ -f "/etc/euleros-release" ]]; then
    echo "检测到 EulerOS 系统: $(cat /etc/euleros-release)"
    if grep -q "SP5" /etc/euleros-release; then
        echo "✓ 检测到 EulerOS SP5，使用兼容性版本"
    else
        echo "⚠ 警告: 未检测到 EulerOS SP5"
    fi
elif [[ -f "/etc/redhat-release" ]]; then
    echo "检测到 RedHat 兼容系统: $(cat /etc/redhat-release)"
else
    echo "警告: 未检测到 EulerOS 系统"
fi

# 检查配置文件
if [ ! -d "$SCRIPT_DIR/config" ]; then
    echo "警告: 找不到配置文件目录"
fi

echo "启动 AIAgent (EulerOS SP5 兼容版本)..."
"$EXECUTABLE"
EOF
    
    chmod +x "$package_dir/run-euleros-sp5.sh"
    
    # 创建 EulerOS SP5 专用 README
    cat > "$package_dir/README-EulerOS-SP5.txt" << EOF
AIAgent - EulerOS SP5 兼容版本

这是专门为 EulerOS release 2.0 (SP5) 优化的兼容性版本。

系统要求:
- EulerOS release 2.0 (SP5) 或更高版本
- x86_64 或 aarch64 架构
- 基本的 C++ 运行时库

兼容性特性:
- 针对 EulerOS SP5 的旧版本 glibc 优化
- 使用静态链接标准库避免版本冲突
- 兼容 EulerOS SP5 的库版本

安装方法:
1. 检查依赖: ./check-euleros-sp5-deps.sh
2. 安装到系统: sudo ./install-euleros-sp5.sh
3. 运行程序: AIAgent

或者直接运行:
./run-euleros-sp5.sh

EulerOS SP5 特定说明:
- 使用 yum 包管理器
- 支持 systemd 服务管理
- 针对 SP5 的库版本兼容性优化
- 使用静态链接避免 glibc 版本冲突

版本信息:
$(date '+%Y-%m-%d %H:%M:%S')
编译目标: EulerOS release 2.0 (SP5)
兼容性: glibc 2.17+, libstdc++ 4.8+
EOF
    
    print_success "EulerOS SP5 兼容性包创建完成: $package_dir"
}

# 创建 EulerOS SP5 压缩包
create_euleros_sp5_archive() {
    local version="$1"
    local build_type="$2"
    
    print_info "创建 EulerOS SP5 兼容性压缩包..."
    
    # 创建包
    create_euleros_compatible_package "$version" "$build_type"
    
    # 创建压缩包
    cd dist
    tar -czf "AIAgent-euleros-sp5-${version}.tar.gz" "AIAgent-euleros-sp5-${version}"
    cd ..
    
    print_success "EulerOS SP5 兼容性压缩包创建完成: dist/AIAgent-euleros-sp5-${version}.tar.gz"
}

# 显示帮助
show_help() {
    echo "AIAgent EulerOS SP5 兼容性编译脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  build [type]     - 编译 EulerOS SP5 兼容版本 (type: debug/release, 默认: release)"
    echo "  package [type]   - 创建 EulerOS SP5 兼容包 (type: debug/release, 默认: release)"
    echo "  archive [type]   - 创建 EulerOS SP5 兼容压缩包 (type: debug/release, 默认: release)"
    echo "  install-deps     - 安装 EulerOS 系统依赖"
    echo "  check-deps       - 检查 EulerOS 系统依赖"
    echo "  clean            - 清理构建文件"
    echo "  help             - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 build release    - 编译 EulerOS SP5 兼容版本"
    echo "  $0 package release  - 创建 EulerOS SP5 兼容包"
    echo "  $0 archive release  - 创建 EulerOS SP5 兼容压缩包"
    echo "  $0 install-deps     - 安装 EulerOS 依赖"
}

# 清理函数
clean() {
    print_info "清理构建文件..."
    rm -f AIAgent
    rm -rf dist/AIAgent-euleros-sp5-*
    print_success "清理完成！"
}

# 主函数
main() {
    detect_euleros_version
    
    case "${1:-help}" in
        "build")
            check_euleros_deps
            compile_for_euleros_compatible "AIAgent" "${2:-release}"
            ;;
        "package")
            check_euleros_deps
            create_euleros_compatible_package "$(date +%Y.%m.%d)" "${2:-release}"
            ;;
        "archive")
            check_euleros_deps
            create_euleros_sp5_archive "$(date +%Y.%m.%d)" "${2:-release}"
            ;;
        "install-deps")
            install_euleros_deps
            ;;
        "check-deps")
            check_euleros_deps
            ;;
        "clean")
            clean
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 执行主函数
main "$@" 