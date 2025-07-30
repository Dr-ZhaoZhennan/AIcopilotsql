#!/bin/bash

# SQL优化器启动脚本 - 集成本地Ollama和模型权重

set -e

echo "=== GaussDB SQL优化Copilot启动脚本 ==="
echo "开始时间: $(date)"
echo

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
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

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    # 检查编译器
    if ! command -v g++ &> /dev/null; then
        log_error "未找到g++编译器，请安装build-essential"
        exit 1
    fi
    
    # 检查make
    if ! command -v make &> /dev/null; then
        log_error "未找到make工具，请安装build-essential"
        exit 1
    fi
    
    # 检查nlohmann/json
    if [[ ! -f "/usr/include/nlohmann/json.hpp" ]] && [[ ! -f "/usr/local/include/nlohmann/json.hpp" ]]; then
        log_warning "未找到nlohmann/json库，正在安装..."
        sudo apt-get update
        sudo apt-get install -y nlohmann-json3-dev
    fi
    
    log_success "系统依赖检查完成"
}

# 设置本地Ollama
setup_local_ollama() {
    log_info "设置本地Ollama..."
    
    # 检查本地Ollama可执行文件
    if [[ -f "./ollama_bin/ollama" ]]; then
        log_info "发现本地Ollama可执行文件"
        
        # 设置PATH，优先使用本地Ollama
        export PATH="./ollama_bin:$PATH"
        
        # 设置OLLAMA_MODELS环境变量指向本地模型
        if [[ -d "./models" ]]; then
            export OLLAMA_MODELS="$(pwd)/models"
            log_success "设置本地模型路径: $OLLAMA_MODELS"
        fi
        
        # 给本地Ollama添加执行权限
        chmod +x ./ollama_bin/ollama
        
        log_success "本地Ollama设置完成"
    else
        log_error "未找到本地Ollama可执行文件: ./ollama_bin/ollama"
        exit 1
    fi
}

# 检查Ollama服务
check_ollama_service() {
    log_info "检查Ollama服务..."
    
    # 检查Ollama是否可用
    if ! command -v ollama &> /dev/null; then
        log_error "Ollama未安装或不可用"
        exit 1
    fi
    
    # 检查Ollama服务状态
    if ! curl -s http://127.0.0.1:11434 > /dev/null 2>&1; then
        log_warning "Ollama服务未运行，正在启动..."
        
        # 启动Ollama服务
        nohup ollama serve > ollama.log 2>&1 &
        OLLAMA_PID=$!
        
        # 等待服务启动
        log_info "等待Ollama服务启动..."
        for i in {1..30}; do
            if curl -s http://127.0.0.1:11434 > /dev/null 2>&1; then
                log_success "Ollama服务启动成功 (PID: $OLLAMA_PID)"
                echo $OLLAMA_PID > ollama.pid
                break
            fi
            sleep 1
            echo -n "."
        done
        
        if [[ $i -eq 30 ]]; then
            log_error "Ollama服务启动超时"
            exit 1
        fi
    else
        log_success "Ollama服务已在运行"
    fi
    
    # 检查可用模型
    log_info "检查可用模型..."
    if ollama list 2>/dev/null | grep -q .; then
        log_success "发现可用模型:"
        ollama list
    else
        log_warning "未找到可用模型，请检查模型文件"
    fi
}

# 编译项目
compile_project() {
    log_info "编译SQL优化器项目..."
    
    # 清理之前的编译
    make clean 2>/dev/null || true
    
    # 编译项目
    if make; then
        log_success "项目编译成功"
    else
        log_error "项目编译失败"
        exit 1
    fi
}

# 启动SQL优化器
start_optimizer() {
    log_info "启动SQL优化器..."
    
    if [[ -f "./main" ]]; then
        log_success "SQL优化器启动成功"
        echo
        echo "=== 使用说明 ==="
        echo "1. 输入SQL语句（多行，END结束）"
        echo "2. 输入EXPLAIN(ANALYZE)结果（多行，END结束）"
        echo "3. 选择要使用的AI模型（1,2,3等）"
        echo "4. 系统将自动分析并给出优化建议"
        echo "5. 可以继续补充信息进行多轮对话"
        echo "6. 输入exit退出程序"
        echo
        echo "按回车键开始..."
        read
        
        # 启动主程序
        ./main
    else
        log_error "未找到可执行文件main"
        exit 1
    fi
}

# 清理函数
cleanup() {
    log_info "清理资源..."
    
    # 停止Ollama服务（如果是我们启动的）
    if [[ -f "ollama.pid" ]]; then
        PID=$(cat ollama.pid)
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            log_info "已停止Ollama服务 (PID: $PID)"
        fi
        rm -f ollama.pid
    fi
}

# 主函数
main() {
    # 设置信号处理
    trap cleanup EXIT
    
    log_info "开始启动SQL优化器..."
    
    check_dependencies
    setup_local_ollama
    check_ollama_service
    compile_project
    start_optimizer
}

# 运行主函数
main "$@" 