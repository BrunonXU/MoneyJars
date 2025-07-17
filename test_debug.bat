@echo off
echo 开始调试...
cd /d "d:\Download-forLRJ"
echo 当前目录: %CD%
echo 检查磁盘空间...
for /f "tokens=3" %%i in ('dir /-c 2^>nul ^| find "bytes free"') do set freeSpace=%%i
echo 磁盘空间变量: %freeSpace%
set /a freeSpaceGB=100
echo 磁盘空间GB: %freeSpaceGB%
pause