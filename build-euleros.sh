#!/bin/bash

# AIAgent EulerOS 专用编译脚本
# 针对 EulerOS release 2.0 优化

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

# 检测 EulerOS 系统
detect_euleros() {
    if [[ -f "/etc/euleros-release" ]]; then
        EULEROS_VERSION=$(cat /etc/euleros-release)
        print_info "检测到 EulerOS: $EULEROS_VERSION"
        return 0
    elif [[ -f "/etc/redhat-release" ]] && grep -q "EulerOS" /etc/redhat-release; then
        EULEROS_VERSION=$(cat /etc/redhat-release)
        print_info "检测到 EulerOS: $EULEROS_VERSION"
        return 0
    else
        print_warning "未检测到 EulerOS 系统，但将继续编译（用于交叉编译）"
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
    
    # 检查 curl 开发库
    if ! pkg-config --exists libcurl 2>/dev/null; then
        print_warning "libcurl 开发库可能未安装"
        print_info "EulerOS 安装命令: sudo yum install libcurl-devel"
    fi
    
    # 检查 OpenSSL 开发库
    if ! pkg-config --exists openssl 2>/dev/null; then
        print_warning "OpenSSL 开发库可能未安装"
        print_info "EulerOS 安装命令: sudo yum install openssl-devel"
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

# EulerOS 优化编译
compile_for_euleros() {
    local target_name="$1"
    local build_type="$2"
    
    print_info "为 EulerOS 编译 $build_type 版本..."
    
    # EulerOS 特定的编译选项
    local euleros_flags=""
    
    # 检测 CPU 架构
    local arch=$(uname -m)
    if [[ "$arch" == "x86_64" ]]; then
        euleros_flags="-march=x86-64 -mtune=generic"
    elif [[ "$arch" == "aarch64" ]]; then
        euleros_flags="-march=armv8-a"
    fi
    
    # 编译选项
    local cxxflags="-std=c++11 -Wall -Wextra -O2 -DNDEBUG $euleros_flags"
    local includes="-Iinclude -Ithird_party"
    local libs="-lcurl -lssl -lcrypto -lz -ldl -lpthread"
    
    # 编译
    g++ $cxxflags $includes \
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
        print_success "EulerOS 编译成功！"
        return 0
    else
        print_error "EulerOS 编译失败！"
        return 1
    fi
}

# 创建 EulerOS 专用包
create_euleros_package() {
    local version="$1"
    local build_type="$2"
    
    print_info "创建 EulerOS 专用包: AIAgent-euleros-${version}"
    
    # 编译
    if ! compile_for_euleros "AIAgent" "$build_type"; then
        exit 1
    fi
    
    # 创建发布目录
    local package_dir="dist/AIAgent-euleros-${version}"
    mkdir -p "$package_dir"
    
    # 复制文件
    cp AIAgent "$package_dir/"
    chmod +x "$package_dir/AIAgent"
    
    if [ -d "config" ]; then
        cp -r config "$package_dir/"
    fi
    
    # 创建 EulerOS 专用安装脚本
    cat > "$package_dir/install-euleros.sh" << 'EOF'
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
EOF
    
    chmod +x "$package_dir/install-euleros.sh"
    
    # 创建 EulerOS 依赖检查脚本
    cat > "$package_dir/check-euleros-deps.sh" << 'EOF'
#!/bin/bash

# EulerOS 依赖检查脚本

echo "检查 EulerOS 系统依赖..."

# 检查系统信息
if [[ -f "/etc/euleros-release" ]]; then
    echo "✓ EulerOS 系统: $(cat /etc/euleros-release)"
elif [[ -f "/etc/redhat-release" ]]; then
    echo "✓ RedHat 兼容系统: $(cat /etc/redhat-release)"
else
    echo "✗ 未检测到 EulerOS 或 RedHat 兼容系统"
fi

# 检查基本库
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
echo "EulerOS 特定命令:"
echo "  sudo yum install libcurl-devel openssl-devel"
EOF
    
    chmod +x "$package_dir/check-euleros-deps.sh"
    
    # 创建 EulerOS 运行脚本
    cat > "$package_dir/run-euleros.sh" << 'EOF'
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
EOF
    
    chmod +x "$package_dir/run-euleros.sh"
    
    # 创建 EulerOS 专用 README
    cat > "$package_dir/README-EulerOS.txt" << EOF
AIAgent - EulerOS 专用版本

这是专门为 EulerOS release 2.0 优化的版本。

系统要求:
- EulerOS release 2.0 或更高版本
- x86_64 或 aarch64 架构
- 基本的 C++ 运行时库

安装方法:
1. 检查依赖: ./check-euleros-deps.sh
2. 安装到系统: sudo ./install-euleros.sh
3. 运行程序: AIAgent

或者直接运行:
./run-euleros.sh

EulerOS 特定说明:
- 使用 yum 包管理器
- 支持 systemd 服务管理
- 针对国产化环境优化

版本信息:
$(date '+%Y-%m-%d %H:%M:%S')
编译目标: EulerOS release 2.0
EOF
    
    print_success "EulerOS 专用包创建完成: $package_dir"
}

# 创建 EulerOS 压缩包
create_euleros_archive() {
    local version="$1"
    local build_type="$2"
    
    print_info "创建 EulerOS 压缩包..."
    
    # 创建包
    create_euleros_package "$version" "$build_type"
    
    # 创建压缩包
    cd dist
    tar -czf "AIAgent-euleros-${version}.tar.gz" "AIAgent-euleros-${version}"
    cd ..
    
    print_success "EulerOS 压缩包创建完成: dist/AIAgent-euleros-${version}.tar.gz"
}

# 显示帮助
show_help() {
    echo "AIAgent EulerOS 专用编译脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  build [type]     - 编译 EulerOS 版本 (type: debug/release, 默认: release)"
    echo "  package [type]   - 创建 EulerOS 专用包 (type: debug/release, 默认: release)"
    echo "  archive [type]   - 创建 EulerOS 压缩包 (type: debug/release, 默认: release)"
    echo "  install-deps     - 安装 EulerOS 系统依赖"
    echo "  check-deps       - 检查 EulerOS 系统依赖"
    echo "  clean            - 清理构建文件"
    echo "  help             - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 build release    - 编译 EulerOS 发布版本"
    echo "  $0 package release  - 创建 EulerOS 专用包"
    echo "  $0 archive release  - 创建 EulerOS 压缩包"
    echo "  $0 install-deps     - 安装 EulerOS 依赖"
}

# 清理函数
clean() {
    print_info "清理构建文件..."
    rm -f AIAgent
    rm -rf dist/AIAgent-euleros-*
    print_success "清理完成！"
}

# 主函数
main() {
    detect_euleros
    
    case "${1:-help}" in
        "build")
            check_euleros_deps
            compile_for_euleros "AIAgent" "${2:-release}"
            ;;
        "package")
            check_euleros_deps
            create_euleros_package "$(date +%Y.%m.%d)" "${2:-release}"
            ;;
        "archive")
            check_euleros_deps
            create_euleros_archive "$(date +%Y.%m.%d)" "${2:-release}"
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