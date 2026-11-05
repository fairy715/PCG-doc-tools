<#
    PCG 文件工具：桌面捷徑執行的啟動腳本（由 launch.vbs 以隱藏視窗呼叫）。
    程式沒在跑就在背景啟動，然後用瀏覽器打開；已經在跑就直接打開。只給這台電腦用（127.0.0.1）。
#>
param([switch]$NoBrowser, [int]$Port = 8765)
$App = Split-Path $PSScriptRoot -Parent
$py = Join-Path $App "python\python.exe"
$data = Join-Path $App "data"
$logDir = Join-Path $data "pcg-logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

function Test-Port([int]$p) {
    try { $c = New-Object System.Net.Sockets.TcpClient; $c.Connect("127.0.0.1", $p); $c.Close(); return $true }
    catch { return $false }
}

if (-not (Test-Port $Port)) {
    $env:JTDT_HOST = "127.0.0.1"
    $env:JTDT_PORT = "$Port"
    # 使用者的資料（工作區、印章、設定）放在安裝資料夾的 data\，更新、重裝都不會動到
    $env:JTDT_DATA_DIR = $data
    # 文字辨識模型：安裝時就放好了，不會再上網下載
    $env:EASYOCR_MODULE_PATH = Join-Path $App "easyocr"
    $env:PYTHONUTF8 = "1"
    $env:PYTHONIOENCODING = "utf-8"
    $env:PATH = (Join-Path $App "python") + ";" + $env:PATH
    Start-Process -FilePath $py -ArgumentList @("run.py") -WorkingDirectory (Join-Path $App "jtdt") -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $logDir "server.log") -RedirectStandardError (Join-Path $logDir "server-error.log")
    for ($i = 0; $i -lt 240 -and -not (Test-Port $Port); $i++) { Start-Sleep -Milliseconds 500 }
}
if (-not $NoBrowser) { Start-Process "http://127.0.0.1:$Port/" }
