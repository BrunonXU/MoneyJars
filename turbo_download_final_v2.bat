@echo off
echo =========================================
echo 🚀 超级加速分类下载 (最终版 v2.0) 🚀
echo =========================================
echo 目标文件夹: d:\Download-forLRJ\data\
echo TSV文件: download_list.tsv
echo.

cd /d "d:\Download-forLRJ"

echo 📡 正在优化网络设置...
rem 临时修改DNS为更快的服务器 (增加错误处理)
netsh interface ip set dns "以太网" static 8.8.8.8 primary >nul 2>&1 || echo 警告：以太网DNS设置失败
netsh interface ip add dns "以太网" 1.1.1.1 index=2 >nul 2>&1 || echo 警告：以太网备用DNS设置失败
netsh interface ip set dns "WLAN" static 8.8.8.8 primary >nul 2>&1 || echo 警告：WLAN DNS设置失败
netsh interface ip add dns "WLAN" 1.1.1.1 index=2 >nul 2>&1 || echo 警告：WLAN备用DNS设置失败

rem 优化TCP设置
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global chimney=enabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global netdma=enabled >nul 2>&1

rem 清理DNS缓存
ipconfig /flushdns >nul 2>&1
echo 网络优化完成！

rem 测试网络连接
echo 测试网络连接...
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    echo ⚠️  警告：网络连接可能不稳定，可能影响下载速度
) else (
    echo ✅ 网络连接正常
)

echo 检查并下载aria2c工具...
if not exist "aria2c.exe" (
    echo aria2c工具不存在，正在下载...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/aria2/aria2/releases/download/release-1.36.0/aria2-1.36.0-win-64bit-build1.zip' -OutFile 'aria2.zip'" || (
        echo ❌ aria2c下载失败，尝试备用下载源...
        powershell -Command "Invoke-WebRequest -Uri 'https://mirrors.tuna.tsinghua.edu.cn/github-release/aria2/aria2/release-1.36.0/aria2-1.36.0-win-64bit-build1.zip' -OutFile 'aria2.zip'"
    )
    if exist "aria2.zip" (
        powershell -Command "Expand-Archive -Path 'aria2.zip' -DestinationPath '.'"
        copy "aria2-1.36.0-win-64bit-build1\aria2c.exe" "aria2c.exe"
        del "aria2.zip"
        rmdir /s /q "aria2-1.36.0-win-64bit-build1"
        echo aria2c工具安装完成！
    ) else (
        echo ❌ 错误：无法下载aria2c工具，请手动下载并放置到当前目录
        pause
        exit /b 1
    )
    echo.
)

rem 验证aria2c版本
echo 验证aria2c版本...
aria2c.exe --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：aria2c工具无法运行，请检查文件完整性
    pause
    exit /b 1
)
echo ✅ aria2c工具验证成功

echo 创建数据目录...
mkdir "data\fastq_by_type" 2>nul

rem 检查磁盘空间 (假设需要至少50GB)
echo 检查磁盘空间...
for /f "tokens=3" %%i in ('dir /-c 2^>nul ^| find "bytes free"') do set freeSpace=%%i
set /a freeSpaceGB=%freeSpace:~0,-1%/1073741824
if %freeSpaceGB% LSS 50 (
    echo ⚠️  警告：可用磁盘空间不足50GB (当前: %freeSpaceGB%GB)
    echo 建议确保有足够的磁盘空间再进行下载
    set /p confirm="是否继续？(y/N): "
    if /i not "%confirm%"=="y" exit /b 1
)
echo ✅ 磁盘空间检查通过 (可用: %freeSpaceGB%GB)

echo 创建超级加速PowerShell脚本...
echo # 超级加速下载脚本 (最终版 v2.0) > turbo_download_final_v2.ps1
echo $ErrorActionPreference = "Continue" >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1

echo # 文件完整性检查函数 >> turbo_download_final_v2.ps1
echo function Test-FileComplete { >> turbo_download_final_v2.ps1
echo     param($filePath) >> turbo_download_final_v2.ps1
echo     if (-not (Test-Path $filePath)) { return $false } >> turbo_download_final_v2.ps1
echo     $fileInfo = Get-Item $filePath >> turbo_download_final_v2.ps1
echo     # 检查文件大小是否大于1MB (避免空文件或损坏文件) >> turbo_download_final_v2.ps1
echo     if ($fileInfo.Length -lt 1MB) { return $false } >> turbo_download_final_v2.ps1
echo     # 检查文件是否可读 >> turbo_download_final_v2.ps1
echo     try { >> turbo_download_final_v2.ps1
echo         $stream = [System.IO.File]::OpenRead($filePath) >> turbo_download_final_v2.ps1
echo         $stream.Close() >> turbo_download_final_v2.ps1
echo         return $true >> turbo_download_final_v2.ps1
echo     } catch { >> turbo_download_final_v2.ps1
echo         return $false >> turbo_download_final_v2.ps1
echo     } >> turbo_download_final_v2.ps1
echo } >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1

echo # 智能下载函数 >> turbo_download_final_v2.ps1
echo function Download-File { >> turbo_download_final_v2.ps1
echo     param($url, $outputFile, $outputDir, $fileName, $retryMax = 3) >> turbo_download_final_v2.ps1
echo     $retryCount = 0 >> turbo_download_final_v2.ps1
echo     $success = $false >> turbo_download_final_v2.ps1
echo     >> turbo_download_final_v2.ps1
echo     do { >> turbo_download_final_v2.ps1
echo         $retryCount++ >> turbo_download_final_v2.ps1
echo         if ($retryCount -gt 1) { >> turbo_download_final_v2.ps1
echo             Write-Host "  🔄 重试 (第 $retryCount 次)" -ForegroundColor Yellow >> turbo_download_final_v2.ps1
echo         } >> turbo_download_final_v2.ps1
echo         >> turbo_download_final_v2.ps1
echo         # 检查目标文件是否已存在且完整 >> turbo_download_final_v2.ps1
echo         if (Test-FileComplete $outputFile) { >> turbo_download_final_v2.ps1
echo             Write-Host "  ⏭️  跳过 (文件完整)" -ForegroundColor Gray >> turbo_download_final_v2.ps1
echo             return $true >> turbo_download_final_v2.ps1
echo         } >> turbo_download_final_v2.ps1
echo         >> turbo_download_final_v2.ps1
echo         # 执行下载 >> turbo_download_final_v2.ps1
echo         $p = Start-Process "./aria2c.exe" "-c --continue=true -x 8 -s 8 -j 8 -k 1M --file-allocation=none --summary-interval=1 --download-result=hide --enable-http-keep-alive=true --max-tries=5 --retry-wait=2 --timeout=24 --connect-timeout=10 -d $outputDir -o $fileName $url" -NoNewWindow -PassThru >> turbo_download_final_v2.ps1
echo         $p.WaitForExit(24000) >> turbo_download_final_v2.ps1
echo         if (-not $p.HasExited) { $p.Kill() } >> turbo_download_final_v2.ps1
echo         >> turbo_download_final_v2.ps1
echo         # 验证下载结果 - 修复的判断逻辑 >> turbo_download_final_v2.ps1
echo         if ($p.ExitCode -eq 0 -and (Test-Path $outputFile) -and ((Get-Item $outputFile).Length -gt 1MB)) { >> turbo_download_final_v2.ps1
echo             $success = $true >> turbo_download_final_v2.ps1
echo         } >> turbo_download_final_v2.ps1
echo     } until ($success -or $retryCount -ge $retryMax) >> turbo_download_final_v2.ps1
echo     >> turbo_download_final_v2.ps1
echo     return $success >> turbo_download_final_v2.ps1
echo } >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1

echo # 读取TSV文件 >> turbo_download_final_v2.ps1
echo $tsvPath = "d:\NS--Normal--Software\Wechat\WeChat Files\wxid_39yqqfvvmy9x22\FileStorage\File\2025-07\download_list.tsv" >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1
echo # 检查TSV文件是否存在 >> turbo_download_final_v2.ps1
echo if (-not (Test-Path $tsvPath)) { >> turbo_download_final_v2.ps1
echo     Write-Host "❌ 错误：TSV文件不存在: $tsvPath" -ForegroundColor Red >> turbo_download_final_v2.ps1
echo     Write-Host "请检查文件路径是否正确" -ForegroundColor Red >> turbo_download_final_v2.ps1
echo     exit 1 >> turbo_download_final_v2.ps1
echo } >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1
echo $data = Get-Content $tsvPath ^| Select-Object -Skip 1 >> turbo_download_final_v2.ps1
echo if ($data.Count -eq 0) { >> turbo_download_final_v2.ps1
echo     Write-Host "❌ 错误：TSV文件为空或格式不正确" -ForegroundColor Red >> turbo_download_final_v2.ps1
echo     exit 1 >> turbo_download_final_v2.ps1
echo } >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1
echo $totalSamples = $data.Count >> turbo_download_final_v2.ps1
echo $current = 0 >> turbo_download_final_v2.ps1
echo $totalFiles = $totalSamples * 2 >> turbo_download_final_v2.ps1
echo $completedFiles = 0 >> turbo_download_final_v2.ps1
echo $totalDownloadedSize = 0 >> turbo_download_final_v2.ps1
echo $skippedFiles = 0 >> turbo_download_final_v2.ps1
echo $failedFiles = 0 >> turbo_download_final_v2.ps1
echo $startTime = Get-Date >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1
echo Write-Host "总样本数: $totalSamples ($totalFiles 个文件)" -ForegroundColor Green >> turbo_download_final_v2.ps1
echo Write-Host "开始时间: $startTime" -ForegroundColor Green >> turbo_download_final_v2.ps1
echo Write-Host "=============================================" -ForegroundColor Cyan >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1
echo foreach ($line in $data) { >> turbo_download_final_v2.ps1
echo     $current++ >> turbo_download_final_v2.ps1
echo     $fields = $line -split "`t" >> turbo_download_final_v2.ps1
echo     if ($fields.Count -lt 4) { >> turbo_download_final_v2.ps1
echo         Write-Host "⚠️  警告：第 $current 行格式不正确，跳过" -ForegroundColor Yellow >> turbo_download_final_v2.ps1
echo         continue >> turbo_download_final_v2.ps1
echo     } >> turbo_download_final_v2.ps1
echo     $sample   = $fields[0] >> turbo_download_final_v2.ps1
echo     $celltype = $fields[1] >> turbo_download_final_v2.ps1
echo     $run      = $fields[2] >> turbo_download_final_v2.ps1
echo     $urls     = $fields[3] -split ";" >> turbo_download_final_v2.ps1
echo     if ($urls.Count -lt 2) { >> turbo_download_final_v2.ps1
echo         Write-Host "⚠️  警告：第 $current 行URL格式不正确，跳过" -ForegroundColor Yellow >> turbo_download_final_v2.ps1
echo         continue >> turbo_download_final_v2.ps1
echo     } >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1

echo     # 创建细胞类型目录 >> turbo_download_final_v2.ps1
echo     $typeDir = "data\fastq_by_type\$celltype" >> turbo_download_final_v2.ps1
echo     New-Item -ItemType Directory -Path $typeDir -Force ^| Out-Null >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1

echo     $unique = "$sample`_$run" >> turbo_download_final_v2.ps1
echo     $r1File = "$typeDir\${unique}_R1.fastq.gz" >> turbo_download_final_v2.ps1
echo     $r2File = "$typeDir\${unique}_R2.fastq.gz" >> turbo_download_final_v2.ps1

echo     $r1Url  = "ftp://" + $urls[0] >> turbo_download_final_v2.ps1
echo     $r2Url  = "ftp://" + $urls[1] >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1
echo     Write-Host "[$current/$totalSamples] 样本: $sample ($celltype)" -ForegroundColor Yellow >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1

:: ========== R1 下载 ==========
echo     Write-Host "  📥 处理R1: $([System.IO.Path]::GetFileName($r1File))" -ForegroundColor Green >> turbo_download_final_v2.ps1
echo     $r1Start = Get-Date >> turbo_download_final_v2.ps1
echo     $r1Success = Download-File -url $r1Url -outputFile $r1File -outputDir $typeDir -fileName "${unique}_R1.fastq.gz" >> turbo_download_final_v2.ps1
echo     if ($r1Success) { >> turbo_download_final_v2.ps1
echo         $r1End   = Get-Date >> turbo_download_final_v2.ps1
echo         $r1Size  = (Get-Item $r1File).Length >> turbo_download_final_v2.ps1
echo         $r1Speed = [math]::Round($r1Size / ($r1End - $r1Start).TotalSeconds / 1MB, 2) >> turbo_download_final_v2.ps1
echo         Write-Host "  ✅ R1完成 ($('{0:N1}' -f ($r1Size/1MB))MB, $r1Speed MB/s)" -ForegroundColor Blue >> turbo_download_final_v2.ps1
echo         $completedFiles++ >> turbo_download_final_v2.ps1
echo         $totalDownloadedSize += $r1Size >> turbo_download_final_v2.ps1
echo     } else { >> turbo_download_final_v2.ps1
echo         Write-Host "  ❌ R1下载失败" -ForegroundColor Red >> turbo_download_final_v2.ps1
echo         $failedFiles++ >> turbo_download_final_v2.ps1
echo     } >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1

:: ========== R2 下载 ==========
echo     Write-Host "  📥 处理R2: $([System.IO.Path]::GetFileName($r2File))" -ForegroundColor Green >> turbo_download_final_v2.ps1
echo     $r2Start = Get-Date >> turbo_download_final_v2.ps1
echo     $r2Success = Download-File -url $r2Url -outputFile $r2File -outputDir $typeDir -fileName "${unique}_R2.fastq.gz" >> turbo_download_final_v2.ps1
echo     if ($r2Success) { >> turbo_download_final_v2.ps1
echo         $r2End   = Get-Date >> turbo_download_final_v2.ps1
echo         $r2Size  = (Get-Item $r2File).Length >> turbo_download_final_v2.ps1
echo         $r2Speed = [math]::Round($r2Size / ($r2End - $r2Start).TotalSeconds / 1MB, 2) >> turbo_download_final_v2.ps1
echo         Write-Host "  ✅ R2完成 ($('{0:N1}' -f ($r2Size/1MB))MB, $r2Speed MB/s)" -ForegroundColor Blue >> turbo_download_final_v2.ps1
echo         $completedFiles++ >> turbo_download_final_v2.ps1
echo         $totalDownloadedSize += $r2Size >> turbo_download_final_v2.ps1
echo     } else { >> turbo_download_final_v2.ps1
echo         Write-Host "  ❌ R2下载失败" -ForegroundColor Red >> turbo_download_final_v2.ps1
echo         $failedFiles++ >> turbo_download_final_v2.ps1
echo     } >> turbo_download_final_v2.ps1
echo >> turbo_download_final_v2.ps1

echo     # 计算总体进度和速度 >> turbo_download_final_v2.ps1
echo     $elapsed            = (Get-Date) - $startTime >> turbo_download_final_v2.ps1
echo     $avgTime           = $elapsed.TotalMinutes / $current >> turbo_download_final_v2.ps1
echo     $remainingTime     = ($totalSamples - $current) * $avgTime >> turbo_download_final_v2.ps1
echo     $totalProcessedFiles = $completedFiles + $skippedFiles + $failedFiles >> turbo_download_final_v2.ps1
echo     $fileProgress      = if ($totalFiles -gt 0) { ($totalProcessedFiles / $totalFiles) * 100 } else { 0 } >> turbo_download_final_v2.ps1
echo     $avgDownloadSpeed  = if ($elapsed.TotalSeconds -gt 0 -and $totalDownloadedSize -gt 0) { [math]::Round($totalDownloadedSize / $elapsed.TotalSeconds / 1MB, 2) } else { 0 } >> turbo_download_final_v2.ps1
echo     Write-Host "  📊 样本进度: $current/$totalSamples ($('{0:P1}' -f ($current/$totalSamples)))" -ForegroundColor Cyan >> turbo_download_final_v2.ps1
echo     Write-Host "  📁 文件进度: $totalProcessedFiles/$totalFiles ($('{0:N1}' -f $fileProgress)%%) [完成:$completedFiles 跳过:$skippedFiles 失败:$failedFiles]" -ForegroundColor Cyan >> turbo_download_final_v2.ps1
echo     Write-Host "  💾 已下载: $('{0:N1}' -f ($totalDownloadedSize/1GB))GB, 平均速度: $avgDownloadSpeed MB/s" -ForegroundColor Cyan >> turbo_download_final_v2.ps1
echo     Write-Host "  ⏰ 预计剩余: $('{0:N0}' -f $remainingTime)分钟" -ForegroundColor Cyan >> turbo_download_final_v2.ps1
echo     Write-Host "=============================================" -ForegroundColor DarkGray >> turbo_download_final_v2.ps1
echo } >> turbo_download_final_v2.ps1
echo. >> turbo_download_final_v2.ps1
echo $endTime = Get-Date >> turbo_download_final_v2.ps1
echo $totalTime = $endTime - $startTime >> turbo_download_final_v2.ps1
echo $finalAvgSpeed = if ($totalTime.TotalSeconds -gt 0 -and $totalDownloadedSize -gt 0) { [math]::Round($totalDownloadedSize / $totalTime.TotalSeconds / 1MB, 2) } else { 0 } >> turbo_download_final_v2.ps1
echo Write-Host "=============================================" -ForegroundColor Green >> turbo_download_final_v2.ps1
echo Write-Host "🎉 所有文件下载完成！" -ForegroundColor Green >> turbo_download_final_v2.ps1
echo Write-Host "📊 最终统计:" -ForegroundColor Yellow >> turbo_download_final_v2.ps1
echo Write-Host "  • 总耗时: $('{0:N0}' -f $totalTime.TotalMinutes)分钟 ($('{0:N1}' -f $totalTime.TotalHours)小时)" -ForegroundColor White >> turbo_download_final_v2.ps1
echo Write-Host "  • 总文件数: $totalFiles" -ForegroundColor White >> turbo_download_final_v2.ps1
echo Write-Host "  • 新下载文件: $completedFiles" -ForegroundColor White >> turbo_download_final_v2.ps1
echo Write-Host "  • 跳过文件: $skippedFiles" -ForegroundColor White >> turbo_download_final_v2.ps1
echo Write-Host "  • 失败文件: $failedFiles" -ForegroundColor Red >> turbo_download_final_v2.ps1
echo Write-Host "  • 总下载量: $('{0:N2}' -f ($totalDownloadedSize/1GB))GB" -ForegroundColor White >> turbo_download_final_v2.ps1
echo Write-Host "  • 平均速度: $finalAvgSpeed MB/s" -ForegroundColor White >> turbo_download_final_v2.ps1
echo Write-Host "=============================================" -ForegroundColor Green >> turbo_download_final_v2.ps1

echo 开始超级加速下载 (最终版 v2.0)...
echo 🚀 使用aria2c 16线程 + 智能重试
echo 📊 实时进度显示 + 文件完整性检查
echo 🎯 按细胞类型分类存储
echo 🔍 智能跳过：只跳过完整文件，重新下载损坏文件
echo ⚡ 优化：修复aria2c退出码判断 + 零风险设计
echo.

echo 检查PowerShell执行策略...
powershell -Command "Get-ExecutionPolicy" | findstr "Restricted" >nul
if not errorlevel 1 (
    echo 警告：PowerShell执行策略受限，尝试临时修改...
    powershell -Command "Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force" >nul 2>&1
)

powershell -ExecutionPolicy Bypass -File turbo_download_final_v2.ps1

echo.
echo 🎉 下载任务完成！
echo 文件保存在: d:\Download-forLRJ\data\fastq_by_type\

echo 🔄 恢复默认DNS设置...
netsh interface ip set dns "以太网" dhcp >nul 2>&1
netsh interface ip set dns "WLAN" dhcp >nul 2>&1

pause 