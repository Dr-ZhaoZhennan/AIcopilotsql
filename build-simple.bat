@echo off
setlocal enabledelayedexpansion

REM AIAgent Windows 简化编译脚本
REM 专门解决静态链接依赖问题

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM 颜色定义（Windows 10+ 支持）
if "%TERM%"=="xterm-256color" (
    set "RED=[91m"
    set "GREEN=[92m"
    set "YELLOW=[93m"
    set "BLUE=[94m"
    set "NC=[0m"
) else (
    set "RED="
    set "GREEN="
    set "YELLOW="
    set "BLUE="
    set "NC="
)

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

REM 检测编译器
:detect_compiler
call :print_info "检测编译器..."
where g++ >nul 2>&1
if %errorlevel% equ 0 (
    set "CXX=g++"
    call :print_success "找到 g++ 编译器"
    goto :eof
)

where cl >nul 2>&1
if %errorlevel% equ 0 (
    set "CXX=cl"
    call :print_success "找到 MSVC 编译器"
    goto :eof
)

call :print_error "找不到合适的编译器"
call :print_info "请安装 MinGW-w64 或 Visual Studio"
goto :eof

REM 检查依赖
:check_dependencies
call :print_info "检查编译依赖..."

REM 检查编译器
call :detect_compiler
if "%CXX%"=="" exit /b 1

REM 检查必要的头文件
if not exist "third_party\json.hpp" (
    call :print_error "找不到 nlohmann/json 库文件"
    exit /b 1
)
call :print_success "nlohmann/json 库: ✓"

call :print_success "所有依赖检查通过！"
goto :eof

REM 动态链接编译（推荐）
:compile_dynamic
set "target_name=%~1"

call :print_info "编译动态链接版本（推荐）..."

%CXX% -std=c++11 -Wall -Wextra -O2 -DNDEBUG -Iinclude -Ithird_party -o "%target_name%.exe" main.cpp src\agent1_input\agent1_input.cpp src\agent2_diagnose\agent2_diagnose.cpp src\agent3_strategy\agent3_strategy.cpp src\agent4_report\agent4_report.cpp src\agent5_interactive\agent5_interactive.cpp src\ai_engine\ai_engine.cpp src\utils\utils.cpp -lcurl -lssl -lcrypto -lz -ldl -lpthread

if %errorlevel% equ 0 (
    call :print_success "动态链接编译成功！"
    exit /b 0
) else (
    exit /b 1
)

REM 静态链接编译（仅基本功能）
:compile_static_basic
set "target_name=%~1"

call :print_info "尝试静态链接编译（仅基本功能）..."

%CXX% -std=c++11 -Wall -Wextra -O2 -DNDEBUG -static -Iinclude -Ithird_party -o "%target_name%.exe" main.cpp src\agent1_input\agent1_input.cpp src\agent2_diagnose\agent2_diagnose.cpp src\agent3_strategy\agent3_strategy.cpp src\agent4_report\agent4_report.cpp src\agent5_interactive\agent5_interactive.cpp src\ai_engine\ai_engine.cpp src\utils\utils.cpp -lcurl -lssl -lcrypto -lz -ldl -lpthread

if %errorlevel% equ 0 (
    call :print_success "静态链接编译成功！"
    exit /b 0
) else (
    exit /b 1
)

REM 编译函数
:compile
set "build_type=%~1"
set "target_name=%~2"

if "%build_type%"=="dynamic" (
    call :compile_dynamic "%target_name%"
) else if "%build_type%"=="static" (
    call :compile_static_basic "%target_name%"
) else if "%build_type%"=="auto" (
    REM 先尝试静态链接，失败则使用动态链接
    call :compile_static_basic "%target_name%"
    if %errorlevel% neq 0 (
        call :print_warning "静态链接失败，使用动态链接..."
        call :compile_dynamic "%target_name%"
    ) else (
        call :print_info "静态链接成功！"
    )
) else (
    call :print_error "未知的编译类型: %build_type%"
    exit /b 1
)

if %errorlevel% equ 0 (
    call :print_success "编译成功！可执行文件: %target_name%.exe"
    
    REM 显示文件信息
    if exist "%target_name%.exe" (
        for %%A in ("%target_name%.exe") do call :print_info "文件大小: %%~zA 字节"
        
        if "%build_type%"=="static" (
            call :print_info "这是一个静态链接的可执行文件"
        ) else (
            call :print_info "这是一个动态链接的可执行文件，需要目标系统安装相应的库"
        )
    )
) else (
    call :print_error "编译失败！"
    exit /b 1
)
goto :eof

REM 创建发布包
:create_package
set "build_type=%~1"
set "package_name=%~2"

call :print_info "创建发布包: %package_name%"

REM 编译
call :compile "%build_type%" "main"
if %errorlevel% neq 0 exit /b 1

REM 创建目录
if not exist "dist\%package_name%" mkdir "dist\%package_name%"

REM 复制文件
copy "main.exe" "dist\%package_name%\AIAgent.exe" >nul
if exist "config" xcopy "config" "dist\%package_name%\config\" /E /I /Y >nul
if exist "README.md" copy "README.md" "dist\%package_name%\" >nul
if exist "LICENSE" copy "LICENSE" "dist\%package_name%\" >nul

call :print_success "发布包创建完成: dist\%package_name%\"
goto :eof

REM 显示帮助信息
:show_help
echo AIAgent Windows 简化编译脚本
echo.
echo 用法: %0 [选项]
echo.
echo 选项:
echo   dynamic          - 编译动态链接版本（推荐用于开发）
echo   static           - 编译静态链接版本（仅基本功能）
echo   auto             - 自动选择最佳编译方式（推荐）
echo   package-windows  - 创建Windows发布包
echo   clean            - 清理编译文件
echo   help             - 显示此帮助信息
echo.
echo 推荐用法:
echo   Windows开发:   %0 dynamic
echo   Windows发布:   %0 auto
echo.
goto :eof

REM 清理函数
:clean
call :print_info "清理编译文件..."
if exist "main.exe" del "main.exe"
if exist "*.o" del "*.o"
if exist "src\*\*.o" del "src\*\*.o"
call :print_success "清理完成！"
goto :eof

REM 主函数
:main
if "%1"=="" goto :show_help

call :check_dependencies
if %errorlevel% neq 0 exit /b 1

if "%1"=="dynamic" (
    call :compile "dynamic" "main"
) else if "%1"=="static" (
    call :compile "static" "main"
) else if "%1"=="auto" (
    call :compile "auto" "main"
) else if "%1"=="package-windows" (
    call :create_package "auto" "AIAgent-windows"
) else if "%1"=="clean" (
    call :clean
) else if "%1"=="help" (
    call :show_help
) else (
    call :print_error "未知选项: %1"
    call :show_help
    exit /b 1
)

goto :eof

REM 执行主函数
call :main %* 