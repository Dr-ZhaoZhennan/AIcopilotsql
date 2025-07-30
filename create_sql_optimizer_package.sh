#!/bin/bash

# SQL优化器完整部署包创建脚本 - 开箱即用版本

set -e

echo "=== 创建SQL优化器完整部署包（开箱即用） ==="
echo "开始时间: $(date)"
echo

# 创建包名
PACKAGE_NAME="sql_optimizer_complete_$(date +%Y%m%d_%H%M%S).tar.gz"
TEMP_DIR=$(mktemp -d)
PACKAGE_DIR="$TEMP_DIR/sql_optimizer"

echo "创建临时目录: $TEMP_DIR"
mkdir -p "$PACKAGE_DIR"

echo "复制项目文件..."

# 复制源代码
cp -r src/ "$PACKAGE_DIR/"
cp -r include/ "$PACKAGE_DIR/"
cp -r config/ "$PACKAGE_DIR/"

# 复制主程序文件
cp main.cpp "$PACKAGE_DIR/"
cp Makefile "$PACKAGE_DIR/"
cp README.md "$PACKAGE_DIR/"

# 复制启动脚本
cp start_sql_optimizer.sh "$PACKAGE_DIR/"

# 复制本地Ollama文件
if [[ -d "ollama_bin" ]]; then
    cp -r ollama_bin/ "$PACKAGE_DIR/"
    echo "✓ 复制本地Ollama可执行文件"
else
    echo "✗ 警告: 未找到ollama_bin目录"
fi

# 复制模型文件
if [[ -d "models" ]]; then
    cp -r models/ "$PACKAGE_DIR/"
    echo "✓ 复制AI模型文件"
    
    # 显示模型信息
    MODEL_SIZE=$(du -sh models/ | cut -f1)
    echo "  模型大小: $MODEL_SIZE"
else
    echo "✗ 警告: 未找到models目录"
fi

# 创建安装脚本
echo "创建安装脚本..."
cat > "$PACKAGE_DIR/install.sh" << 'INSTALL_EOF'
#!/bin/bash

# SQL优化器安装脚本 - 开箱即用版本

set -e

echo "=== SQL优化器安装脚本 ==="
echo "开始时间: $(date)"
echo

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

# 检查是否以root权限运行
if [[ $EUID -eq 0 ]]; then
    log_error "请不要以root权限运行此脚本"
    exit 1
fi

# 安装系统依赖
log_info "安装系统依赖..."
sudo apt-get update
sudo apt-get install -y build-essential nlohmann-json3-dev curl

# 设置本地Ollama
log_info "设置本地Ollama..."
if [[ -f "ollama_bin/ollama" ]]; then
    # 给本地Ollama添加执行权限
    chmod +x ollama_bin/ollama
    
    # 创建软链接到系统路径（可选）
    if [[ ! -f "/usr/local/bin/ollama" ]]; then
        sudo ln -sf "$(pwd)/ollama_bin/ollama" /usr/local/bin/ollama
        log_success "Ollama已链接到系统路径"
    fi
    
    log_success "本地Ollama设置完成"
else
    log_error "未找到本地Ollama可执行文件"
    exit 1
fi

# 设置模型路径
log_info "设置模型路径..."
if [[ -d "models" ]]; then
    # 设置环境变量
    echo "export OLLAMA_MODELS=$(pwd)/models" >> ~/.bashrc
    export OLLAMA_MODELS="$(pwd)/models"
    log_success "模型路径已设置: $OLLAMA_MODELS"
    
    # 显示模型信息
    MODEL_COUNT=$(find models/ -type f | wc -l)
    MODEL_SIZE=$(du -sh models/ | cut -f1)
    log_info "模型文件数: $MODEL_COUNT"
    log_info "模型大小: $MODEL_SIZE"
else
    log_warning "模型目录不存在"
fi

# 设置脚本权限
log_info "设置脚本权限..."
chmod +x *.sh

# 编译项目
log_info "编译SQL优化器..."
if make; then
    log_success "项目编译成功"
else
    log_error "项目编译失败"
    exit 1
fi

echo
log_success "=== 安装完成 ==="
log_success "✓ 系统依赖已安装"
log_success "✓ 本地Ollama已设置"
log_success "✓ 模型路径已配置"
log_success "✓ 项目已编译完成"
log_success "✓ 脚本已准备就绪"
echo
echo "下一步操作:"
echo "1. 启动服务: ./start_sql_optimizer.sh"
echo "2. 查看模型: ollama list"
echo "3. 测试模型: ollama run qwen2.5-coder:7b"
echo
echo "结束时间: $(date)"
INSTALL_EOF

chmod +x "$PACKAGE_DIR/install.sh"

# 创建README
echo "创建README文件..."
cat > "$PACKAGE_DIR/README.md" << 'README_EOF'
# GaussDB SQL优化Copilot - 开箱即用版本

## 项目简介
这是一个基于本地AI大模型的GaussDB SQL查询优化工具，采用C/C++实现，支持对EXPLAIN(ANALYZE)结果进行自动分析、优化建议生成，并具备交互式"会诊"能力。

**特点：开箱即用，无需额外下载任何文件！**

## 功能特性
- ✅ 支持GaussDB EXPLAIN(ANALYZE)结果分析
- ✅ 自动生成SQL优化建议
- ✅ 交互式会诊，主动向用户提问补全知识
- ✅ 本地AI模型，无需网络连接
- ✅ 支持多种AI模型切换
- ✅ 开箱即用，包含所有必要文件

## 包含内容
- **本地Ollama可执行文件** - 无需安装
- **预训练AI模型** - 包含多个模型权重文件
- **SQL优化器源代码** - C/C++实现
- **配置文件** - 完整的AI模型配置
- **安装和启动脚本** - 一键部署

## 快速开始

### 1. 解压部署包
```bash
tar -xzf sql_optimizer_complete_*.tar.gz
cd sql_optimizer
```

### 2. 运行安装脚本
```bash
./install.sh
```

### 3. 启动SQL优化器
```bash
./start_sql_optimizer.sh
```

## 使用说明

### 启动优化器
```bash
./start_sql_optimizer.sh
```

### 使用流程
1. 输入SQL语句（多行，END结束）
2. 输入EXPLAIN(ANALYZE)结果（多行，END结束）
3. **选择AI模型**（1,2,3等数字选择）
4. 系统自动分析并给出优化建议
5. 可以继续补充信息进行多轮对话

### AI模型选择
程序会显示可用的AI模型列表，您可以通过输入数字来选择：
- 1. qwen2.5-coder:7b - 中文友好的代码模型
- 2. deepseek-coder:6.7b - 代码生成模型
- 3. deepseek-r1:7b - 平衡性能模型
- 0. 使用默认模型

## 可用AI模型
- **qwen2.5-coder:7b** (4.7 GB) - 中文友好的代码模型
- **deepseek-coder:6.7b** (3.8 GB) - 代码生成模型
- **deepseek-r1:7b** (4.7 GB) - 平衡性能模型

## 系统要求
- Linux x86_64
- 至少8GB内存
- 至少30GB可用磁盘空间
- 推荐16GB内存和50GB磁盘空间

## 文件说明
- `src/` - 源代码目录
- `include/` - 头文件目录
- `config/` - 配置文件
- `ollama_bin/ollama` - 本地Ollama可执行文件
- `models/` - AI模型权重文件
- `main.cpp` - 主程序
- `Makefile` - 编译配置
- `install.sh` - 安装脚本
- `start_sql_optimizer.sh` - 启动脚本

## 配置说明
AI模型配置在 `config/ai_models.json` 中，可以修改默认模型和参数。

## 故障排除
1. 如果编译失败，请检查是否安装了build-essential和nlohmann-json3-dev
2. 如果Ollama启动失败，请检查端口11434是否被占用
3. 如果模型加载失败，请检查磁盘空间是否充足

## 技术支持
- 日志文件: ollama.log
- 错误信息: 查看终端输出
- 模型状态: ollama list

## 开发说明
项目采用模块化设计，主要模块包括：
- agent1_input: 输入接收与验证
- agent2_diagnose: 语义诊断
- agent3_strategy: 策略生成
- agent4_report: 报告生成
- agent5_interactive: 交互与知识管理
- ai_engine: AI接口模块
- utils: 工具函数

## 开箱即用特性
- ✅ 无需下载Ollama
- ✅ 无需下载模型权重
- ✅ 无需网络连接
- ✅ 解压即可使用
- ✅ 支持AI模型选择
README_EOF

# 创建快速启动脚本
echo "创建快速启动脚本..."
cat > "$PACKAGE_DIR/quick_start.sh" << 'QUICK_START_EOF'
#!/bin/bash

# 快速启动脚本

echo "=== SQL优化器快速启动 ==="

# 检查是否已安装
if [[ ! -f "./main" ]]; then
    echo "项目未编译，正在安装..."
    ./install.sh
fi

# 设置本地Ollama
if [[ -f "./ollama_bin/ollama" ]]; then
    export PATH="./ollama_bin:$PATH"
    chmod +x ./ollama_bin/ollama
fi

# 设置模型路径
if [[ -d "./models" ]]; then
    export OLLAMA_MODELS="$(pwd)/models"
fi

# 检查Ollama服务
if ! curl -s http://127.0.0.1:11434 > /dev/null 2>&1; then
    echo "启动Ollama服务..."
    ollama serve > ollama.log 2>&1 &
    sleep 3
fi

# 启动优化器
echo "启动SQL优化器..."
./main
QUICK_START_EOF

chmod +x "$PACKAGE_DIR/quick_start.sh"

# 创建停止脚本
echo "创建停止脚本..."
cat > "$PACKAGE_DIR/stop_services.sh" << 'STOP_EOF'
#!/bin/bash

echo "停止所有服务..."

# 停止Ollama服务
PIDS=$(pgrep -f "ollama serve")
if [[ -n "$PIDS" ]]; then
    echo $PIDS | xargs kill
    echo "✓ 已停止Ollama服务"
else
    echo "没有运行中的Ollama服务"
fi

# 停止主程序
PIDS=$(pgrep -f "./main")
if [[ -n "$PIDS" ]]; then
    echo $PIDS | xargs kill
    echo "✓ 已停止SQL优化器"
else
    echo "没有运行中的SQL优化器"
fi
STOP_EOF

chmod +x "$PACKAGE_DIR/stop_services.sh"

# 打包
echo "创建压缩包..."
cd "$TEMP_DIR"
tar -czf "$PACKAGE_NAME" sql_optimizer/

# 移动到当前目录
mv "$PACKAGE_NAME" "$OLDPWD/"
cd "$OLDPWD"

# 清理临时目录
rm -rf "$TEMP_DIR"

# 显示结果
echo
echo "=== 打包完成 ==="
echo "包文件: $PACKAGE_NAME"
echo "文件大小: $(du -h "$PACKAGE_NAME" | cut -f1)"

echo
echo "=== 部署说明 ==="
echo "1. 将 $PACKAGE_NAME 复制到目标机器"
echo "2. 解压: tar -xzf $PACKAGE_NAME"
echo "3. 进入目录: cd sql_optimizer"
echo "4. 安装: ./install.sh"
echo "5. 启动: ./start_sql_optimizer.sh"
echo
echo "=== 开箱即用特性 ==="
echo "✅ 包含本地Ollama可执行文件"
echo "✅ 包含AI模型权重文件"
echo "✅ 无需网络连接"
echo "✅ 支持AI模型选择"
echo "✅ 解压即可使用"

echo
echo "结束时间: $(date)" 