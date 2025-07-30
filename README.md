# GaussDB SQL优化Copilot

## 项目简介
这是一个基于本地AI大模型的GaussDB SQL查询优化工具，采用C/C++实现，支持对EXPLAIN(ANALYZE)结果进行自动分析、优化建议生成，并具备交互式"会诊"能力。

**特点：开箱即用，支持本地模型和API模型！**

## 功能特性
- ✅ 支持GaussDB EXPLAIN(ANALYZE)结果分析
- ✅ 自动生成SQL优化建议
- ✅ 交互式会诊，主动向用户提问补全知识
- ✅ **本地AI模型** - 无需网络连接，数据安全
- ✅ **API模型支持** - 支持DeepSeek等在线API
- ✅ 支持多种AI模型切换
- ✅ 开箱即用，包含所有必要文件

## 项目结构
```
AIAgent/
├── src/                          # 源代码目录
│   ├── agent1_input/            # 输入接收与验证
│   ├── agent2_diagnose/         # 语义诊断
│   ├── agent3_strategy/         # 策略生成
│   ├── agent4_report/           # 报告生成
│   ├── agent5_interactive/      # 交互与知识管理
│   ├── ai_engine/              # AI接口模块
│   └── utils/                  # 工具函数
├── include/                     # 头文件目录
├── config/                      # 配置文件
│   └── ai_models.json          # AI模型配置
├── ollama_bin/                 # 本地Ollama可执行文件
│   └── ollama                  # Ollama二进制文件
├── models/                      # AI模型权重文件
├── main.cpp                     # 主程序
├── Makefile                     # 编译配置
├── README.md                    # 项目说明
├── start_sql_optimizer.sh      # 启动脚本
└── create_sql_optimizer_package.sh  # 打包脚本
```

## 快速开始

### 方法1: 一键部署（推荐）
```bash
# 解压项目文件
tar -xzf sql_optimizer_complete_*.tar.gz
cd sql_optimizer

# 运行依赖检查
./check_dependencies.sh

# 启动程序
./start_sql_optimizer.sh
```

### 方法2: 一键启动
```bash
./start_sql_optimizer.sh
```

### 方法3: 手动启动
```bash
# 编译项目
make

# 设置本地Ollama
export PATH="./ollama_bin:$PATH"
chmod +x ./ollama_bin/ollama

# 设置模型路径
export OLLAMA_MODELS="$(pwd)/models"

# 启动Ollama服务
ollama serve &

# 运行优化器
./main
```

### 方法4: 创建部署包
```bash
./create_sql_optimizer_package.sh
```



## 使用流程
1. 输入SQL语句（多行，END结束）
2. 输入EXPLAIN(ANALYZE)结果（多行，END结束）
3. **选择AI模型**（本地模型或API模型）
4. 系统自动分析并给出优化建议
5. 可以继续补充信息进行多轮对话

## 可用AI模型

### 本地模型（无需网络）
- **qwen2.5-coder:7b** (4.7 GB) - 中文友好的代码模型
- **deepseek-coder:6.7b** (3.8 GB) - 代码生成模型
- **deepseek-r1:7b** (4.7 GB) - 平衡性能模型

### API模型（需要网络）
- **deepseek-chat** - DeepSeek Chat API模型
- **deepseek-reasoner** - DeepSeek Reasoner API模型

## AI模型选择
程序会显示可用的AI模型列表，您可以通过输入数字来选择：
```
=== 可用AI模型 ===
1. qwen2.5-coder:7b [本地] - 中文友好的代码模型
2. deepseek-coder:6.7b [本地] - 代码生成模型
3. deepseek-r1:7b [本地] - 平衡性能模型
4. deepseek-chat [API] - DeepSeek Chat API模型
5. deepseek-reasoner [API] - DeepSeek Reasoner API模型
0. 使用默认模型

请选择AI模型 (0-5): 
```

## 开箱即用特性
- ✅ 包含本地Ollama可执行文件
- ✅ 包含AI模型权重文件
- ✅ 支持本地模型（无需网络连接）
- ✅ 支持API模型（需要网络连接）
- ✅ 支持AI模型选择
- ✅ 解压即可使用
- ✅ 自动依赖检查和安装
- ✅ 支持多种Linux发行版
- ✅ 完整的部署指南和故障排除

## 系统要求

### 最低要求
- **操作系统**: Linux x86_64 (Ubuntu 18.04+, CentOS 7+, RHEL 7+)
- **内存**: 4GB RAM
- **磁盘空间**: 10GB 可用空间
- **网络**: 可选（用于API模型）

### 推荐配置
- **操作系统**: Ubuntu 20.04+ 或 CentOS 8+
- **内存**: 8GB+ RAM
- **磁盘空间**: 20GB+ 可用空间
- **网络**: 稳定的互联网连接

### 本地模型要求
- 至少8GB内存
- 至少30GB可用磁盘空间
- 推荐16GB内存和50GB磁盘空间

### API模型要求
- 网络连接
- 有效的API密钥
- 防火墙允许HTTPS连接

## 配置说明

### 本地模型配置
本地模型配置在 `config/ai_models.json` 中，包括：
- 模型名称和描述
- Ollama服务配置
- 模型参数（temperature、max_tokens等）

### API模型配置
API模型需要配置：
- API端点URL
- API密钥
- 模型ID
- 请求参数

示例配置：
```json
{
  "name": "deepseek-chat",
  "type": "api",
  "url": "https://api.deepseek.com/chat/completions",
  "api_key": "your-api-key-here",
  "model_id": "deepseek-chat",
  "description": "DeepSeek Chat API模型"
}
```

## 编译和运行
```bash
# 编译项目
make

# 运行优化器
./main
```

## 故障排除

### 本地模型问题
1. **Ollama服务启动失败**
   - 检查端口11434是否被占用
   - 运行 `pkill -f "ollama serve"` 停止现有服务

2. **模型加载失败**
   - 检查磁盘空间是否充足
   - 确认模型文件完整性

### API模型问题
1. **网络连接失败**
   - 检查网络连接
   - 确认防火墙设置

2. **API密钥无效**
   - 检查API密钥是否正确
   - 确认API密钥权限

3. **请求超时**
   - 检查网络延迟
   - 调整超时设置

## 部署和分发

### 新电脑部署
本项目设计为**开箱即用**，可以在没有预装Ollama和大模型的新电脑上正常运行：

1. **解压项目文件**
2. **运行依赖检查**: `./check_dependencies.sh`
3. **启动程序**: `./start_sql_optimizer.sh`

### 部署模式
- **完全本地模式**: 无需网络连接，数据安全
- **API模式**: 需要网络连接，使用在线API
- **混合模式**: 本地模型 + API模型

### 故障排除
- 查看部署报告: `cat deployment_report.txt`
- 运行诊断: `./check_dependencies.sh`
- 管理模型: `./manage_ollama.sh help`

详细部署指南请参考: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

## 许可证
MIT License
