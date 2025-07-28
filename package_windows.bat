@echo off
setlocal enabledelayedexpansion

echo ========================================
echo SQL AI Copilot - Windows 打包工具
echo ========================================

REM 设置颜色
color 0A

REM 检查系统要求
echo [1/6] 检查系统要求...

REM 检查Windows版本
ver | findstr /i "10\.0\|11\.0" >nul
if %errorlevel% neq 0 (
    echo 警告：建议在 Windows 10/11 上运行
)

REM 检查编译器
where g++ >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误：未找到 g++ 编译器
    echo.
    echo 请安装以下任一编译器：
    echo 1. MinGW-w64: https://www.mingw-w64.org/downloads/
    echo 2. MSYS2: https://www.msys2.org/
    echo 3. Visual Studio Build Tools
    echo.
    echo 安装后请确保 g++ 在 PATH 环境变量中
    pause
    exit /b 1
)

echo ✓ 编译器检查通过

REM 检查curl库
echo [2/6] 检查依赖库...
g++ -lcurl -o test_curl.exe 2>nul
if exist test_curl.exe (
    del test_curl.exe
    echo ✓ libcurl 库可用
) else (
    echo 警告：libcurl 库可能不可用，将尝试静态编译
)

REM 创建输出目录结构
echo [3/6] 创建输出目录...
if exist "SQL_AI_Copilot_Windows" rmdir /s /q "SQL_AI_Copilot_Windows"
mkdir "SQL_AI_Copilot_Windows"
mkdir "SQL_AI_Copilot_Windows\config"
mkdir "SQL_AI_Copilot_Windows\include"
mkdir "SQL_AI_Copilot_Windows\docs"

REM 编译项目
echo [4/6] 编译项目...

REM 尝试静态编译
echo 尝试静态编译（推荐）...
g++ -std=c++11 -Iinclude -static -static-libgcc -static-libstdc++ -o "SQL_AI_Copilot_Windows\sql_ai_copilot.exe" ^
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
    echo 静态编译失败，尝试动态编译...
    g++ -std=c++11 -Iinclude -o "SQL_AI_Copilot_Windows\sql_ai_copilot.exe" ^
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
        echo 编译失败！请检查源代码和依赖库
        pause
        exit /b 1
    )
    echo ✓ 动态编译成功
) else (
    echo ✓ 静态编译成功
)

REM 复制必要文件
echo [5/6] 复制必要文件...

REM 复制配置文件
copy "config\ai_models.json" "SQL_AI_Copilot_Windows\config\" >nul

REM 复制头文件
xcopy "include\*" "SQL_AI_Copilot_Windows\include\" /Y /Q >nul

REM 复制原始README
copy "README.md" "SQL_AI_Copilot_Windows\docs\原始README.md" >nul

REM 创建启动脚本
echo 创建启动脚本...
(
echo @echo off
echo title SQL AI Copilot
echo color 0A
echo.
echo echo ========================================
echo echo    SQL AI Copilot 启动中...
echo echo ========================================
echo echo.
echo.
echo REM 检查配置文件
echo if not exist "config\ai_models.json" ^(
echo     echo 错误：未找到配置文件 config\ai_models.json
echo     echo 请确保配置文件存在且格式正确
echo     echo.
echo     pause
echo     exit /b 1
echo ^)
echo.
echo REM 检查网络连接（可选）
echo echo 正在检查网络连接...
echo ping -n 1 api.deepseek.com ^>nul 2^>^&1
echo if %%errorlevel%% neq 0 ^(
echo     echo 警告：网络连接可能有问题，AI功能可能无法使用
echo     echo.
echo ^)
echo.
echo REM 启动程序
echo echo 启动主程序...
echo sql_ai_copilot.exe
echo.
echo REM 检查程序退出状态
echo if %%errorlevel%% neq 0 ^(
echo     echo.
echo     echo 程序异常退出，错误代码：%%errorlevel%%
echo     echo 可能的原因：
echo     echo 1. 网络连接问题
echo     echo 2. API密钥无效
echo     echo 3. 配置文件格式错误
echo     echo.
echo     pause
echo ^)
echo.
echo echo 程序已退出
echo pause
) > "SQL_AI_Copilot_Windows\启动程序.bat"

REM 创建详细说明文件
echo 创建说明文件...
(
echo SQL AI Copilot - Windows 可执行文件包
echo ========================================
echo.
echo 版本信息：
echo - 编译时间：%date% %time%
echo - 目标系统：Windows 10/11
echo - 编译器：MinGW-w64
echo.
echo 文件说明：
echo ==========
echo - sql_ai_copilot.exe：主程序（可执行文件）
echo - 启动程序.bat：推荐启动方式（包含错误检查）
echo - config\ai_models.json：AI模型配置文件
echo - include\：头文件（开发参考用）
echo - docs\：文档文件夹
echo.
echo 使用方法：
echo ==========
echo 1. 双击"启动程序.bat"（推荐）
echo 2. 或直接运行 sql_ai_copilot.exe
echo.
echo 首次使用：
echo ==========
echo 1. 确保网络连接正常
echo 2. 检查 config\ai_models.json 中的API密钥
echo 3. 运行程序并按照提示操作
echo.
echo 功能说明：
echo ==========
echo - SQL语句输入（支持多行）
echo - 执行计划分析
echo - AI智能优化建议
echo - 多轮交互问答
echo.
echo 系统要求：
echo ==========
echo - Windows 10/11
echo - 网络连接
echo - 至少 50MB 可用内存
echo - 支持 HTTPS 连接
echo.
echo 故障排除：
echo ==========
echo 1. 网络问题：
echo    - 检查防火墙设置
echo    - 确认网络连接正常
echo.
echo 2. API问题：
echo    - 检查 config\ai_models.json 中的API密钥
echo    - 确认API密钥有效且有足够配额
echo.
echo 3. 程序崩溃：
echo    - 检查配置文件格式
echo    - 确认系统兼容性
echo    - 查看错误代码
echo.
echo 技术支持：
echo ==========
echo 如遇到问题，请提供以下信息：
echo - 错误信息或错误代码
echo - 操作系统版本
echo - 网络连接状态
echo - 配置文件内容（隐藏API密钥）
echo.
echo 更新说明：
echo ==========
echo 如需更新程序，请：
echo 1. 备份当前配置文件
echo 2. 下载新版本
echo 3. 替换可执行文件
echo 4. 恢复配置文件
echo.
echo ========================================
echo 感谢使用 SQL AI Copilot！
echo ========================================
) > "SQL_AI_Copilot_Windows\使用说明.txt"

REM 创建快速配置脚本
echo 创建配置脚本...
(
echo @echo off
echo echo ========================================
echo echo SQL AI Copilot - 配置向导
echo echo ========================================
echo echo.
echo echo 此脚本将帮助您配置API密钥
echo echo.
echo if not exist "config\ai_models.json" ^(
echo     echo 错误：配置文件不存在
echo     pause
echo     exit /b 1
echo ^)
echo.
echo echo 当前配置：
echo type "config\ai_models.json"
echo echo.
echo echo 如需修改配置，请编辑 config\ai_models.json 文件
echo echo.
echo pause
) > "SQL_AI_Copilot_Windows\配置向导.bat"

REM 创建版本信息文件
echo 创建版本信息...
(
echo SQL AI Copilot
echo 版本：1.0.0
echo 编译时间：%date% %time%
echo 目标平台：Windows x64
echo 编译器：MinGW-w64
echo.
echo 功能特性：
echo - GaussDB SQL优化分析
echo - AI智能建议生成
echo - 多轮交互问答
echo - 执行计划分析
echo.
echo 依赖库：
echo - libcurl（网络请求）
echo - libstdc++（C++标准库）
) > "SQL_AI_Copilot_Windows\版本信息.txt"

echo [6/6] 完成打包！

echo.
echo ========================================
echo 打包完成！
echo ========================================
echo.
echo 输出文件夹：SQL_AI_Copilot_Windows
echo.
echo 包含文件：
echo - sql_ai_copilot.exe （主程序）
echo - 启动程序.bat （推荐启动方式）
echo - 配置向导.bat （配置帮助）
echo - 使用说明.txt （详细说明）
echo - 版本信息.txt （版本信息）
echo - config\ai_models.json （配置文件）
echo - include\ （头文件）
echo - docs\ （文档）
echo.
echo 使用方法：
echo 1. 进入 SQL_AI_Copilot_Windows 文件夹
echo 2. 双击"启动程序.bat"
echo 3. 按照程序提示操作
echo.
echo 注意事项：
echo - 首次使用请检查网络连接
echo - 确保API密钥配置正确
echo - 建议使用启动脚本而非直接运行exe
echo.
echo 打包完成！可以分发 SQL_AI_Copilot_Windows 文件夹
echo ========================================

pause 