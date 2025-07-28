#!/bin/bash

# AIAgent 简化编译脚本
# 专门解决静态链接依赖问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
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

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
    else
        OS="unknown"
    fi
    print_info "检测到操作系统: $OS"
}

# 检查依赖
check_dependencies() {
    print_info "检查编译依赖..."
    
    # 检查编译器
    if ! command -v g++ &> /dev/null; then
        print_error "找不到 g++ 编译器，请安装 gcc/g++"
        exit 1
    fi
    print_success "编译器: g++ ✓"
    
    # 检查必要的头文件
    if [[ ! -f "third_party/json.hpp" ]]; then
        print_error "找不到 nlohmann/json 库文件"
        exit 1
    fi
    print_success "nlohmann/json 库: ✓"
    
    # 检查 curl 开发库
    if [[ "$OS" == "linux" ]]; then
        if ! pkg-config --exists libcurl; then
            print_warning "libcurl 开发库可能未安装，尝试继续编译..."
        else
            print_success "libcurl 开发库: ✓"
        fi
    fi
}

# 动态链接编译（推荐）
compile_dynamic() {
    local target_name="$1"
    
    print_info "编译动态链接版本（推荐）..."
    
    g++ -std=c++11 -Wall -Wextra -O2 -DNDEBUG \
        -Iinclude -Ithird_party \
        -o "$target_name" \
        main.cpp \
        src/agent1_input/agent1_input.cpp \
        src/agent2_diagnose/agent2_diagnose.cpp \
        src/agent3_strategy/agent3_strategy.cpp \
        src/agent4_report/agent4_report.cpp \
        src/agent5_interactive/agent5_interactive.cpp \
        src/ai_engine/ai_engine.cpp \
        src/utils/utils.cpp \
        -lcurl -lssl -lcrypto -lz -ldl -lpthread
    
    if [[ $? -eq 0 ]]; then
        print_success "动态链接编译成功！"
        return 0
    fi
    return 1
}

# 尝试静态链接编译（仅基本功能）
compile_static_basic() {
    local target_name="$1"
    
    print_info "尝试静态链接编译（仅基本功能）..."
    
    # 使用更简单的静态链接选项
    g++ -std=c++11 -Wall -Wextra -O2 -DNDEBUG -static \
        -Iinclude -Ithird_party \
        -o "$target_name" \
        main.cpp \
        src/agent1_input/agent1_input.cpp \
        src/agent2_diagnose/agent2_diagnose.cpp \
        src/agent3_strategy/agent3_strategy.cpp \
        src/agent4_report/agent4_report.cpp \
        src/agent5_interactive/agent5_interactive.cpp \
        src/ai_engine/ai_engine.cpp \
        src/utils/utils.cpp \
        -lcurl -lssl -lcrypto -lz -ldl -lpthread 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        print_success "静态链接编译成功！"
        return 0
    fi
    return 1
}

# 编译函数
compile() {
    local build_type="$1"
    local target_name="$2"
    
    case $build_type in
        "dynamic")
            compile_dynamic "$target_name"
            ;;
        "static")
            compile_static_basic "$target_name"
            ;;
        "auto")
            # 先尝试静态链接，失败则使用动态链接
            if compile_static_basic "$target_name"; then
                print_info "静态链接成功！"
            else
                print_warning "静态链接失败，使用动态链接..."
                compile_dynamic "$target_name"
            fi
            ;;
        *)
            print_error "未知的编译类型: $build_type"
            exit 1
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        print_success "编译成功！可执行文件: $target_name"
        
        # 显示文件信息
        if [[ -f "$target_name" ]]; then
            local file_size=$(du -h "$target_name" | cut -f1)
            print_info "文件大小: $file_size"
            
            if [[ "$build_type" == "static" ]]; then
                print_info "这是一个静态链接的可执行文件，可以在其他Linux系统上运行"
            else
                print_info "这是一个动态链接的可执行文件，需要目标系统安装相应的库"
            fi
        fi
    else
        print_error "编译失败！"
        exit 1
    fi
}

# 创建发布包
create_package() {
    local build_type="$1"
    local package_name="$2"
    
    print_info "创建发布包: $package_name"
    
    # 编译
    compile "$build_type" "main"
    
    # 创建目录
    mkdir -p "dist/$package_name"
    
    # 复制文件
    cp main "dist/$package_name/AIAgent"
    cp -r config "dist/$package_name/"
    cp README.md "dist/$package_name/"
    if [[ -f "LICENSE" ]]; then
        cp LICENSE "dist/$package_name/"
    fi
    
    print_success "发布包创建完成: dist/$package_name/"
}

# 显示帮助信息
show_help() {
    echo "AIAgent 简化编译脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  dynamic          - 编译动态链接版本（推荐用于开发）"
    echo "  static           - 编译静态链接版本（仅基本功能）"
    echo "  auto             - 自动选择最佳编译方式（推荐）"
    echo "  package-linux    - 创建Linux发布包"
    echo "  clean            - 清理编译文件"
    echo "  help             - 显示此帮助信息"
    echo ""
    echo "推荐用法:"
    echo "  Linux开发:   $0 dynamic"
    echo "  Linux发布:   $0 auto"
    echo "  Windows:     $0 dynamic"
    echo ""
}

# 清理函数
clean() {
    print_info "清理编译文件..."
    rm -f main main.exe *.o src/*/*.o
    print_success "清理完成！"
}

# 主函数
main() {
    detect_os
    check_dependencies
    
    case "${1:-help}" in
        "dynamic")
            compile "dynamic" "main"
            ;;
        "static")
            compile "static" "main"
            ;;
        "auto")
            compile "auto" "main"
            ;;
        "package-linux")
            create_package "auto" "AIAgent-linux"
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