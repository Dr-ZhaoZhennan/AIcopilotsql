# 项目结构说明

## 📁 核心文件

### 主要程序文件
- `main.cpp` - 主程序源码
- `Makefile` - 编译配置文件
- `start_sql_optimizer.sh` - 启动脚本
- `create_sql_optimizer_package.sh` - 打包脚本

### 文档文件
- `README.md` - 项目使用说明
- `PROJECT_FINAL.md` - 项目总结文档

### 核心目录
- `src/` - 源代码目录
  - `ai_engine/` - AI引擎实现
  - `agent1_input/` - 输入处理模块
  - `agent2_diagnose/` - 诊断分析模块
  - `agent3_strategy/` - 策略生成模块
  - `agent4_report/` - 报告生成模块
  - `agent5_interactive/` - 交互式会诊模块
  - `utils/` - 工具函数

- `include/` - 头文件目录
- `config/` - 配置文件目录
  - `ai_models.json` - AI模型配置

### 运行时文件
- `ollama_bin/` - Ollama二进制文件
  - `ollama` - Ollama可执行文件
- `models/` - 本地模型权重文件

## 🚀 快速使用

1. **编译项目**：`make`
2. **启动程序**：`./start_sql_optimizer.sh`
3. **创建部署包**：`./create_sql_optimizer_package.sh`

## ✨ 项目特点

- **开箱即用** - 包含所有必要文件
- **多模型支持** - 本地模型和API模型
- **模块化设计** - 易于维护和扩展
- **完整文档** - 详细的使用说明 