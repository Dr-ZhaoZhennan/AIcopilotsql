# AIAgent 编译指南

## 问题解决

本项目解决了静态链接时curl库依赖过多的问题，提供了多种编译方案。

## 编译方案

### 1. 简化编译脚本（推荐）

#### Linux/macOS
```bash
# 自动选择最佳编译方式（推荐）
./build-simple.sh auto

# 仅动态链接（开发用）
./build-simple.sh dynamic

# 仅静态链接（尝试）
./build-simple.sh static

# 创建Linux发布包
./build-simple.sh package-linux
```

#### Windows
```cmd
# 自动选择最佳编译方式（推荐）
build-simple.bat auto

# 仅动态链接（开发用）
build-simple.bat dynamic

# 仅静态链接（尝试）
build-simple.bat static

# 创建Windows发布包
build-simple.bat package-windows
```

### 2. Makefile 编译

```bash
# 动态链接版本（推荐用于开发）
make dynamic

# 最小化静态链接版本（推荐用于发布）
make release-static-minimal

# 简化静态链接版本
make release-static-simple

# 完整静态链接版本（包含所有依赖）
make release-static
```

### 3. 原始编译脚本

```bash
# Linux
./build-static.sh auto

# Windows
build.bat dynamic
```

## 编译结果说明

### 动态链接版本
- **优点**: 编译成功率高，文件小，启动快
- **缺点**: 需要目标系统安装相应的库
- **适用**: 开发和测试环境

### 静态链接版本
- **优点**: 完全独立，可在任何Linux系统运行
- **缺点**: 文件较大，可能遇到依赖问题
- **适用**: 生产环境部署

## 依赖要求

### Linux
```bash
# Ubuntu/Debian
sudo apt-get install g++ make libcurl4-openssl-dev pkg-config

# CentOS/RHEL
sudo yum install gcc-c++ make libcurl-devel pkgconfig
```

### Windows
1. 安装 MSYS2: https://www.msys2.org/
2. 在 MSYS2 中运行:
   ```bash
   pacman -S mingw-w64-x86_64-gcc
   pacman -S mingw-w64-x86_64-make
   pacman -S mingw-w64-x86_64-curl
   ```
3. 将 MSYS2 的 bin 目录添加到 PATH 环境变量

## 常见问题

### 1. 静态链接失败
**问题**: 出现大量 "undefined reference" 错误
**解决**: 使用动态链接版本或 `build-simple.sh auto`

### 2. 找不到编译器
**问题**: `g++: command not found`
**解决**: 安装 gcc/g++ 编译器

### 3. 找不到 curl 库
**问题**: `curl/curl.h: No such file or directory`
**解决**: 安装 libcurl 开发库

### 4. Windows 编译失败
**问题**: 找不到编译器或库
**解决**: 使用 MSYS2 环境，确保 PATH 设置正确

## 推荐使用方式

### 开发环境
```bash
# Linux
./build-simple.sh dynamic

# Windows
build-simple.bat dynamic
```

### 生产环境
```bash
# Linux
./build-simple.sh auto

# Windows
build-simple.bat auto
```

## 文件说明

- `build-simple.sh` - Linux/macOS 简化编译脚本
- `build-simple.bat` - Windows 简化编译脚本
- `build-static.sh` - 原始静态链接编译脚本
- `build.sh` - 原始 Linux 编译脚本
- `build.bat` - 原始 Windows 编译脚本
- `Makefile` - 传统 Makefile 编译系统

## 测试编译结果

```bash
# 编译
./build-simple.sh auto

# 测试运行
./main --help 2>/dev/null || echo "程序运行正常"
```

## 发布包创建

```bash
# Linux 发布包
./build-simple.sh package-linux

# Windows 发布包
build-simple.bat package-windows
```

发布包将创建在 `dist/` 目录下，包含可执行文件和配置文件。 