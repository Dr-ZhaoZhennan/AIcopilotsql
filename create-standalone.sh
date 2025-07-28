 #!/bin/bash

# AIAgent 独立可执行文件创建脚本
# 创建一个包含所有依赖的独立可执行文件

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

# 检查依赖
check_dependencies() {
    print_info "检查编译依赖..."
    
    if ! command -v g++ &> /dev/null; then
        print_error "找不到 g++ 编译器"
        exit 1
    fi
    
    if ! command -v make &> /dev/null; then
        print_error "找不到 make"
        exit 1
    fi
    
    if [ ! -f "third_party/json.hpp" ]; then
        print_error "找不到 nlohmann/json 库"
        exit 1
    fi
    
    print_success "所有依赖检查通过！"
}

# 编译动态版本
compile_dynamic() {
    print_info "编译动态链接版本..."
    
    g++ -std=c++11 -Wall -Wextra -O2 -DNDEBUG \
        -Iinclude -Ithird_party \
        -o main \
        main.cpp \
        src/agent1_input/agent1_input.cpp \
        src/agent2_diagnose/agent2_diagnose.cpp \
        src/agent3_strategy/agent3_strategy.cpp \
        src/agent4_report/agent4_report.cpp \
        src/agent5_interactive/agent5_interactive.cpp \
        src/ai_engine/ai_engine.cpp \
        src/utils/utils.cpp \
        -lcurl -lssl -lcrypto -lz -ldl -lpthread
    
    if [ $? -eq 0 ]; then
        print_success "编译成功！"
        return 0
    else
        print_error "编译失败！"
        return 1
    fi
}

# 创建独立可执行文件
create_standalone() {
    local output_name="$1"
    
    print_info "创建独立可执行文件: $output_name"
    
    # 编译
    if ! compile_dynamic; then
        exit 1
    fi
    
    # 创建输出目录
    mkdir -p dist
    
    # 复制可执行文件
    cp main "dist/$output_name"
    chmod +x "dist/$output_name"
    
    # 复制配置文件
    if [ -d "config" ]; then
        cp -r config "dist/"
    fi
    
    # 复制文档
    if [ -f "README.md" ]; then
        cp README.md "dist/"
    fi
    
    # 创建运行脚本
    cat > "dist/run.sh" << 'EOF'
#!/bin/bash

# AIAgent 运行脚本
# 自动处理依赖和环境设置

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXECUTABLE="$SCRIPT_DIR/AIAgent"

# 检查可执行文件
if [ ! -f "$EXECUTABLE" ]; then
    echo "错误: 找不到可执行文件 $EXECUTABLE"
    exit 1
fi

# 检查配置文件
if [ ! -d "$SCRIPT_DIR/config" ]; then
    echo "警告: 找不到配置文件目录"
fi

# 运行程序
echo "启动 AIAgent..."
"$EXECUTABLE"
EOF
    
    chmod +x "dist/run.sh"
    
    # 创建安装脚本
    cat > "dist/install.sh" << 'EOF'
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
EOF
    
    chmod +x "dist/install.sh"
    
    # 创建依赖检查脚本
    cat > "dist/check-deps.sh" << 'EOF'
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
EOF
    
    chmod +x "dist/check-deps.sh"
    
    # 创建 README
    cat > "dist/README.txt" << EOF
AIAgent - 智能 SQL 优化助手

这是一个独立的可执行文件，包含以下组件：

1. AIAgent - 主程序
2. config/ - 配置文件目录
3. run.sh - 运行脚本
4. install.sh - 安装脚本
5. check-deps.sh - 依赖检查脚本

使用方法：

1. 直接运行：
   ./AIAgent

2. 使用运行脚本：
   ./run.sh

3. 安装到系统：
   sudo ./install.sh

4. 检查依赖：
   ./check-deps.sh

注意事项：
- 确保系统已安装必要的库文件
- 首次运行前建议先运行 check-deps.sh
- 配置文件位于 config/ 目录中

版本信息：
$(date '+%Y-%m-%d %H:%M:%S')
EOF
    
    print_success "独立可执行文件创建完成！"
    print_info "输出目录: dist/"
    print_info "文件大小: $(du -h "dist/$output_name" | cut -f1)"
    
    # 显示依赖信息
    print_info "依赖库信息:"
    ldd "dist/$output_name" | head -10
}

# 创建便携式包
create_portable_package() {
    local package_name="$1"
    
    print_info "创建便携式包: $package_name"
    
    # 创建独立可执行文件
    create_standalone "AIAgent"
    
    # 创建压缩包
    cd dist
    tar -czf "../$package_name.tar.gz" *
    cd ..
    
    print_success "便携式包创建完成: $package_name.tar.gz"
    print_info "文件大小: $(du -h "$package_name.tar.gz" | cut -f1)"
}

# 显示帮助
show_help() {
    echo "AIAgent 独立可执行文件创建脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  build [name]     - 创建独立可执行文件 (默认名称: AIAgent)"
    echo "  package [name]   - 创建便携式包 (默认名称: AIAgent-portable)"
    echo "  clean            - 清理构建文件"
    echo "  help             - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 build                    - 创建 AIAgent 可执行文件"
    echo "  $0 build myapp             - 创建名为 myapp 的可执行文件"
    echo "  $0 package                 - 创建便携式包"
    echo "  $0 package myapp-portable - 创建名为 myapp-portable 的便携式包"
}

# 清理函数
clean() {
    print_info "清理构建文件..."
    rm -f main
    rm -rf dist
    print_success "清理完成！"
}

# 主函数
main() {
    case "${1:-help}" in
        "build")
            check_dependencies
            create_standalone "${2:-AIAgent}"
            ;;
        "package")
            check_dependencies
            create_portable_package "${2:-AIAgent-portable}"
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