#!/bin/bash

# AIAgent 构建脚本 (Linux)
# 使用方法: ./build.sh [选项]

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

# 检查依赖
check_dependencies() {
    print_info "检查依赖..."
    
    # 检查编译器
    if ! command -v g++ &> /dev/null; then
        print_error "找不到 g++ 编译器"
        print_info "请运行: sudo apt-get install g++"
        exit 1
    fi
    
    # 检查 make
    if ! command -v make &> /dev/null; then
        print_error "找不到 make"
        print_info "请运行: sudo apt-get install make"
        exit 1
    fi
    
    # 检查 curl 开发库
    if ! pkg-config --exists libcurl; then
        print_warning "找不到 libcurl 开发库"
        print_info "请运行: sudo apt-get install libcurl4-openssl-dev"
        exit 1
    fi
    
    # 检查 nlohmann/json
    if [ ! -f "third_party/json.hpp" ]; then
        print_error "找不到 nlohmann/json 库"
        print_info "正在下载..."
        mkdir -p third_party
        wget -O third_party/json.hpp https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp
    fi
    
    print_success "所有依赖检查通过！"
}

# 安装依赖
install_dependencies() {
    print_info "安装系统依赖..."
    sudo apt-get update
    sudo apt-get install -y g++ make libcurl4-openssl-dev pkg-config
    print_success "依赖安装完成！"
}

# 清理构建文件
clean() {
    print_info "清理构建文件..."
    make clean
    print_success "清理完成！"
}

# 编译项目
build() {
    local build_type=${1:-release}
    
    print_info "开始编译 ($build_type 版本)..."
    
    case $build_type in
        debug)
            make debug
            ;;
        release)
            make release
            ;;
        *)
            make
            ;;
    esac
    
    print_success "编译完成！"
}

# 运行程序
run() {
    if [ ! -f "./main" ]; then
        print_warning "可执行文件不存在，正在编译..."
        build
    fi
    
    print_info "运行程序..."
    ./main
}

# 显示帮助信息
show_help() {
    echo "AIAgent 构建脚本"
    echo ""
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  build [type]     - 编译项目 (type: debug/release, 默认: release)"
    echo "  clean            - 清理构建文件"
    echo "  run              - 编译并运行程序"
    echo "  check-deps       - 检查依赖"
    echo "  install-deps     - 安装系统依赖"
    echo "  help             - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 build debug   - 编译调试版本"
    echo "  $0 build release - 编译发布版本"
    echo "  $0 run           - 编译并运行"
}

# 主函数
main() {
    case ${1:-help} in
        build)
            check_dependencies
            build $2
            ;;
        clean)
            clean
            ;;
        run)
            check_dependencies
            run
            ;;
        check-deps)
            check_dependencies
            ;;
        install-deps)
            install_dependencies
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@" 