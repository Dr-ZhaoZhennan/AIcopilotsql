# AIAgent EulerOS 专用版本使用指南

## 🎯 专为 EulerOS release 2.0 优化

这是专门为 EulerOS release 2.0 系统优化的 AIAgent 版本，针对国产化环境进行了特殊优化。

## 📦 文件说明

EulerOS 专用包包含以下文件：

```
AIAgent-euleros-2025.07.28/
├── AIAgent                    # 主程序可执行文件 (230KB)
├── config/                    # 配置文件目录
│   └── ai_models.json       # AI 模型配置
├── install-euleros.sh        # EulerOS 专用安装脚本
├── check-euleros-deps.sh     # EulerOS 依赖检查脚本
├── run-euleros.sh            # EulerOS 专用运行脚本
└── README-EulerOS.txt        # EulerOS 专用说明文档
```

## 🚀 快速开始

### 方法一：直接运行（推荐）

1. **解压压缩包**
   ```bash
   tar -xzf AIAgent-euleros-2025.07.28.tar.gz
   cd AIAgent-euleros-2025.07.28
   ```

2. **检查 EulerOS 依赖**
   ```bash
   ./check-euleros-deps.sh
   ```

3. **运行程序**
   ```bash
   ./AIAgent
   # 或者使用 EulerOS 专用运行脚本
   ./run-euleros.sh
   ```

### 方法二：安装到 EulerOS 系统

1. **安装到系统目录**
   ```bash
   sudo ./install-euleros.sh
   ```

2. **全局运行**
   ```bash
   AIAgent
   ```

3. **可选：安装为系统服务**
   ```bash
   sudo cp /tmp/aiagent.service /etc/systemd/system/
   sudo systemctl enable aiagent.service
   sudo systemctl start aiagent.service
   ```

## 📋 EulerOS 系统要求

### 最低要求
- EulerOS release 2.0 或更高版本
- x86_64 或 aarch64 架构
- 基本的 C++ 运行时库
- 网络连接（用于 AI API 调用）

### EulerOS 特定依赖
程序需要以下库文件（EulerOS 通常已预装）：
- `libcurl.so.4` - HTTP 客户端库
- `libssl.so.10` - SSL/TLS 加密库（EulerOS 版本）
- `libcrypto.so.10` - 加密库（EulerOS 版本）
- `libstdc++.so.6` - C++ 标准库
- `libc.so.6` - C 标准库

### 安装缺失依赖

**EulerOS 系统：**
```bash
# 更新系统
sudo yum update

# 安装基本依赖
sudo yum install libcurl openssl-libs libstdc++

# 安装开发库（如果需要重新编译）
sudo yum install libcurl-devel openssl-devel gcc-c++ make
```

## 🔧 EulerOS 特定配置

### 系统服务配置
EulerOS 支持 systemd 服务管理，可以安装为系统服务：

```bash
# 安装为系统服务
sudo ./install-euleros.sh

# 启用服务
sudo systemctl enable aiagent.service

# 启动服务
sudo systemctl start aiagent.service

# 查看服务状态
sudo systemctl status aiagent.service
```

### 防火墙配置
如果遇到网络连接问题，可能需要配置防火墙：

```bash
# 检查防火墙状态
sudo systemctl status firewalld

# 如果需要，允许 AIAgent 的网络访问
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

## 📖 EulerOS 使用教程

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

### EulerOS 特定功能

- **国产化环境优化**：针对 EulerOS 的库版本进行了优化
- **systemd 服务支持**：可以安装为系统服务
- **yum 包管理器兼容**：使用 yum 安装依赖
- **SELinux 兼容**：考虑了 SELinux 安全策略

## 🛠️ EulerOS 故障排除

### 常见问题

1. **权限错误**
   ```bash
   chmod +x AIAgent
   chmod +x *.sh
   ```

2. **依赖库缺失**
   ```bash
   ./check-euleros-deps.sh
   # 根据提示安装缺失的库
   sudo yum install libcurl openssl-libs libstdc++
   ```

3. **SELinux 问题**
   ```bash
   # 检查 SELinux 状态
   getenforce
   
   # 如果需要，临时禁用 SELinux
   sudo setenforce 0
   
   # 或者配置 SELinux 策略
   sudo semanage fcontext -a -t bin_t "/usr/local/bin/AIAgent"
   sudo restorecon -v /usr/local/bin/AIAgent
   ```

4. **网络连接问题**
   ```bash
   # 检查网络连接
   ping api.openai.com
   
   # 检查防火墙
   sudo systemctl status firewalld
   
   # 检查 DNS 解析
   nslookup api.openai.com
   ```

5. **配置文件错误**
   ```bash
   # 检查配置文件格式
   cat config/ai_models.json
   
   # 确认 API 密钥有效
   curl -H "Authorization: Bearer YOUR_API_KEY" \
        https://api.openai.com/v1/models
   ```

### EulerOS 特定调试

```bash
# 检查系统信息
cat /etc/euleros-release
cat /etc/redhat-release

# 检查库版本
ldd AIAgent

# 检查系统日志
sudo journalctl -u aiagent.service -f

# 检查 SELinux 日志
sudo ausearch -m AVC -ts recent
```

## 🔒 EulerOS 安全注意事项

### SELinux 配置
EulerOS 默认启用 SELinux，可能需要配置：

```bash
# 检查 SELinux 状态
sestatus

# 查看 AIAgent 的 SELinux 上下文
ls -Z /usr/local/bin/AIAgent

# 如果需要，设置正确的上下文
sudo semanage fcontext -a -t bin_t "/usr/local/bin/AIAgent"
sudo restorecon -v /usr/local/bin/AIAgent
```

### 防火墙配置
```bash
# 检查防火墙规则
sudo firewall-cmd --list-all

# 添加 AIAgent 需要的端口（如果需要）
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

### 文件权限
```bash
# 设置正确的文件权限
sudo chown root:root /usr/local/bin/AIAgent
sudo chmod 755 /usr/local/bin/AIAgent
sudo chown -R root:root /usr/local/etc/AIAgent
sudo chmod -R 644 /usr/local/etc/AIAgent/*
```

## 📦 EulerOS 分发说明

### 创建 EulerOS 专用包
```bash
# 在项目根目录运行
./build-euleros.sh archive release
```

### 分发文件
分发时只需要以下文件：
- `AIAgent-euleros-2025.07.28.tar.gz` - 完整的 EulerOS 专用包

### 安装到其他 EulerOS 系统
```bash
# 在目标 EulerOS 系统上
tar -xzf AIAgent-euleros-2025.07.28.tar.gz
cd AIAgent-euleros-2025.07.28
./check-euleros-deps.sh
sudo ./install-euleros.sh
```

## 🎯 EulerOS 优化特性

### 编译优化
- 针对 EulerOS 的库版本进行了优化
- 支持 x86_64 和 aarch64 架构
- 使用 EulerOS 兼容的编译选项

### 系统集成
- 支持 systemd 服务管理
- 兼容 SELinux 安全策略
- 使用 yum 包管理器

### 国产化支持
- 针对国产化环境优化
- 支持国产 CPU 架构
- 兼容国产操作系统生态

## 📞 EulerOS 技术支持

如果遇到问题，请：

1. 运行 `./check-euleros-deps.sh` 检查依赖
2. 查看错误信息和日志
3. 确认配置文件格式正确
4. 检查网络连接和 API 密钥
5. 检查 SELinux 和防火墙设置

### EulerOS 特定支持
- 检查 `/etc/euleros-release` 系统信息
- 查看 `journalctl` 系统日志
- 检查 SELinux 审计日志
- 验证 yum 包管理器状态

## 📝 EulerOS 更新日志

- **v1.0.0** - 初始 EulerOS 版本
- 针对 EulerOS release 2.0 优化
- 支持 systemd 服务管理
- 兼容 SELinux 安全策略
- 使用 yum 包管理器
- 支持国产化环境

---

**注意**：这个版本专门为 EulerOS release 2.0 优化，在其他系统上可能无法正常运行。 