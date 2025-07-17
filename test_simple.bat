@echo off
echo 开始测试...
cd /d "d:\Download-forLRJ"
echo 当前目录: %CD%

echo 创建简单测试PowerShell脚本...
echo Write-Host "Hello from PowerShell!" -ForegroundColor Green > test_simple.ps1
echo $ErrorActionPreference = "Continue" >> test_simple.ps1
echo Write-Host "测试完成" -ForegroundColor Blue >> test_simple.ps1

echo 运行PowerShell脚本...
powershell -ExecutionPolicy Bypass -File test_simple.ps1

echo 脚本运行完成!
pause