@echo off
echo =========================================
echo 📊 下载状态检查器 v1.0 📊
echo =========================================
echo 检查目录: d:\Download-forLRJ\data\fastq_by_type\
echo.

cd /d "d:\Download-forLRJ"

echo 创建PowerShell统计脚本...
(
echo # 下载状态检查脚本
echo $ErrorActionPreference = "Continue"
echo.
echo # 检查文件完整性函数
echo function Test-FileIntegrity {
echo     param($filePath)
echo     if (-not (Test-Path $filePath)) { return "不存在" }
echo     $fileInfo = Get-Item $filePath
echo     if ($fileInfo.Length -lt 1MB) { return "损坏(过小)" }
echo     try {
echo         $stream = [System.IO.File]::OpenRead($filePath)
echo         $stream.Close()
echo         return "完整"
echo     } catch {
echo         return "损坏(无法读取)"
echo     }
echo }
echo.
echo # 主统计逻辑
echo $dataDir = "data\fastq_by_type"
echo $tsvPath = "d:\NS--Normal--Software\Wechat\WeChat Files\wxid_39yqqfvvmy9x22\FileStorage\File\2025-07\download_list.tsv"
echo.
echo # 检查数据目录是否存在
echo if (-not (Test-Path $dataDir)) {
echo     Write-Host "❌ 错误：数据目录不存在: $dataDir" -ForegroundColor Red
echo     exit 1
echo }
echo.
echo # 统计已下载文件
echo Write-Host "🔍 正在扫描已下载文件..." -ForegroundColor Yellow
echo $allFiles = Get-ChildItem -Path $dataDir -Recurse -Filter "*.fastq.gz"
echo $totalFiles = $allFiles.Count
echo.
echo # 按细胞类型统计
echo Write-Host "📊 按细胞类型统计:" -ForegroundColor Green
echo $typeStats = @{}
echo $typeSizes = @{}
echo $failedFiles = @()
echo.
echo foreach ($file in $allFiles) {
echo     $type = $file.Directory.Name
echo     $integrity = Test-FileIntegrity $file.FullName
echo     if (-not $typeStats.ContainsKey($type)) {
echo         $typeStats[$type] = @{ "完整" = 0; "损坏" = 0; "不存在" = 0 }
echo         $typeSizes[$type] = 0
echo     }
echo     if ($integrity -eq "完整") {
echo         $typeStats[$type]["完整"]++
echo         $typeSizes[$type] += $file.Length
echo     } else {
echo         $typeStats[$type]["损坏"]++
echo         $failedFiles += [PSCustomObject]@{
echo             Type = $type
echo             File = $file.Name
echo             Path = $file.FullName
echo             Status = $integrity
echo             Size = if ($file.Exists) { $file.Length } else { 0 }
echo         }
echo     }
echo }
echo.
echo # 显示统计结果
echo Write-Host "=============================================" -ForegroundColor Cyan
echo Write-Host "📈 总体统计:" -ForegroundColor Yellow
echo Write-Host "  • 总文件数: $totalFiles" -ForegroundColor White
echo Write-Host "  • 细胞类型数: $($typeStats.Count)" -ForegroundColor White
echo $totalSize = ($typeSizes.Values ^| Measure-Object -Sum).Sum
echo Write-Host "  • 总大小: $('{0:N2}' -f ($totalSize / 1GB))GB" -ForegroundColor White
echo Write-Host "=============================================" -ForegroundColor Cyan
echo.
echo # 按类型显示详细统计
echo $sortedTypes = $typeStats.Keys ^| Sort-Object
echo foreach ($type in $sortedTypes) {
echo     $stats = $typeStats[$type]
echo     $totalType = $stats["完整"] + $stats["损坏"]
echo     $sizeGB = [math]::Round($typeSizes[$type] / 1GB, 2)
echo     $statusColor = if ($stats["损坏"] -eq 0) { "Green" } else { "Yellow" }
echo     Write-Host "  📁 $type`: $totalType 个文件 ($sizeGB GB)" -ForegroundColor $statusColor
echo     Write-Host "    ✅ 完整: $($stats["完整"])  ❌ 损坏: $($stats["损坏"])" -ForegroundColor Gray
echo }
echo.
echo # 检查TSV文件并计算进度
echo if (Test-Path $tsvPath) {
echo     Write-Host "=============================================" -ForegroundColor Cyan
echo     Write-Host "📋 与TSV文件对比:" -ForegroundColor Yellow
echo     $tsvData = Get-Content $tsvPath ^| Select-Object -Skip 1
echo     $totalSamples = $tsvData.Count
echo     $expectedFiles = $totalSamples * 2
echo     $completedFiles = ($typeStats.Values ^| ForEach-Object { $_["完整"] } ^| Measure-Object -Sum).Sum
echo     $progress = if ($expectedFiles -gt 0) { [math]::Round(($completedFiles / $expectedFiles) * 100, 1) } else { 0 }
echo     Write-Host "  • TSV样本数: $totalSamples" -ForegroundColor White
echo     Write-Host "  • 预期文件数: $expectedFiles" -ForegroundColor White
echo     Write-Host "  • 已完成文件: $completedFiles" -ForegroundColor Green
echo     Write-Host "  • 完成进度: $progress%%" -ForegroundColor Cyan
echo     Write-Host "  • 剩余文件: $($expectedFiles - $completedFiles)" -ForegroundColor Yellow
echo } else {
echo     Write-Host "⚠️  警告：TSV文件不存在，无法计算进度" -ForegroundColor Yellow
echo }
echo.
echo # 显示失败文件列表
echo if ($failedFiles.Count -gt 0) {
echo     Write-Host "=============================================" -ForegroundColor Red
echo     Write-Host "❌ 失败/损坏文件列表 ($($failedFiles.Count) 个):" -ForegroundColor Red
echo     Write-Host "=============================================" -ForegroundColor Red
echo     foreach ($file in $failedFiles) {
echo         $sizeMB = if ($file.Size -gt 0) { [math]::Round($file.Size / 1MB, 1) } else { 0 }
echo         Write-Host "  📁 $($file.Type)\$($file.File) - $($file.Status) ($sizeMB MB)" -ForegroundColor Red
echo     }
echo } else {
echo     Write-Host "=============================================" -ForegroundColor Green
echo     Write-Host "🎉 所有文件都完整！没有发现损坏文件" -ForegroundColor Green
echo }
echo.
echo Write-Host "=============================================" -ForegroundColor Cyan
echo Write-Host "📊 统计完成！" -ForegroundColor Green
echo Write-Host "=============================================" -ForegroundColor Cyan
) > download_status_checker.ps1

echo 开始检查下载状态...
powershell -ExecutionPolicy Bypass -File download_status_checker.ps1

echo.
echo 检查完成！详细结果如上所示。
pause