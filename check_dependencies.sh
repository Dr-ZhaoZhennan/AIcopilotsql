#!/bin/bash

# 依赖检查和安装脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查操作系统
check_os() {
    log_info "检查操作系统..."
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
        log_success "操作系统: $OS $VER"
    else
        log_warning "无法确定操作系统版本"
        OS="Unknown"
    fi
}

# 检查系统架构
check_architecture() {
    log_info "检查系统架构..."
    
    ARCH=$(uname -m)
    log_success "系统架构: $ARCH"
    
    if [[ "$ARCH" != "x86_64" ]]; then
        log_warning "当前架构为 $ARCH，可能不支持某些功能"
    fi
}

# 检查基本依赖
check_basic_deps() {
    log_info "检查基本依赖..."
    
    # 检查g++
    if command -v g++ &> /dev/null; then
        log_success "g++ 编译器已安装"
    else
        log_error "g++ 编译器未安装"
        return 1
    fi
    
    # 检查make
    if command -v make &> /dev/null; then
        log_success "make 工具已安装"
    else
        log_error "make 工具未安装"
        return 1
    fi
    
    # 检查curl
    if command -v curl &> /dev/null; then
        log_success "curl 工具已安装"
    else
        log_error "curl 工具未安装"
        return 1
    fi
    
    return 0
}

# 检查nlohmann/json库
check_json_library() {
    log_info "检查nlohmann/json库..."
    
    # 检查系统安装的json库
    if [[ -f "/usr/include/nlohmann/json.hpp" ]] || [[ -f "/usr/local/include/nlohmann/json.hpp" ]]; then
        log_success "nlohmann/json库已安装"
        return 0
    fi
    
    # 检查项目内的json库
    if [[ -f "./include/nlohmann/json.hpp" ]]; then
        log_success "项目内包含nlohmann/json库"
        return 0
    fi
    
    log_warning "未找到nlohmann/json库"
    return 1
}

# 安装依赖（Ubuntu/Debian）
install_deps_ubuntu() {
    log_info "在Ubuntu/Debian系统上安装依赖..."
    
    sudo apt-get update
    sudo apt-get install -y build-essential curl nlohmann-json3-dev
    
    log_success "依赖安装完成"
}

# 安装依赖（CentOS/RHEL）
install_deps_centos() {
    log_info "在CentOS/RHEL系统上安装依赖..."
    
    sudo yum groupinstall -y "Development Tools"
    sudo yum install -y curl
    
    # 安装nlohmann/json
    if ! rpm -q nlohmann-json-devel &> /dev/null; then
        log_warning "需要手动安装nlohmann/json库"
        log_info "请运行: sudo yum install nlohmann-json-devel"
    fi
    
    log_success "依赖安装完成"
}

# 检查项目文件
check_project_files() {
    log_info "检查项目文件..."
    
    local missing_files=()
    
    # 检查必要文件
    [[ -f "main.cpp" ]] || missing_files+=("main.cpp")
    [[ -f "Makefile" ]] || missing_files+=("Makefile")
    [[ -f "config/ai_models.json" ]] || missing_files+=("config/ai_models.json")
    [[ -d "src" ]] || missing_files+=("src目录")
    [[ -d "include" ]] || missing_files+=("include目录")
    
    # 检查Ollama相关文件
    [[ -f "ollama_bin/ollama" ]] || missing_files+=("ollama_bin/ollama")
    [[ -d "models" ]] || missing_files+=("models目录")
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        log_success "所有项目文件完整"
        return 0
    else
        log_error "缺少以下文件:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        return 1
    fi
}

# 检查网络连接
check_network() {
    log_info "检查网络连接..."
    
    if curl -s --connect-timeout 10 https://api.deepseek.com > /dev/null; then
        log_success "网络连接正常"
        return 0
    else
        log_warning "网络连接可能有问题，API模型可能无法使用"
        return 1
    fi
}

# 测试编译
test_compilation() {
    log_info "测试项目编译..."
    
    if make clean && make; then
        log_success "项目编译成功"
        return 0
    else
        log_error "项目编译失败"
        return 1
    fi
}

# 测试Ollama服务
test_ollama() {
    log_info "测试Ollama服务..."
    
    # 设置环境变量
    export PATH="./ollama_bin:$PATH"
    export OLLAMA_MODELS="$(pwd)/models"
    
    # 检查Ollama可执行文件
    if [[ ! -f "./ollama_bin/ollama" ]]; then
        log_error "Ollama可执行文件不存在"
        return 1
    fi
    
    # 启动Ollama服务
    if pgrep -f "ollama serve" > /dev/null; then
        log_success "Ollama服务已在运行"
    else
        log_info "启动Ollama服务..."
        nohup ./ollama_bin/ollama serve > ollama.log 2>&1 &
        sleep 3
        
        if pgrep -f "ollama serve" > /dev/null; then
            log_success "Ollama服务启动成功"
        else
            log_error "Ollama服务启动失败"
            return 1
        fi
    fi
    
    # 检查模型
    if ./ollama_bin/ollama list 2>/dev/null | grep -q .; then
        log_success "发现可用模型"
        return 0
    else
        log_warning "未找到可用模型，但程序仍可运行（使用API模型）"
        return 0
    fi
}

# 生成部署报告
generate_report() {
    local report_file="deployment_report.txt"
    
    log_info "生成部署报告: $report_file"
    
    cat > "$report_file" << EOF
GaussDB SQL优化Copilot - 部署检查报告
生成时间: $(date)

=== 系统信息 ===
操作系统: $OS
架构: $(uname -m)
内核版本: $(uname -r)

=== 依赖检查 ===
$(check_basic_deps 2>&1 | grep -E "\[SUCCESS\]|\[ERROR\]|\[WARNING\]")
$(check_json_library 2>&1 | grep -E "\[SUCCESS\]|\[ERROR\]|\[WARNING\]")

=== 项目文件 ===
$(check_project_files 2>&1 | grep -E "\[SUCCESS\]|\[ERROR\]|\[WARNING\]")

=== 网络连接 ===
$(check_network 2>&1 | grep -E "\[SUCCESS\]|\[ERROR\]|\[WARNING\]")

=== 编译测试 ===
$(test_compilation 2>&1 | grep -E "\[SUCCESS\]|\[ERROR\]|\[WARNING\]")

=== Ollama服务 ===
$(test_ollama 2>&1 | grep -E "\[SUCCESS\]|\[ERROR\]|\[WARNING\]")

=== 部署建议 ===
1. 如果所有检查都通过，项目可以正常运行
2. 如果有错误，请根据错误信息安装相应依赖
3. 如果网络连接有问题，只能使用本地模型
4. 如果Ollama服务有问题，只能使用API模型

=== 使用方法 ===
1. 运行启动脚本: ./start_sql_optimizer.sh
2. 或者手动编译: make && ./main
3. 使用管理脚本: ./manage_ollama.sh help

EOF

    log_success "部署报告已生成: $report_file"
}

# 主函数
main() {
    echo "=== GaussDB SQL优化Copilot - 依赖检查 ==="
    echo "开始时间: $(date)"
    echo
    
    local all_passed=true
    
    # 检查操作系统
    check_os
    
    # 检查系统架构
    check_architecture
    
    # 检查基本依赖
    if ! check_basic_deps; then
        log_error "基本依赖检查失败"
        all_passed=false
        
        # 尝试自动安装
        if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
            log_info "尝试自动安装依赖..."
            install_deps_ubuntu
        elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
            log_info "尝试自动安装依赖..."
            install_deps_centos
        else
            log_error "请手动安装依赖: build-essential, curl, nlohmann-json3-dev"
        fi
    fi
    
    # 检查json库
    if ! check_json_library; then
        log_warning "nlohmann/json库未安装，可能影响编译"
        all_passed=false
    fi
    
    # 检查项目文件
    if ! check_project_files; then
        log_error "项目文件不完整"
        all_passed=false
    fi
    
    # 检查网络连接
    if ! check_network; then
        log_warning "网络连接有问题，API模型可能无法使用"
    fi
    
    # 测试编译
    if ! test_compilation; then
        log_error "项目编译失败"
        all_passed=false
    fi
    
    # 测试Ollama服务
    if ! test_ollama; then
        log_warning "Ollama服务有问题，只能使用API模型"
    fi
    
    # 生成报告
    generate_report
    
    echo
    echo "=== 检查完成 ==="
    if [[ "$all_passed" == "true" ]]; then
        log_success "所有检查通过！项目可以正常运行。"
        echo
        echo "🎉 部署成功！您可以："
        echo "1. 运行: ./start_sql_optimizer.sh"
        echo "2. 或者: make && ./main"
        echo "3. 管理模型: ./manage_ollama.sh help"
    else
        log_error "部分检查失败，请根据上述信息解决问题。"
        echo
        echo "⚠️  需要解决的问题："
        echo "1. 安装缺失的依赖"
        echo "2. 确保项目文件完整"
        echo "3. 检查网络连接"
    fi
    
    echo
    echo "结束时间: $(date)"
}

# 运行主函数
main "$@" 