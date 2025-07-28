#!/bin/bash

# AIAgent 二进制打包脚本
# 使用方法: ./package.sh [选项]

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

# 获取版本信息
get_version() {
    # 从 git 标签获取版本，如果没有则使用日期
    if git describe --tags --abbrev=0 2>/dev/null; then
        echo $(git describe --tags --abbrev=0)
    else
        echo "v$(date +%Y.%m.%d)"
    fi
}

# 获取构建信息
get_build_info() {
    echo "Build: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
    echo "Platform: $(uname -s)-$(uname -m)"
    echo "Compiler: $(g++ --version | head -n1)"
}

# 创建发布包
create_package() {
    local version=$1
    local build_type=$2
    
    print_info "创建发布包: AIAgent-${version}-${build_type}"
    
    # 创建发布目录
    local package_dir="dist/AIAgent-${version}-${build_type}"
    mkdir -p "$package_dir"
    
    # 复制可执行文件
    if [ -f "main" ]; then
        cp main "$package_dir/AIAgent"
        chmod +x "$package_dir/AIAgent"
        print_success "复制可执行文件"
    else
        print_error "可执行文件不存在，请先编译"
        exit 1
    fi
    
    # 复制配置文件
    if [ -d "config" ]; then
        cp -r config "$package_dir/"
        print_success "复制配置文件"
    fi
    
    # 复制文档
    if [ -f "README.md" ]; then
        cp README.md "$package_dir/"
    fi
    
    # 创建安装脚本
    cat > "$package_dir/install.sh" << 'EOF'
#!/bin/bash
# AIAgent 安装脚本

set -e

echo "正在安装 AIAgent..."

# 检查目标目录
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
    sudo cp -r config/* "$CONFIG_DIR/"
fi

echo "安装完成！"
echo "可执行文件位置: $INSTALL_DIR/AIAgent"
echo "配置文件位置: $CONFIG_DIR"
echo ""
echo "使用方法:"
echo "  AIAgent"
echo ""
echo "注意: 请确保配置文件中的 API 密钥已正确设置"
EOF
    chmod +x "$package_dir/install.sh"
    
    # 创建卸载脚本
    cat > "$package_dir/uninstall.sh" << 'EOF'
#!/bin/bash
# AIAgent 卸载脚本

set -e

echo "正在卸载 AIAgent..."

INSTALL_DIR="${1:-/usr/local/bin}"
CONFIG_DIR="${2:-/usr/local/etc/AIAgent}"

# 删除可执行文件
if [ -f "$INSTALL_DIR/AIAgent" ]; then
    sudo rm -f "$INSTALL_DIR/AIAgent"
    echo "已删除可执行文件"
fi

# 删除配置文件
if [ -d "$CONFIG_DIR" ]; then
    sudo rm -rf "$CONFIG_DIR"
    echo "已删除配置文件"
fi

echo "卸载完成！"
EOF
    chmod +x "$package_dir/uninstall.sh"
    
    # 创建快速启动脚本
    cat > "$package_dir/run.sh" << 'EOF'
#!/bin/bash
# AIAgent 快速启动脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 检查可执行文件
if [ ! -f "./AIAgent" ]; then
    echo "错误: 找不到 AIAgent 可执行文件"
    exit 1
fi

# 检查配置文件
if [ ! -d "./config" ]; then
    echo "警告: 找不到配置文件目录"
    echo "请确保 config/ai_models.json 文件存在并包含有效的 API 密钥"
fi

# 运行程序
./AIAgent
EOF
    chmod +x "$package_dir/run.sh"
    
    # 创建版本信息文件
    cat > "$package_dir/VERSION" << EOF
AIAgent ${version}
$(get_build_info)
构建类型: ${build_type}
EOF
    
    # 创建压缩包
    local archive_name="AIAgent-${version}-${build_type}.tar.gz"
    tar -czf "$archive_name" -C dist "AIAgent-${version}-${build_type}"
    
    print_success "发布包创建完成: $archive_name"
    print_info "包大小: $(du -h "$archive_name" | cut -f1)"
    
    # 显示包内容
    print_info "包内容:"
    tar -tzf "$archive_name" | sed 's/^/  /'
}

# 编译静态版本
build_static() {
    print_info "编译静态链接版本..."
    
    # 清理之前的构建
    make clean
    
    # 编译静态版本
    if [ "$1" = "release" ]; then
        make release-static
    else
        make static
    fi
    
    # 检查编译结果
    if [ -f "main" ]; then
        print_success "编译成功"
        print_info "文件大小: $(du -h main | cut -f1)"
        print_info "文件类型: $(file main)"
    else
        print_error "编译失败"
        exit 1
    fi
}

# 显示帮助信息
show_help() {
    echo "AIAgent 二进制打包脚本"
    echo ""
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  build [type]     - 编译静态版本 (type: debug/release, 默认: release)"
    echo "  package [type]   - 创建发布包 (type: debug/release, 默认: release)"
    echo "  clean            - 清理构建文件"
    echo "  help             - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 build release    - 编译发布版本"
    echo "  $0 package release  - 创建发布包"
    echo "  $0 clean            - 清理构建文件"
}

# 主函数
main() {
    case ${1:-help} in
        build)
            local build_type=${2:-release}
            build_static "$build_type"
            ;;
        package)
            local build_type=${2:-release}
            build_static "$build_type"
            local version=$(get_version)
            create_package "$version" "$build_type"
            ;;
        clean)
            make clean
            rm -rf dist/
            print_success "清理完成"
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