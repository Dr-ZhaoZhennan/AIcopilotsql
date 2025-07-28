@echo off
setlocal enabledelayedexpansion

echo ========================================
echo SQL优化助手 - Windows构建脚本
echo ========================================

:: 检查是否安装了g++
where g++ >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到g++编译器
    echo 请安装MinGW或Visual Studio编译器
    pause
    exit /b 1
)

:: 创建构建目录
if not exist build mkdir build
if not exist build\src mkdir build\src
if not exist build\src\utils mkdir build\src\utils
if not exist build\src\agent1_input mkdir build\src\agent1_input
if not exist build\src\agent2_diagnose mkdir build\src\agent2_diagnose
if not exist build\src\agent3_strategy mkdir build\src\agent3_strategy
if not exist build\src\agent4_report mkdir build\src\agent4_report
if not exist build\src\agent5_interactive mkdir build\src\agent5_interactive
if not exist build\src\ai_engine mkdir build\src\ai_engine

:: 编译选项
set CXXFLAGS=-std=c++17 -Wall -Wextra -O2 -I./include
set LDFLAGS=-lcurl

echo 正在编译项目...

:: 编译各个模块
echo 编译 utils...
g++ %CXXFLAGS% -c src/utils/utils.cpp -o build/src/utils/utils.o
if %errorlevel% neq 0 (
    echo 编译 utils 失败
    pause
    exit /b 1
)

echo 编译 agent1_input...
g++ %CXXFLAGS% -c src/agent1_input/agent1_input.cpp -o build/src/agent1_input/agent1_input.o
if %errorlevel% neq 0 (
    echo 编译 agent1_input 失败
    pause
    exit /b 1
)

echo 编译 agent2_diagnose...
g++ %CXXFLAGS% -c src/agent2_diagnose/agent2_diagnose.cpp -o build/src/agent2_diagnose/agent2_diagnose.o
if %errorlevel% neq 0 (
    echo 编译 agent2_diagnose 失败
    pause
    exit /b 1
)

echo 编译 agent5_interactive...
g++ %CXXFLAGS% -c src/agent5_interactive/agent5_interactive.cpp -o build/src/agent5_interactive/agent5_interactive.o
if %errorlevel% neq 0 (
    echo 编译 agent5_interactive 失败
    pause
    exit /b 1
)

echo 编译 agent3_strategy...
g++ %CXXFLAGS% -c src/agent3_strategy/agent3_strategy.cpp -o build/src/agent3_strategy/agent3_strategy.o
if %errorlevel% neq 0 (
    echo 编译 agent3_strategy 失败
    pause
    exit /b 1
)

echo 编译 agent4_report...
g++ %CXXFLAGS% -c src/agent4_report/agent4_report.cpp -o build/src/agent4_report/agent4_report.o
if %errorlevel% neq 0 (
    echo 编译 agent4_report 失败
    pause
    exit /b 1
)

echo 编译 ai_engine...
g++ %CXXFLAGS% -c src/ai_engine/ai_engine.cpp -o build/src/ai_engine/ai_engine.o
if %errorlevel% neq 0 (
    echo 编译 ai_engine 失败
    pause
    exit /b 1
)

echo 编译 main.cpp...
g++ %CXXFLAGS% -c main.cpp -o build/main.o
if %errorlevel% neq 0 (
    echo 编译 main.cpp 失败
    pause
    exit /b 1
)

:: 链接可执行文件
echo 链接可执行文件...
g++ build/main.o build/src/utils/utils.o build/src/agent1_input/agent1_input.o build/src/agent2_diagnose/agent2_diagnose.o build/src/agent5_interactive/agent5_interactive.o build/src/agent3_strategy/agent3_strategy.o build/src/agent4_report/agent4_report.o build/src/ai_engine/ai_engine.o -o sql_optimizer.exe %LDFLAGS%
if %errorlevel% neq 0 (
    echo 链接失败
    pause
    exit /b 1
)

echo.
echo ========================================
echo 编译成功！可执行文件: sql_optimizer.exe
echo ========================================
echo.
echo 运行程序: sql_optimizer.exe
echo 清理构建文件: build.bat clean
echo.
pause 