@echo off
REM AIAgent 构建脚本 (Windows)
REM 使用方法: build.bat [选项]

setlocal enabledelayedexpansion

REM 设置颜色代码
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM 打印带颜色的消息
:print_info
echo %BLUE%[INFO]%NC% %~1
goto :eof

:print_success
echo %GREEN%[SUCCESS]%NC% %~1
goto :eof

:print_warning
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

:print_error
echo %RED%[ERROR]%NC% %~1
goto :eof

REM 检查依赖
:check_dependencies
call :print_info "检查依赖..."

REM 检查 g++ 编译器
where g++ >nul 2>&1
if %errorlevel% neq 0 (
    call :print_error "找不到 g++ 编译器"
    call :print_info "请安装 MSYS2: https://www.msys2.org/"
    call :print_info "然后在 MSYS2 中运行: pacman -S mingw-w64-x86_64-gcc"
    exit /b 1
)

REM 检查 make
where make >nul 2>&1
if %errorlevel% neq 0 (
    call :print_error "找不到 make"
    call :print_info "请安装 MSYS2: https://www.msys2.org/"
    call :print_info "然后在 MSYS2 中运行: pacman -S mingw-w64-x86_64-make"
    exit /b 1
)

REM 检查 nlohmann/json
if not exist "third_party\json.hpp" (
    call :print_error "找不到 nlohmann/json 库"
    call :print_info "正在下载..."
    if not exist "third_party" mkdir third_party
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp' -OutFile 'third_party\json.hpp'"
    if %errorlevel% neq 0 (
        call :print_error "下载失败，请手动下载 json.hpp 到 third_party 目录"
        exit /b 1
    )
)

call :print_success "所有依赖检查通过！"
goto :eof

REM 安装依赖说明
:install_deps_windows
call :print_info "Windows 依赖安装说明："
echo.
echo 1. 安装 MSYS2: https://www.msys2.org/
echo 2. 在 MSYS2 中运行以下命令：
echo    pacman -S mingw-w64-x86_64-gcc
echo    pacman -S mingw-w64-x86_64-make
echo    pacman -S mingw-w64-x86_64-curl
echo 3. 将 MSYS2 的 bin 目录添加到 PATH 环境变量
echo    （通常是 C:\msys64\mingw64\bin）
echo.
call :print_info "安装完成后重新运行此脚本"
goto :eof

REM 清理构建文件
:clean
call :print_info "清理构建文件..."
if exist "main.exe" del "main.exe"
if exist "*.o" del "*.o"
for /d /r "src" %%d in (*) do (
    if exist "%%d\*.o" del "%%d\*.o"
)
call :print_success "清理完成！"
goto :eof

REM 编译项目
:build
set "build_type=%~1"
if "%build_type%"=="" set "build_type=release"

call :print_info "开始编译 (%build_type% 版本)..."

if "%build_type%"=="debug" (
    make debug
) else if "%build_type%"=="release" (
    make release
) else (
    make
)

if %errorlevel% neq 0 (
    call :print_error "编译失败！"
    exit /b 1
)

call :print_success "编译完成！"
goto :eof

REM 运行程序
:run
if not exist "main.exe" (
    call :print_warning "可执行文件不存在，正在编译..."
    call :build
)

call :print_info "运行程序..."
main.exe
goto :eof

REM 显示帮助信息
:show_help
echo AIAgent 构建脚本 (Windows)
echo.
echo 使用方法: %0 [选项]
echo.
echo 选项:
echo   build [type]     - 编译项目 (type: debug/release, 默认: release)
echo   clean            - 清理构建文件
echo   run              - 编译并运行程序
echo   check-deps       - 检查依赖
echo   install-deps     - 显示依赖安装说明
echo   help             - 显示此帮助信息
echo.
echo 示例:
echo   %0 build debug   - 编译调试版本
echo   %0 build release - 编译发布版本
echo   %0 run           - 编译并运行
echo.
goto :eof

REM 主函数
:main
if "%1"=="" goto :show_help

if "%1"=="build" (
    call :check_dependencies
    call :build %2
) else if "%1"=="clean" (
    call :clean
) else if "%1"=="run" (
    call :check_dependencies
    call :run
) else if "%1"=="check-deps" (
    call :check_dependencies
) else if "%1"=="install-deps" (
    call :install_deps_windows
) else if "%1"=="help" (
    call :show_help
) else (
    call :print_error "未知选项: %1"
    call :show_help
    exit /b 1
)

goto :eof

REM 运行主函数
call :main %* 