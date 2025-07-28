@echo off
echo 清理构建文件...

:: 删除构建目录
if exist build (
    echo 删除 build 目录...
    rmdir /s /q build
)

:: 删除可执行文件
if exist sql_optimizer.exe (
    echo 删除 sql_optimizer.exe...
    del sql_optimizer.exe
)

echo 清理完成！
pause 