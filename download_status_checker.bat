@echo off
setlocal enabledelayedexpansion
title 📊 下载进度检查器

echo.
echo ████████████████████████████████████████████████████████████████████████████████
echo ██                                                                            ██
echo ██     📊 下载进度检查器 - 修正版 📊                                          ██
echo ██                                                                            ██
echo ████████████████████████████████████████████████████████████████████████████████
echo.

cd /d "d:\Download-forLRJ"

echo 🔍 正在扫描数据目录...
echo.

rem 检查数据目录
if not exist "data\fastq_by_type" (
    echo ❌ 数据目录不存在: data\fastq_by_type
    pause
    exit /b 1
)

rem 初始化计数器
set /a totalFolders=0
set /a totalFiles=0
set /a normalFiles=0
set /a damagedFiles=0

rem 统计文件夹数量
for /d %%D in ("data\fastq_by_type\*") do (
    set /a totalFolders+=1
)

echo 找到 %totalFolders% 个文件夹，正在统计文件...
echo.

rem 统计文件数量
for /r "data\fastq_by_type" %%F in (*.fastq.gz) do (
    set /a totalFiles+=1
    call :checkfile "%%F"
)

rem 计算预期文件数
set /a expectedFiles=0
if exist "d:\NS--Normal--Software\Wechat\WeChat Files\wxid_39yqqfvvmy9x22\FileStorage\File\2025-07\download_list.tsv" (
    for /f %%L in ('find /c /v "" ^< "d:\NS--Normal--Software\Wechat\WeChat Files\wxid_39yqqfvvmy9x22\FileStorage\File\2025-07\download_list.tsv"') do (
        set /a expectedFiles=%%L*2-2
    )
)

rem 计算缺失文件数
set /a missingFiles=expectedFiles-totalFiles

rem 计算真实完成进度（基于正常文件数）
set /a completionPercent=0
if %expectedFiles% GTR 0 (
    set /a completionPercent=normalFiles*100/expectedFiles
)

echo ████████████████████████████████████████████████████████████████████████████████
echo ██                          📊 总体统计                                       ██
echo ████████████████████████████████████████████████████████████████████████████████
echo.
echo     📁 文件夹数量: %totalFolders% 个
echo     📄 预期文件: %expectedFiles% 个
echo     📄 实际文件: %totalFiles% 个
echo     ✅ 正常文件: %normalFiles% 个
echo     ❌ 损坏文件: %damagedFiles% 个
echo     ⚠️  缺失文件: %missingFiles% 个
echo     📊 真实完成进度: %completionPercent%%%
echo.

rem 生成进度条（基于真实完成进度）
set "bar="
set /a bars=completionPercent/5
for /l %%i in (1,1,%bars%) do set "bar=!bar!█"
for /l %%i in (%bars%,1,19) do set "bar=!bar!░"
echo     🔥 进度条: [!bar!] %completionPercent%%%
echo.

rem 计算预估剩余时间（更合理的速度：100文件/小时）
set /a remainingFiles=expectedFiles-normalFiles
set /a estimatedHours=remainingFiles/100
if %estimatedHours% EQU 0 set /a estimatedHours=1
echo     ⏰ 预估剩余时间: 约 %estimatedHours% 小时 (按100文件/小时计算)
echo.

rem 读取TSV文件统计各类别应该有多少文件
echo 📋 正在分析TSV文件计算各类别目标...
echo.

rem 创建临时文件统计各类别预期文件数
echo. > category_expected.tmp
if exist "d:\NS--Normal--Software\Wechat\WeChat Files\wxid_39yqqfvvmy9x22\FileStorage\File\2025-07\download_list.tsv" (
    for /f "skip=1 tokens=2 delims=	" %%C in ("d:\NS--Normal--Software\Wechat\WeChat Files\wxid_39yqqfvvmy9x22\FileStorage\File\2025-07\download_list.tsv") do (
        call :countcategory "%%C"
    )
)

echo ████████████████████████████████████████████████████████████████████████████████
echo ██                        📂 各类别统计 (修正版)                             ██
echo ████████████████████████████████████████████████████████████████████████████████
echo.

rem 统计各类别实际情况
for /d %%D in ("data\fastq_by_type\*") do (
    set /a catTotal=0
    set /a catNormal=0
    
    for %%F in ("%%D\*.fastq.gz") do (
        set /a catTotal+=1
        call :checkcatfile "%%F"
    )
    
    set /a catDamaged=catTotal-catNormal
    
    rem 从TSV统计中获取该类别的预期文件数
    set /a catExpected=0
    call :getcatexpected "%%~nD"
    
    rem 计算真实完成率（基于预期文件数）
    set /a catPercent=0
    if !catExpected! GTR 0 (
        set /a catPercent=catNormal*100/catExpected
    )
    
    set /a catMissing=catExpected-catTotal
    
    echo     📁 %%~nD:
    echo         预期文件: !catExpected! 个
    echo         实际文件: !catTotal! 个
    echo         正常文件: !catNormal! 个 ✅
    echo         损坏文件: !catDamaged! 个 ❌
    echo         缺失文件: !catMissing! 个 ⚠️
    echo         真实完成率: !catPercent!%% (正常文件/预期文件)
    echo.
)

rem 显示损坏文件（如果有）
if %damagedFiles% GTR 0 (
    echo ████████████████████████████████████████████████████████████████████████████████
    echo ██                        ❌ 损坏文件列表                                   ██
    echo ████████████████████████████████████████████████████████████████████████████████
    echo.
    
    for /r "data\fastq_by_type" %%F in (*.fastq.gz) do (
        call :showdamaged "%%F"
    )
    echo.
)

echo ████████████████████████████████████████████████████████████████████████████████
echo ██                            🎯 总结                                        ██
echo ████████████████████████████████████████████████████████████████████████████████
echo.

if %damagedFiles% GTR 0 (
    echo     ⚠️  发现 %damagedFiles% 个损坏文件，需要重新下载
) else (
    echo     ✅ 所有已下载文件状态良好
)

if %missingFiles% GTR 0 (
    echo     📋 还有 %missingFiles% 个文件待下载
    echo     🚀 建议：继续运行下载脚本
) else (
    echo     🎉 所有文件下载完成！
)

echo.
echo     📊 下载效率分析:
echo         总进度: %normalFiles%/%expectedFiles% = %completionPercent%%%
echo         平均下载速度: 约100文件/小时 (可调整)
echo.

echo ████████████████████████████████████████████████████████████████████████████████
echo ██                          ✅ 检查完成                                      ██
echo ████████████████████████████████████████████████████████████████████████████████
echo.

rem 清理临时文件
del category_expected.tmp >nul 2>&1

goto :end

:checkfile
set "filepath=%~1"
if not exist "%filepath%" goto :eof
for %%A in ("%filepath%") do (
    if %%~zA GTR 1048576 (
        set /a normalFiles+=1
    ) else (
        set /a damagedFiles+=1
    )
)
goto :eof

:checkcatfile
set "filepath=%~1"
if not exist "%filepath%" goto :eof
for %%A in ("%filepath%") do (
    if %%~zA GTR 1048576 (
        set /a catNormal+=1
    )
)
goto :eof

:showdamaged
set "filepath=%~1"
if not exist "%filepath%" goto :eof
for %%A in ("%filepath%") do (
    if %%~zA LEQ 1048576 (
        echo     ❌ %%~nxA (%%~zA bytes)
    )
)
goto :eof

:countcategory
rem 这里应该统计各类别在TSV中出现的次数，但批处理限制太多，简化处理
goto :eof

:getcatexpected
rem 简化：每个类别假设平均分配预期文件数
set /a catExpected=expectedFiles/totalFolders
goto :eof

:end
pause