<#
    PCG 文件工具：桌面捷徑執行的啟動腳本（由 launch.vbs 以隱藏視窗呼叫）。
    程式沒在跑就在背景啟動，然後用瀏覽器打開；已經在跑就直接打開。只給這台電腦用（127.0.0.1）。
#>
param([switch]$NoBrowser, [switch]$NoUpdateCheck, [int]$Port = 8765)
$App = Split-Path $PSScriptRoot -Parent
$py = Join-Path $App "python\python.exe"
$data = Join-Path $App "data"
$logDir = Join-Path $data "pcg-logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

function Test-Port([int]$p) {
    try { $c = New-Object System.Net.Sockets.TcpClient; $c.Connect("127.0.0.1", $p); $c.Close(); return $true }
    catch { return $false }
}

# 一鍵更新：程式還沒開時檢查一次（共用資料夾或 GitHub）。有小更新包就問要不要更新；只有完整安裝檔或設定成只有 IT 能更新就請同仁找 IT
function Show-UpdatePrompt {
    $env:PYTHONUTF8 = "1"
    $up = Join-Path $PSScriptRoot "updater.py"
    try { $info = (& $py $up check 2>$null | Select-Object -Last 1) | ConvertFrom-Json } catch { return }
    if (-not $info -or -not $info.available) { return }
    $lang = $PSUICulture.Substring(0, 2).ToLower()
    $T = @{
        zh = @{ t = "PCG 文件工具"; ask = "有新版本 v{0}（目前 v{1}）。`n`n要現在更新嗎？約 1 分鐘，完成後會自動開啟。`n選「否」：3 天內不再提醒。"
                it = "有新版本 v{0}（目前 v{1}）。`n`n請找 IT 更新。"; fail = "更新沒有完成（{0}）。先用目前的版本開啟，請找 IT。" }
        en = @{ t = "PCG Document Tools"; ask = "A new version v{0} is available (you have v{1}).`n`nUpdate now? It takes about 1 minute and the app opens by itself.`nChoose No to be reminded again in 3 days."
                it = "A new version v{0} is available (you have v{1}).`n`nPlease ask IT to update."; fail = "The update did not finish ({0}). Opening the current version; please ask IT." }
        id = @{ t = "Alat Dokumen PCG"; ask = "Versi baru v{0} tersedia (versi Anda v{1}).`n`nPerbarui sekarang? Sekitar 1 menit, lalu aplikasi terbuka otomatis.`nPilih Tidak untuk diingatkan lagi dalam 3 hari."
                it = "Versi baru v{0} tersedia (versi Anda v{1}).`n`nHubungi IT untuk memperbarui."; fail = "Pembaruan tidak selesai ({0}). Membuka versi saat ini; hubungi IT." }
        vi = @{ t = "Công cụ tài liệu PCG"; ask = "Có phiên bản mới v{0} (bạn đang dùng v{1}).`n`nCập nhật ngay? Mất khoảng 1 phút, sau đó ứng dụng tự mở.`nChọn Không để được nhắc lại sau 3 ngày."
                it = "Có phiên bản mới v{0} (bạn đang dùng v{1}).`n`nHãy liên hệ IT để cập nhật."; fail = "Cập nhật chưa hoàn tất ({0}). Mở phiên bản hiện tại; hãy liên hệ IT." }
    }
    $m = if ($T.ContainsKey($lang)) { $T[$lang] } else { $T.en }
    Add-Type -AssemblyName System.Windows.Forms
    $owner = New-Object System.Windows.Forms.Form -Property @{ TopMost = $true }
    if ($info.kind -ne "patch" -or $info.who -eq "it") {
        [void][System.Windows.Forms.MessageBox]::Show($owner, ($m.it -f $info.version, $info.current), $m.t, "OK", "Information")
        & $py $up skip $info.version 3 | Out-Null
        return
    }
    $ans = [System.Windows.Forms.MessageBox]::Show($owner, ($m.ask -f $info.version, $info.current), $m.t, "YesNo", "Information")
    if ($ans -ne "Yes") { & $py $up skip $info.version 3 | Out-Null; return }
    try { $r = (& $py $up install 2>$null | Select-Object -Last 1) | ConvertFrom-Json } catch { $r = $null }
    if ($r -and $r.ok) { exit 0 }       # 小更新包在背景安裝，裝完會自己開啟
    [void][System.Windows.Forms.MessageBox]::Show($owner, ($m.fail -f $(if ($r) { $r.error } else { "?" })), $m.t, "OK", "Warning")
}

if (-not (Test-Port $Port)) {
    if (-not $NoUpdateCheck) { Show-UpdatePrompt }
    $env:JTDT_HOST = "127.0.0.1"
    $env:JTDT_PORT = "$Port"
    # 使用者的資料（工作區、印章、設定）放在安裝資料夾的 data\，更新、重裝都不會動到
    $env:JTDT_DATA_DIR = $data
    # 文字辨識模型：安裝時就放好了，不會再上網下載
    $env:EASYOCR_MODULE_PATH = Join-Path $App "easyocr"
    $env:PYTHONUTF8 = "1"
    $env:PYTHONIOENCODING = "utf-8"
    # Office 轉檔引擎：原作者的程式找不到固定路徑時會用 PATH 上的 soffice.exe
    $env:PATH = (Join-Path $App "python") + ";" + (Join-Path $App "oxoffice\program") + ";" + $env:PATH
    Start-Process -FilePath $py -ArgumentList @("run.py") -WorkingDirectory (Join-Path $App "jtdt") -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $logDir "server.log") -RedirectStandardError (Join-Path $logDir "server-error.log")
    for ($i = 0; $i -lt 240 -and -not (Test-Port $Port); $i++) { Start-Sleep -Milliseconds 500 }
}
if (-not $NoBrowser) { Start-Process "http://127.0.0.1:$Port/" }
