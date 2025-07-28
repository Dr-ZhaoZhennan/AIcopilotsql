@echo off
echo ========================================
echo 正在编译 SQL AI Copilot 项目...
echo ========================================

REM 检查是否安装了 MinGW
where g++ >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误：未找到 g++ 编译器
    echo 请安装 MinGW-w64 或 MSYS2
    echo 下载地址：https://www.mingw-w64.org/downloads/
    pause
    exit /b 1
)

REM 创建输出目录
if not exist "dist" mkdir dist
if not exist "dist\config" mkdir dist\config

REM 编译项目
echo 正在编译源代码...
g++ -std=c++11 -Iinclude -o dist\sql_ai_copilot.exe ^
    main.cpp ^
    src/agent1_input/agent1_input.cpp ^
    src/agent2_diagnose/agent2_diagnose.cpp ^
    src/agent3_strategy/agent3_strategy.cpp ^
    src/agent4_report/agent4_report.cpp ^
    src/agent5_interactive/agent5_interactive.cpp ^
    src/ai_engine/ai_engine.cpp ^
    src/utils/utils.cpp ^
    -lcurl

if %errorlevel% neq 0 (
    echo 编译失败！
    pause
    exit /b 1
)

REM 复制配置文件
echo 正在复制配置文件...
copy config\ai_models.json dist\config\ >nul

REM 复制头文件（用于参考）
if not exist "dist\include" mkdir dist\include
xcopy include\* dist\include\ /Y /Q >nul

REM 创建启动脚本
echo 正在创建启动脚本...
(
echo @echo off
echo echo ========================================
echo echo SQL AI Copilot 启动中...
echo echo ========================================
echo.
echo REM 检查配置文件
echo if not exist "config\ai_models.json" ^(
echo     echo 错误：未找到配置文件 config\ai_models.json
echo     echo 请确保配置文件存在
echo     pause
echo     exit /b 1
echo ^)
echo.
echo REM 启动程序
echo sql_ai_copilot.exe
echo.
echo REM 如果程序异常退出，暂停以便查看错误信息
echo if %errorlevel% neq 0 ^(
echo     echo.
echo     echo 程序异常退出，错误代码：%%errorlevel%%
echo     pause
echo ^)
) > dist\start.bat

REM 创建说明文件
echo 正在创建说明文件...
(
echo SQL AI Copilot - Windows 可执行文件包
echo ========================================
echo.
echo 文件说明：
echo - sql_ai_copilot.exe：主程序
echo - start.bat：启动脚本
echo - config\ai_models.json：AI模型配置文件
echo - include\：头文件（参考用）
echo.
echo 使用方法：
echo 1. 双击 start.bat 启动程序
echo 2. 或直接运行 sql_ai_copilot.exe
echo.
echo 注意事项：
echo - 确保 config\ai_models.json 文件存在且配置正确
echo - 需要网络连接以调用AI API
echo - 如果遇到问题，请检查配置文件中的API密钥
echo.
echo 系统要求：
echo - Windows 10/11
echo - 网络连接
echo - 至少 50MB 可用内存
echo.
echo 技术支持：
echo 如有问题，请检查：
echo 1. 网络连接是否正常
echo 2. API密钥是否有效
echo 3. 配置文件格式是否正确
) > dist\README.txt

echo.
echo ========================================
echo 编译完成！
echo ========================================
echo.
echo 可执行文件已生成在 dist 文件夹中：
echo - sql_ai_copilot.exe
echo - start.bat （推荐使用此脚本启动）
echo - config\ai_models.json
echo - README.txt
echo.
echo 使用方法：
echo 1. 进入 dist 文件夹
echo 2. 双击 start.bat 启动程序
echo.
pause 