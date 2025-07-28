@echo off
REM 设置UTF-8编码
chcp 65001 >nul 2>&1
title SQL AI Copilot - 中文版
color 0A

echo ========================================
echo    SQL AI Copilot 启动中...
echo ========================================
echo.

REM 检查配置文件
if not exist "config\ai_models.json" (
    echo [错误] 未找到配置文件 config\ai_models.json
    echo 请确保配置文件存在且格式正确
    echo.
    pause
    exit /b 1
)

REM 检查网络连接（可选）
echo [信息] 正在检查网络连接...
ping -n 1 api.deepseek.com >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] 网络连接可能有问题，AI功能可能无法使用
    echo.
)

REM 启动程序
echo [信息] 启动主程序...
sql_ai_copilot.exe

REM 检查程序退出状态
if %errorlevel% neq 0 (
    echo.
    echo [错误] 程序异常退出，错误代码：%errorlevel%
    echo 可能的原因：
    echo 1. 网络连接问题
    echo 2. API密钥无效
    echo 3. 配置文件格式错误
    echo.
    pause
)

echo.
echo [信息] 程序已退出
pause 