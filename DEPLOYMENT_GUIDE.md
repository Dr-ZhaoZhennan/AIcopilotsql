# GaussDB SQL优化Copilot - 部署指南

## 🎯 部署概述

本项目设计为**开箱即用**，可以在没有预装Ollama和大模型的新电脑上正常运行。

## 📋 系统要求

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

## 🚀 快速部署

### 方法1: 一键部署（推荐）

```bash
# 1. 解压项目文件
tar -xzf sql_optimizer_complete_*.tar.gz
cd sql_optimizer

# 2. 运行依赖检查
./check_dependencies.sh

# 3. 启动程序
./start_sql_optimizer.sh
```

### 方法2: 手动部署

```bash
# 1. 解压项目文件
tar -xzf sql_optimizer_complete_*.tar.gz
cd sql_optimizer

# 2. 安装依赖（Ubuntu/Debian）
sudo apt-get update
sudo apt-get install -y build-essential curl nlohmann-json3-dev

# 3. 编译项目
make

# 4. 启动程序
./main
```

## 🔧 详细部署步骤

### 1. 环境准备

#### Ubuntu/Debian系统
```bash
# 更新系统
sudo apt-get update

# 安装编译工具
sudo apt-get install -y build-essential

# 安装curl
sudo apt-get install -y curl

# 安装nlohmann/json库
sudo apt-get install -y nlohmann-json3-dev
```

#### CentOS/RHEL系统
```bash
# 安装开发工具组
sudo yum groupinstall -y "Development Tools"

# 安装curl
sudo yum install -y curl

# 安装nlohmann/json库
sudo yum install -y nlohmann-json-devel
```

### 2. 项目部署

```bash
# 解压项目文件
tar -xzf sql_optimizer_complete_*.tar.gz
cd sql_optimizer

# 检查项目完整性
ls -la

# 应该看到以下文件和目录：
# - main.cpp (主程序源码)
# - Makefile (编译配置)
# - start_sql_optimizer.sh (启动脚本)
# - check_dependencies.sh (依赖检查脚本)
# - manage_ollama.sh (Ollama管理脚本)
# - ollama_bin/ (Ollama二进制文件)
# - models/ (模型权重文件)
# - src/ (源代码目录)
# - include/ (头文件目录)
# - config/ (配置文件目录)
```

### 3. 依赖检查

```bash
# 运行完整的依赖检查
./check_dependencies.sh

# 检查结果
cat deployment_report.txt
```

### 4. 编译项目

```bash
# 清理之前的编译文件
make clean

# 编译项目
make

# 检查编译结果
ls -la main
```

### 5. 启动服务

#### 使用启动脚本（推荐）
```bash
./start_sql_optimizer.sh
```

#### 手动启动
```bash
# 设置环境变量
export PATH="./ollama_bin:$PATH"
export OLLAMA_MODELS="$(pwd)/models"

# 启动Ollama服务
nohup ./ollama_bin/ollama serve > ollama.log 2>&1 &

# 等待服务启动
sleep 5

# 运行主程序
./main
```

## 🎯 运行模式

### 1. 完全本地模式（推荐）
- **特点**: 无需网络连接，数据安全
- **要求**: 需要本地模型文件
- **启动**: `./start_sql_optimizer.sh`
- **模型**: 使用内置的本地模型

### 2. API模式
- **特点**: 需要网络连接，使用在线API
- **要求**: 稳定的互联网连接
- **启动**: `./start_sql_optimizer.sh`
- **模型**: 使用DeepSeek等在线API

### 3. 混合模式
- **特点**: 本地模型 + API模型
- **要求**: 本地模型文件 + 网络连接
- **启动**: `./start_sql_optimizer.sh`
- **模型**: 可选择本地或API模型

## 🔍 故障排除

### 常见问题

#### 1. 编译失败
```bash
# 错误: g++: command not found
sudo apt-get install -y build-essential

# 错误: nlohmann/json.hpp: No such file or directory
sudo apt-get install -y nlohmann-json3-dev
```

#### 2. Ollama服务启动失败
```bash
# 检查Ollama可执行文件
ls -la ollama_bin/ollama

# 检查权限
chmod +x ollama_bin/ollama

# 检查端口占用
netstat -tlnp | grep 11434

# 手动启动服务
./ollama_bin/ollama serve
```

#### 3. 模型加载失败
```bash
# 检查模型文件
ls -la models/

# 检查磁盘空间
df -h

# 重新下载模型
./manage_ollama.sh download llama2:7b
```

#### 4. 网络连接问题
```bash
# 测试网络连接
curl -s https://api.deepseek.com

# 检查防火墙
sudo ufw status

# 检查DNS
nslookup api.deepseek.com
```

### 调试工具

#### 1. 依赖检查
```bash
./check_dependencies.sh
```

#### 2. 服务状态检查
```bash
./manage_ollama.sh status
```

#### 3. 模型管理
```bash
# 查看已安装模型
./manage_ollama.sh list

# 下载新模型
./manage_ollama.sh download llama2:7b

# 删除模型
./manage_ollama.sh remove llama2:7b
```

#### 4. 日志查看
```bash
# 查看Ollama日志
tail -f ollama.log

# 查看系统日志
journalctl -u ollama -f
```

## 📊 性能优化

### 1. 内存优化
```bash
# 检查内存使用
free -h

# 调整Ollama内存限制
export OLLAMA_HOST=127.0.0.1:11434
export OLLAMA_ORIGINS=*
```

### 2. 磁盘优化
```bash
# 检查磁盘空间
df -h

# 清理不需要的模型
./manage_ollama.sh list
./manage_ollama.sh remove <unused_model>
```

### 3. 网络优化
```bash
# 设置代理（如果需要）
export http_proxy=http://proxy:port
export https_proxy=http://proxy:port
```

## 🔒 安全考虑

### 1. 数据安全
- **本地模型**: 数据完全本地处理，不上传
- **API模型**: 仅发送必要的查询信息
- **日志文件**: 定期清理敏感信息

### 2. 网络安全
- **防火墙**: 只开放必要端口
- **代理**: 使用企业代理访问外网
- **VPN**: 通过VPN访问API服务

### 3. 权限管理
- **用户权限**: 使用非root用户运行
- **文件权限**: 设置适当的文件权限
- **服务权限**: 限制服务运行权限

## 📈 监控和维护

### 1. 服务监控
```bash
# 检查服务状态
./manage_ollama.sh status

# 监控资源使用
htop

# 检查日志
tail -f ollama.log
```

### 2. 定期维护
```bash
# 更新模型
./manage_ollama.sh download <new_model>

# 清理日志
rm -f ollama.log

# 备份配置
cp config/ai_models.json config/ai_models.json.backup
```

### 3. 性能调优
```bash
# 调整Ollama参数
export OLLAMA_NUM_PARALLEL=4
export OLLAMA_HOST=127.0.0.1:11434
```

## 🎉 部署成功标志

当您看到以下信息时，说明部署成功：

```
============================================================
🚀 Copilot SQL 优化助手
============================================================

----------------------------------------
📝 【步骤1】请输入SQL语句
----------------------------------------
```

## 📞 技术支持

### 获取帮助
1. 查看部署报告: `cat deployment_report.txt`
2. 运行诊断: `./check_dependencies.sh`
3. 查看日志: `tail -f ollama.log`

### 常见命令
```bash
# 启动服务
./start_sql_optimizer.sh

# 检查状态
./manage_ollama.sh status

# 管理模型
./manage_ollama.sh help

# 检查依赖
./check_dependencies.sh
```

---

**注意**: 本项目设计为开箱即用，包含所有必要的二进制文件和模型权重，可以在没有预装Ollama和大模型的新电脑上正常运行。 