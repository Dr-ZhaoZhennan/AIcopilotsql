@echo off
chcp 65001 >nul
echo ========================================
echo SQL AI Copilot - UTF-8版本编译工具
echo ========================================

echo 正在编译支持UTF-8编码的版本...
echo.

REM 检查编译器
where g++ >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误：未找到 g++ 编译器
    echo 请安装 MinGW-w64 或 MSYS2
    pause
    exit /b 1
)

REM 编译UTF-8版本
echo 编译UTF-8版本...
g++ -std=c++11 -Iinclude -o "SQL_AI_Copilot_Simple\sql_ai_copilot_utf8.exe" ^
    main_utf8.cpp ^
    src/agent1_input/agent1_input.cpp ^
    src/agent2_diagnose/agent2_diagnose.cpp ^
    src/agent3_strategy/agent3_strategy.cpp ^
    src/agent4_report/agent4_report.cpp ^
    src/agent5_interactive/agent5_interactive.cpp ^
    src/ai_engine/ai_engine_simple.cpp ^
    src/utils/utils.cpp ^
    -lwinhttp

if %errorlevel% neq 0 (
    echo 编译失败！请检查源代码
    pause
    exit /b 1
)

echo ✓ UTF-8版本编译成功！

REM 创建UTF-8版本的启动脚本
echo 创建UTF-8版本启动脚本...
(
echo @echo off
echo REM 设置UTF-8编码
echo chcp 65001 ^>nul 2^>^&1
echo title SQL AI Copilot - UTF-8版本
echo color 0A
echo.
echo echo ========================================
echo echo    SQL AI Copilot UTF-8版本启动中...
echo echo ========================================
echo echo.
echo.
echo REM 检查配置文件
echo if not exist "config\ai_models.json" ^(
echo     echo [错误] 未找到配置文件 config\ai_models.json
echo     echo 请确保配置文件存在且格式正确
echo     echo.
echo     pause
echo     exit /b 1
echo ^)
echo.
echo REM 检查网络连接（可选）
echo echo [信息] 正在检查网络连接...
echo ping -n 1 api.deepseek.com ^>nul 2^>^&1
echo if %%errorlevel%% neq 0 ^(
echo     echo [警告] 网络连接可能有问题，AI功能可能无法使用
echo     echo.
echo ^)
echo.
echo REM 启动程序
echo echo [信息] 启动UTF-8版本主程序...
echo sql_ai_copilot_utf8.exe
echo.
echo REM 检查程序退出状态
echo if %%errorlevel%% neq 0 ^(
echo     echo.
echo     echo [错误] 程序异常退出，错误代码：%%errorlevel%%
echo     echo 可能的原因：
echo     echo 1. 网络连接问题
echo     echo 2. API密钥无效
echo     echo 3. 配置文件格式错误
echo     echo.
echo     pause
echo ^)
echo.
echo echo [信息] 程序已退出
echo pause
) > "SQL_AI_Copilot_Simple\启动程序_UTF8.bat"

echo ✓ UTF-8版本启动脚本创建完成！

echo.
echo ========================================
echo UTF-8版本编译完成！
echo ========================================
echo.
echo 生成文件：
echo - sql_ai_copilot_utf8.exe （UTF-8版本主程序）
echo - 启动程序_UTF8.bat （UTF-8版本启动脚本）
echo.
echo 使用方法：
echo 1. 双击"启动程序_UTF8.bat"
echo 2. 或直接运行 sql_ai_copilot_utf8.exe
echo.
echo 此版本专门解决中文显示乱码问题！
echo ========================================

pause 