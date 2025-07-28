@echo off
echo ========================================
echo 安装 libcurl 开发库
echo ========================================

echo 检测到缺少 libcurl 开发库，正在尝试安装...
echo.

REM 检查是否使用 MSYS2
where pacman >nul 2>nul
if %errorlevel% equ 0 (
    echo 检测到 MSYS2 环境，使用 pacman 安装...
    echo.
    echo 正在安装 libcurl 开发库...
    pacman -S mingw-w64-x86_64-curl --noconfirm
    if %errorlevel% equ 0 (
        echo ✓ libcurl 安装成功！
        echo.
        echo 请重新运行 build_and_package.bat
        pause
        exit /b 0
    ) else (
        echo ✗ 自动安装失败
        goto :manual_install
    )
)

REM 检查是否使用 Chocolatey
where choco >nul 2>nul
if %errorlevel% equ 0 (
    echo 检测到 Chocolatey，尝试安装 curl...
    choco install curl --y
    if %errorlevel% equ 0 (
        echo ✓ curl 安装成功！
        echo.
        echo 请重新运行 build_and_package.bat
        pause
        exit /b 0
    ) else (
        echo ✗ 自动安装失败
        goto :manual_install
    )
)

:manual_install
echo.
echo ========================================
echo 手动安装 libcurl 说明
echo ========================================
echo.
echo 方法一：使用 MSYS2（推荐）
echo 1. 打开 MSYS2 终端
echo 2. 运行：pacman -S mingw-w64-x86_64-curl
echo 3. 重新打开命令提示符
echo.
echo 方法二：使用 vcpkg
echo 1. 安装 vcpkg: https://github.com/microsoft/vcpkg
echo 2. 运行：vcpkg install curl:x64-windows
echo 3. 设置环境变量：set VCPKG_ROOT=C:\vcpkg
echo.
echo 方法三：手动下载
echo 1. 访问 https://curl.se/windows/
echo 2. 下载 curl 开发包
echo 3. 解压到 C:\curl
echo 4. 设置环境变量：
echo    set CURL_ROOT=C:\curl
echo    set PATH=%PATH%;C:\curl\bin
echo    set INCLUDE=%INCLUDE%;C:\curl\include
echo    set LIB=%LIB%;C:\curl\lib
echo.
echo 方法四：使用 Visual Studio
echo 1. 安装 Visual Studio Build Tools
echo 2. 使用 vcpkg 安装：vcpkg install curl:x64-windows
echo.
echo 安装完成后，请重新运行 build_and_package.bat
echo.
pause 