@echo off
echo ========================================
echo SQL AI Copilot - 配置向导
echo ========================================
echo.
echo 此脚本将帮助您配置API密钥
echo.
if not exist "config\ai_models.json" (
    echo 错误：配置文件不存在
    pause
    exit /b 1
)

echo 当前配置：
type "config\ai_models.json"
echo.
echo 如需修改配置，请编辑 config\ai_models.json 文件
echo.
pause
