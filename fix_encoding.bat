@echo off
chcp 65001 >nul
echo ========================================
echo SQL AI Copilot - 编码修复工具
echo ========================================

echo 检测到字符编码问题，正在修复...
echo.

REM 检查当前代码页
echo 当前代码页：
chcp
echo.

REM 设置UTF-8编码
echo 正在设置UTF-8编码...
chcp 65001 >nul
if %errorlevel% equ 0 (
    echo ✓ UTF-8编码设置成功
) else (
    echo ✗ UTF-8编码设置失败
)

echo.
echo 如果仍有乱码问题，请尝试以下解决方案：
echo.
echo 1. 手动设置代码页：
echo    chcp 65001
echo.
echo 2. 使用PowerShell运行：
echo    powershell -Command "& .\启动程序.bat"
echo.
echo 3. 修改Windows区域设置：
echo    - 控制面板 -> 区域 -> 管理 -> 更改系统区域设置
echo    - 勾选"使用 Unicode UTF-8 提供全球语言支持"
echo    - 重启计算机
echo.
echo 4. 使用英文版本（如果可用）
echo.
pause 