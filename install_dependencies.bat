@echo off
echo ========================================
echo SQL AI Copilot - 依赖安装工具
echo ========================================

echo 此脚本将帮助您安装编译 SQL AI Copilot 所需的依赖
echo.

echo 检查当前环境...
where g++ >nul 2>nul
if %errorlevel% equ 0 (
    echo ✓ 已检测到 g++ 编译器
    echo 编译器路径：
    where g++
    echo.
    goto :check_curl
)

echo 未检测到 g++ 编译器
echo.
echo 请选择安装方式：
echo 1. 自动下载并安装 MinGW-w64（推荐）
echo 2. 手动安装说明
echo 3. 退出
echo.
set /p choice="请选择 (1-3): "

if "%choice%"=="1" goto :auto_install
if "%choice%"=="2" goto :manual_install
if "%choice%"=="3" goto :exit
goto :menu

:auto_install
echo.
echo 正在准备自动安装...
echo 注意：此过程需要网络连接，可能需要几分钟时间
echo.

REM 检查是否已安装 Chocolatey
where choco >nul 2>nul
if %errorlevel% neq 0 (
    echo 正在安装 Chocolatey 包管理器...
    echo 请以管理员身份运行此脚本
    echo.
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if %errorlevel% neq 0 (
        echo 安装 Chocolatey 失败，请手动安装
        goto :manual_install
    )
)

echo 正在安装 MinGW-w64...
choco install mingw -y
if %errorlevel% neq 0 (
    echo 自动安装失败，请手动安装
    goto :manual_install
)

echo 正在刷新环境变量...
refreshenv
if %errorlevel% neq 0 (
    echo 请重新打开命令提示符或重启系统
)

:check_curl
echo.
echo 检查 libcurl 库...
g++ -lcurl -o test_curl.exe 2>nul
if exist test_curl.exe (
    del test_curl.exe
    echo ✓ libcurl 库可用
    echo.
    echo 所有依赖已安装完成！
    echo 现在可以运行 package_windows.bat 来打包程序
    goto :exit
) else (
    echo 警告：libcurl 库不可用
    echo 将尝试静态编译，但可能需要额外的库文件
    echo.
    echo 建议安装 libcurl 开发库
)

goto :exit

:manual_install
echo.
echo ========================================
echo 手动安装说明
echo ========================================
echo.
echo 方法一：使用 MSYS2（推荐）
echo 1. 访问 https://www.msys2.org/
echo 2. 下载并安装 MSYS2
echo 3. 打开 MSYS2 终端
echo 4. 运行：pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-curl
echo 5. 将 MSYS2 的 bin 目录添加到 PATH 环境变量
echo.
echo 方法二：使用 MinGW-w64
echo 1. 访问 https://www.mingw-w64.org/downloads/
echo 2. 下载 MinGW-w64
echo 3. 解压到 C:\mingw64
echo 4. 将 C:\mingw64\bin 添加到 PATH 环境变量
echo.
echo 方法三：使用 Visual Studio Build Tools
echo 1. 访问 https://visualstudio.microsoft.com/downloads/
echo 2. 下载 Visual Studio Build Tools
echo 3. 安装 C++ 构建工具
echo 4. 使用 Developer Command Prompt
echo.
echo 安装完成后，请重新运行此脚本检查环境
echo.
pause
goto :exit

:exit
echo.
echo 感谢使用 SQL AI Copilot 依赖安装工具！
echo.
pause 