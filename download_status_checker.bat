@echo off
echo =================================================
echo 📊 下载进度检查器 - 简洁版 📊
echo =================================================
echo.

cd /d "d:\Download-forLRJ"

echo 创建检查脚本...
echo # 下载进度检查脚本 > status_check.ps1
echo $ErrorActionPreference = "Continue" >> status_check.ps1
echo. >> status_check.ps1

echo # 配置 >> status_check.ps1
echo $dataDir = "data\fastq_by_type" >> status_check.ps1
echo $tsvFile = "d:\NS--Normal--Software\Wechat\WeChat Files\wxid_39yqqfvvmy9x22\FileStorage\File\2025-07\download_list.tsv" >> status_check.ps1
echo. >> status_check.ps1

echo # 检查数据目录 >> status_check.ps1
echo if (-not (Test-Path $dataDir)) { >> status_check.ps1
echo     Write-Host "❌ 数据目录不存在: $dataDir" -ForegroundColor Red >> status_check.ps1
echo     exit 1 >> status_check.ps1
echo } >> status_check.ps1
echo. >> status_check.ps1

echo # 统计函数 >> status_check.ps1
echo function Get-FileStatus($filePath) { >> status_check.ps1
echo     if (-not (Test-Path $filePath)) { return "缺失" } >> status_check.ps1
echo     $file = Get-Item $filePath >> status_check.ps1
echo     if ($file.Length -lt 1MB) { return "损坏" } >> status_check.ps1
echo     return "正常" >> status_check.ps1
echo } >> status_check.ps1
echo. >> status_check.ps1

echo # 开始统计 >> status_check.ps1
echo Write-Host "🔍 开始扫描..." -ForegroundColor Yellow >> status_check.ps1
echo. >> status_check.ps1

echo # 获取所有类别目录 >> status_check.ps1
echo $categories = Get-ChildItem -Path $dataDir -Directory >> status_check.ps1
echo $totalCategories = $categories.Count >> status_check.ps1
echo. >> status_check.ps1

echo # 统计变量 >> status_check.ps1
echo $totalFiles = 0 >> status_check.ps1
echo $normalFiles = 0 >> status_check.ps1
echo $damagedFiles = 0 >> status_check.ps1
echo $missingFiles = 0 >> status_check.ps1
echo $totalSizeGB = 0 >> status_check.ps1
echo $categoryStats = @{} >> status_check.ps1
echo. >> status_check.ps1

echo # 扫描每个类别 >> status_check.ps1
echo foreach ($category in $categories) { >> status_check.ps1
echo     $categoryName = $category.Name >> status_check.ps1
echo     $files = Get-ChildItem -Path $category.FullName -Filter "*.fastq.gz" >> status_check.ps1
echo     >> status_check.ps1
echo     $catNormal = 0 >> status_check.ps1
echo     $catDamaged = 0 >> status_check.ps1
echo     $catMissing = 0 >> status_check.ps1
echo     $catSize = 0 >> status_check.ps1
echo     >> status_check.ps1
echo     foreach ($file in $files) { >> status_check.ps1
echo         $status = Get-FileStatus $file.FullName >> status_check.ps1
echo         $totalFiles++ >> status_check.ps1
echo         >> status_check.ps1
echo         switch ($status) { >> status_check.ps1
echo             "正常" { $normalFiles++; $catNormal++; $catSize += $file.Length } >> status_check.ps1
echo             "损坏" { $damagedFiles++; $catDamaged++ } >> status_check.ps1
echo             "缺失" { $missingFiles++; $catMissing++ } >> status_check.ps1
echo         } >> status_check.ps1
echo     } >> status_check.ps1
echo     >> status_check.ps1
echo     $totalSizeGB += $catSize >> status_check.ps1
echo     $categoryStats[$categoryName] = @{ >> status_check.ps1
echo         "总文件" = $files.Count >> status_check.ps1
echo         "正常" = $catNormal >> status_check.ps1
echo         "损坏" = $catDamaged >> status_check.ps1
echo         "缺失" = $catMissing >> status_check.ps1
echo         "大小GB" = [math]::Round($catSize / 1GB, 2) >> status_check.ps1
echo     } >> status_check.ps1
echo } >> status_check.ps1
echo. >> status_check.ps1

echo # 计算预期总数 >> status_check.ps1
echo $expectedTotal = 0 >> status_check.ps1
echo if (Test-Path $tsvFile) { >> status_check.ps1
echo     $tsvData = Get-Content $tsvFile | Select-Object -Skip 1 >> status_check.ps1
echo     $expectedTotal = $tsvData.Count * 2 >> status_check.ps1
echo } >> status_check.ps1
echo. >> status_check.ps1

echo # 显示结果 >> status_check.ps1
echo Write-Host "=============================================" -ForegroundColor Cyan >> status_check.ps1
echo Write-Host "📈 总体统计" -ForegroundColor Green >> status_check.ps1
echo Write-Host "=============================================" -ForegroundColor Cyan >> status_check.ps1
echo Write-Host "📁 总文件夹数: $totalCategories" -ForegroundColor White >> status_check.ps1
echo Write-Host "📄 预期总文件: $expectedTotal" -ForegroundColor White >> status_check.ps1
echo Write-Host "📄 实际总文件: $totalFiles" -ForegroundColor White >> status_check.ps1
echo Write-Host "✅ 正常文件: $normalFiles" -ForegroundColor Green >> status_check.ps1
echo Write-Host "❌ 损坏文件: $damagedFiles" -ForegroundColor Red >> status_check.ps1
echo Write-Host "⚠️  缺失文件: $missingFiles" -ForegroundColor Yellow >> status_check.ps1
echo Write-Host "💾 总大小: $([math]::Round($totalSizeGB / 1GB, 2)) GB" -ForegroundColor Cyan >> status_check.ps1
echo $completionRate = if ($expectedTotal -gt 0) { [math]::Round(($normalFiles / $expectedTotal) * 100, 1) } else { 0 } >> status_check.ps1
echo Write-Host "📊 完成率: $completionRate%%" -ForegroundColor Magenta >> status_check.ps1
echo. >> status_check.ps1

echo # 显示各类别详情 >> status_check.ps1
echo Write-Host "=============================================" -ForegroundColor Cyan >> status_check.ps1
echo Write-Host "📂 各类别详情" -ForegroundColor Green >> status_check.ps1
echo Write-Host "=============================================" -ForegroundColor Cyan >> status_check.ps1
echo foreach ($catName in ($categoryStats.Keys | Sort-Object)) { >> status_check.ps1
echo     $stats = $categoryStats[$catName] >> status_check.ps1
echo     $color = if ($stats["损坏"] -gt 0 -or $stats["缺失"] -gt 0) { "Yellow" } else { "Green" } >> status_check.ps1
echo     Write-Host "$catName`:" -ForegroundColor $color >> status_check.ps1
echo     Write-Host "  总文件: $($stats["总文件"])  正常: $($stats["正常"])  损坏: $($stats["损坏"])  缺失: $($stats["缺失"])  大小: $($stats["大小GB"]) GB" -ForegroundColor Gray >> status_check.ps1
echo } >> status_check.ps1
echo. >> status_check.ps1

echo Write-Host "=============================================" -ForegroundColor Cyan >> status_check.ps1
echo Write-Host "✅ 检查完成!" -ForegroundColor Green >> status_check.ps1
echo Write-Host "=============================================" -ForegroundColor Cyan >> status_check.ps1

echo 运行检查脚本...
powershell -ExecutionPolicy Bypass -File status_check.ps1

echo.
echo 检查完成！
pause