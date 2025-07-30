#!/bin/bash

# Ollama管理脚本

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

# 设置环境变量
export PATH="./ollama_bin:$PATH"
export OLLAMA_MODELS="$(pwd)/models"

# 检查Ollama可执行文件
check_ollama() {
    if [[ ! -f "./ollama_bin/ollama" ]]; then
        log_error "Ollama可执行文件不存在"
        exit 1
    fi
    log_success "Ollama可执行文件存在"
}

# 启动Ollama服务
start_ollama() {
    log_info "启动Ollama服务..."
    
    # 检查是否已经在运行
    if pgrep -f "ollama serve" > /dev/null; then
        log_warning "Ollama服务已经在运行"
        return 0
    fi
    
    # 启动服务
    nohup ./ollama_bin/ollama serve > ollama.log 2>&1 &
    sleep 3
    
    # 检查服务是否启动成功
    if pgrep -f "ollama serve" > /dev/null; then
        log_success "Ollama服务启动成功"
    else
        log_error "Ollama服务启动失败"
        exit 1
    fi
}

# 停止Ollama服务
stop_ollama() {
    log_info "停止Ollama服务..."
    pkill -f "ollama serve" || true
    log_success "Ollama服务已停止"
}

# 显示当前模型列表
list_models() {
    log_info "当前已安装的模型："
    ./ollama_bin/ollama list
}

# 下载模型
download_model() {
    local model_name=$1
    if [[ -z "$model_name" ]]; then
        log_error "请指定模型名称"
        echo "用法: $0 download <模型名称>"
        echo "示例: $0 download llama2:7b"
        exit 1
    fi
    
    log_info "开始下载模型: $model_name"
    log_warning "这可能需要几分钟到几十分钟，取决于模型大小和网络速度"
    
    ./ollama_bin/ollama pull "$model_name"
    
    if [[ $? -eq 0 ]]; then
        log_success "模型 $model_name 下载完成"
    else
        log_error "模型 $model_name 下载失败"
        exit 1
    fi
}

# 删除模型
remove_model() {
    local model_name=$1
    if [[ -z "$model_name" ]]; then
        log_error "请指定模型名称"
        echo "用法: $0 remove <模型名称>"
        echo "示例: $0 remove llama2:7b"
        exit 1
    fi
    
    log_info "删除模型: $model_name"
    ./ollama_bin/ollama rm "$model_name"
    log_success "模型 $model_name 已删除"
}

# 运行模型
run_model() {
    local model_name=$1
    if [[ -z "$model_name" ]]; then
        log_error "请指定模型名称"
        echo "用法: $0 run <模型名称>"
        echo "示例: $0 run llama2:7b"
        exit 1
    fi
    
    log_info "运行模型: $model_name"
    ./ollama_bin/ollama run "$model_name"
}

# 显示帮助信息
show_help() {
    echo "Ollama管理脚本"
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "命令:"
    echo "  start             启动Ollama服务"
    echo "  stop              停止Ollama服务"
    echo "  restart           重启Ollama服务"
    echo "  status            显示服务状态"
    echo "  list              显示已安装的模型"
    echo "  download <模型>   下载指定模型"
    echo "  remove <模型>     删除指定模型"
    echo "  run <模型>        运行指定模型"
    echo "  help              显示此帮助信息"
    echo ""
    echo "常用模型示例:"
    echo "  llama2:7b         Llama2 7B模型"
    echo "  llama2:13b        Llama2 13B模型"
    echo "  codellama:7b      Code Llama 7B模型"
    echo "  qwen2.5:7b        Qwen2.5 7B模型"
    echo "  deepseek-coder:6.7b  DeepSeek Coder 6.7B模型"
    echo "  mistral:7b        Mistral 7B模型"
    echo ""
    echo "示例:"
    echo "  $0 start"
    echo "  $0 download llama2:7b"
    echo "  $0 list"
    echo "  $0 run llama2:7b"
}

# 显示服务状态
show_status() {
    log_info "Ollama服务状态："
    if pgrep -f "ollama serve" > /dev/null; then
        log_success "服务正在运行"
        echo "进程ID: $(pgrep -f 'ollama serve')"
    else
        log_error "服务未运行"
    fi
    
    echo ""
    log_info "环境变量："
    echo "PATH: $PATH"
    echo "OLLAMA_MODELS: $OLLAMA_MODELS"
}

# 重启服务
restart_ollama() {
    log_info "重启Ollama服务..."
    stop_ollama
    sleep 2
    start_ollama
}

# 主函数
main() {
    check_ollama
    
    case "${1:-help}" in
        start)
            start_ollama
            ;;
        stop)
            stop_ollama
            ;;
        restart)
            restart_ollama
            ;;
        status)
            show_status
            ;;
        list)
            start_ollama
            list_models
            ;;
        download)
            start_ollama
            download_model "$2"
            ;;
        remove)
            remove_model "$2"
            ;;
        run)
            start_ollama
            run_model "$2"
            ;;
        help|*)
            show_help
            ;;
    esac
}

main "$@" 