<#
    PCG 文件工具：小更新包裝完後的自我檢查（由 PCG-DocTools-Update-*.exe 呼叫）。
    小更新包只換程式（jtdt\、pcg\）；Python、套件、文字辨識模型沿用已安裝的。結果寫在 data\pcg-logs\update.log
#>
param([Parameter(Mandatory = $true)][string]$AppDir)
$logDir = Join-Path $AppDir "data\pcg-logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir "update.log"
function Log($msg) {
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $msg
    Write-Host $line
    Add-Content -Path $log -Value $line -Encoding UTF8
}
$ver = "?"
try { $ver = (Get-Content (Join-Path $AppDir "pcg\version.json") -Raw -Encoding UTF8 | ConvertFrom-Json).version } catch { }
Log "=== 小更新包：更新到 $ver ==="
$py = Join-Path $AppDir "python\python.exe"
if (-not (Test-Path $py)) { Log "[錯誤] 找不到執行環境（$py），請改用完整安裝檔"; exit 1 }
$env:PYTHONUTF8 = "1"
$ErrorActionPreference = "Continue"
& $py (Join-Path $AppDir "pcg\selftest.py") 2>&1 | ForEach-Object { "$_" } | Out-File -Append -Encoding UTF8 $log
$rc = $LASTEXITCODE
if ($rc -ne 0) { Log "[錯誤] 自我檢查沒有通過（結束代碼 $rc）"; exit 1 }
Log "=== 更新完成 ==="
exit 0
