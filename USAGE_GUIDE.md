# AIAgent 独立二进制文件使用指南

## 📦 文件说明

我们已经为你创建了一个独立的二进制文件包，包含以下文件：

```
dist/
├── AIAgent              # 主程序可执行文件
├── config/              # 配置文件目录
├── run.sh               # 运行脚本
├── install.sh           # 安装脚本
├── check-deps.sh        # 依赖检查脚本
├── README.txt           # 使用说明
└── README.md            # 项目文档
```

## 🚀 快速开始

### 方法一：直接运行（推荐）

1. **下载并解压**
   ```bash
   # 如果是压缩包，先解压
   tar -xzf AIAgent-portable.tar.gz
   cd AIAgent-portable
   ```

2. **检查依赖**
   ```bash
   ./check-deps.sh
   ```

3. **运行程序**
   ```bash
   ./AIAgent
   # 或者使用运行脚本
   ./run.sh
   ```

### 方法二：安装到系统

1. **安装到系统目录**
   ```bash
   sudo ./install.sh
   ```

2. **全局运行**
   ```bash
   AIAgent
   ```

## 📋 系统要求

### 最低要求
- Linux 系统（x86_64 架构）
- 基本的 C++ 运行时库
- 网络连接（用于 AI API 调用）

### 依赖库
程序需要以下库文件（通常现代 Linux 系统都已预装）：
- `libcurl.so.4` - HTTP 客户端库
- `libssl.so.3` - SSL/TLS 加密库
- `libcrypto.so.3` - 加密库
- `libstdc++.so.6` - C++ 标准库
- `libc.so.6` - C 标准库

### 安装缺失依赖

**Ubuntu/Debian 系统：**
```bash
sudo apt-get update
sudo apt-get install libcurl4 libssl3 libstdc++6
```

**CentOS/RHEL 系统：**
```bash
sudo yum install libcurl openssl-libs libstdc++
# 或者使用 dnf
sudo dnf install libcurl openssl-libs libstdc++
```

## 🔧 配置说明

### 配置文件
配置文件位于 `config/` 目录中：

```
config/
└── ai_models.json      # AI 模型配置
```

### 配置 AI 模型
编辑 `config/ai_models.json` 文件来配置 AI 模型：

```json
[
  {
    "name": "OpenAI GPT-4",
    "api_url": "https://api.openai.com/v1/chat/completions",
    "api_key": "your-api-key-here",
    "model": "gpt-4",
    "max_tokens": 4000,
    "temperature": 0.7
  }
]
```

## 📖 使用教程

### 基本使用流程

1. **启动程序**
   ```bash
   ./AIAgent
   ```

2. **输入 SQL 语句**
   ```
   请输入SQL语句（可多行，END/#END/两次空行结束）：
   SELECT * FROM users WHERE age > 25;
   END
   ```

3. **输入执行计划**
   ```
   请输入查询计划分析（EXPLAIN(ANALYZE)结果）：
   EXPLAIN (ANALYZE) SELECT * FROM users WHERE age > 25;
   END
   ```

4. **获取优化建议**
   程序会自动分析并生成优化建议。

### 高级功能

- **多行输入**：支持复杂的 SQL 语句和执行计划
- **交互式问答**：程序可能需要补充信息时会主动提问
- **退出程序**：在任何输入环节输入 `exit` 或 `quit` 即可退出

## 🛠️ 故障排除

### 常见问题

1. **权限错误**
   ```bash
   chmod +x AIAgent
   chmod +x *.sh
   ```

2. **依赖库缺失**
   ```bash
   ./check-deps.sh
   # 根据提示安装缺失的库
   ```

3. **网络连接问题**
   - 检查网络连接
   - 确认防火墙设置
   - 验证 API 密钥是否正确

4. **配置文件错误**
   - 检查 `config/ai_models.json` 格式
   - 确认 API 密钥有效

### 调试模式

如果需要调试，可以查看详细输出：
```bash
# 检查程序是否可执行
file AIAgent

# 查看依赖库
ldd AIAgent

# 运行并查看详细输出
./AIAgent 2>&1 | tee output.log
```

## 📦 分发说明

### 创建便携式包
```bash
# 在项目根目录运行
./create-standalone.sh package
```

### 分发文件
分发时只需要以下文件：
- `AIAgent` - 主程序
- `config/` - 配置文件目录
- `run.sh` - 运行脚本
- `check-deps.sh` - 依赖检查脚本
- `README.txt` - 使用说明

## 🔒 安全注意事项

1. **API 密钥安全**
   - 不要在代码中硬编码 API 密钥
   - 使用环境变量或配置文件
   - 定期轮换 API 密钥

2. **文件权限**
   - 确保可执行文件有执行权限
   - 配置文件应该有适当的读写权限

3. **网络安全**
   - 使用 HTTPS 连接
   - 验证 SSL 证书
   - 注意数据传输安全

## 📞 技术支持

如果遇到问题，请：

1. 运行 `./check-deps.sh` 检查依赖
2. 查看错误信息和日志
3. 确认配置文件格式正确
4. 检查网络连接和 API 密钥

## 📝 更新日志

- **v1.0.0** - 初始版本，支持基本的 SQL 优化功能
- 支持多种 AI 模型配置
- 提供完整的依赖检查和安装脚本
- 包含详细的用户文档

---

**注意**：这个二进制文件是为 Linux x86_64 系统编译的，在其他架构或系统上可能无法运行。 