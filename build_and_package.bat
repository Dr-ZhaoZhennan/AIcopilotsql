@echo off
setlocal enabledelayedexpansion

title SQL AI Copilot - 构建与打包工具

echo ========================================
echo    SQL AI Copilot - 构建与打包工具
echo ========================================
echo.

:menu
echo 请选择操作：
echo.
echo 1. 检查环境依赖
echo 2. 安装编译工具（如需要）
echo 3. 编译项目
echo 4. 完整打包（推荐）
echo 5. 清理临时文件
echo 6. 退出
echo.
set /p choice="请输入选择 (1-6): "

if "%choice%"=="1" goto :check_env
if "%choice%"=="2" goto :install_deps
if "%choice%"=="3" goto :compile_only
if "%choice%"=="4" goto :full_package
if "%choice%"=="5" goto :clean
if "%choice%"=="6" goto :exit
goto :menu

:check_env
echo.
echo ========================================
echo 检查环境依赖...
echo ========================================

echo 检查 g++ 编译器...
where g++ >nul 2>nul
if %errorlevel% equ 0 (
    echo ✓ g++ 编译器已安装
    for /f "tokens=*" %%i in ('where g++') do echo   路径: %%i
) else (
    echo ✗ g++ 编译器未安装
)

echo.
echo 检查 libcurl 库...
g++ -lcurl -o test_curl.exe 2>nul
if exist test_curl.exe (
    del test_curl.exe
    echo ✓ libcurl 库可用
) else (
    echo ✗ libcurl 库不可用
)

echo.
echo 检查项目文件...
if exist "main.cpp" (
    echo ✓ 主程序文件存在
) else (
    echo ✗ 主程序文件不存在
)

if exist "config\ai_models.json" (
    echo ✓ 配置文件存在
) else (
    echo ✗ 配置文件不存在
)

echo.
echo 检查源代码文件...
set missing_files=0
for %%f in (src\agent1_input\agent1_input.cpp src\agent2_diagnose\agent2_diagnose.cpp src\agent3_strategy\agent3_strategy.cpp src\agent4_report\agent4_report.cpp src\agent5_interactive\agent5_interactive.cpp src\ai_engine\ai_engine.cpp src\utils\utils.cpp) do (
    if exist "%%f" (
        echo ✓ %%f
    ) else (
        echo ✗ %%f 缺失
        set /a missing_files+=1
    )
)

echo.
if %missing_files% gtr 0 (
    echo 警告：有 %missing_files% 个源文件缺失
) else (
    echo ✓ 所有源文件都存在
)

echo.
echo 环境检查完成！
pause
goto :menu

:install_deps
echo.
echo ========================================
echo 安装编译工具...
echo ========================================
call install_dependencies.bat
goto :menu

:compile_only
echo.
echo ========================================
echo 仅编译项目...
echo ========================================

echo 检查编译器...
where g++ >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误：未找到 g++ 编译器
    echo 请先运行选项 2 安装编译工具
    pause
    goto :menu
)

echo 开始编译...
g++ -std=c++11 -Iinclude -o sql_ai_copilot.exe ^
    main.cpp ^
    src/agent1_input/agent1_input.cpp ^
    src/agent2_diagnose/agent2_diagnose.cpp ^
    src/agent3_strategy/agent3_strategy.cpp ^
    src/agent4_report/agent4_report.cpp ^
    src/agent5_interactive/agent5_interactive.cpp ^
    src/ai_engine/ai_engine.cpp ^
    src/utils/utils.cpp ^
    -lcurl

if %errorlevel% equ 0 (
    echo.
    echo ✓ 编译成功！
    echo 生成文件：sql_ai_copilot.exe
    echo.
    echo 注意：这只是编译，没有打包配置文件
    echo 建议运行完整打包（选项 4）
) else (
    echo.
    echo ✗ 编译失败！
    echo 请检查错误信息并修复问题
)

pause
goto :menu

:full_package
echo.
echo ========================================
echo 完整打包项目...
echo ========================================

echo 检查编译器...
where g++ >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误：未找到 g++ 编译器
    echo 请先运行选项 2 安装编译工具
    pause
    goto :menu
)

echo 开始完整打包...
call package_windows.bat

echo.
echo 打包完成！请检查 SQL_AI_Copilot_Windows 文件夹
pause
goto :menu

:clean
echo.
echo ========================================
echo 清理临时文件...
echo ========================================

echo 删除编译生成的文件...
if exist "sql_ai_copilot.exe" (
    del "sql_ai_copilot.exe"
    echo ✓ 删除 sql_ai_copilot.exe
)

if exist "test_curl.exe" (
    del "test_curl.exe"
    echo ✓ 删除 test_curl.exe
)

if exist "dist" (
    rmdir /s /q "dist"
    echo ✓ 删除 dist 文件夹
)

if exist "SQL_AI_Copilot_Windows" (
    echo 是否删除 SQL_AI_Copilot_Windows 文件夹？(y/n)
    set /p confirm=
    if /i "%confirm%"=="y" (
        rmdir /s /q "SQL_AI_Copilot_Windows"
        echo ✓ 删除 SQL_AI_Copilot_Windows 文件夹
    )
)

echo.
echo ✓ 清理完成！
pause
goto :menu

:exit
echo.
echo 感谢使用 SQL AI Copilot 构建工具！
echo.
exit /b 0 