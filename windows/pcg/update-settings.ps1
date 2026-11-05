<#
    PCG 文件工具：更新設定（給 IT）。從「開始」功能表的「PCG 文件工具 更新設定」打開。
    設定存在 data\pcg-update.json（更新、重裝都不會動到）：自動檢查、誰可以更新、公司共用資料夾、IT 密碼（加鹽雜湊）
#>
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$App = Split-Path $PSScriptRoot -Parent
$py = Join-Path $App "python\python.exe"
$up = Join-Path $PSScriptRoot "updater.py"
$data = Join-Path $App "data"
$cfgPath = Join-Path $data "pcg-update.json"
New-Item -ItemType Directory -Force -Path $data | Out-Null
$env:PYTHONUTF8 = "1"

$zh = $PSUICulture.StartsWith("zh")
function L($c, $e) { if ($zh) { $c } else { $e } }
$title = L "PCG 文件工具：更新設定" "PCG Document Tools: update settings"

function Read-Cfg {
    $c = @{ check = $true; who = "staff"; share = ""; it_password = "" }
    if (Test-Path $cfgPath) {
        try {
            $j = Get-Content $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json
            foreach ($k in @("check", "who", "share", "it_password")) { if ($null -ne $j.$k) { $c[$k] = $j.$k } }
        } catch { }
    }
    return $c
}
function Save-Cfg($c) {
    $json = ($c | ConvertTo-Json -Depth 3)
    [System.IO.File]::WriteAllText($cfgPath, $json, (New-Object System.Text.UTF8Encoding($false)))
}
function Hash-Pw([string]$pw, [string]$saltHex) {
    if (-not $saltHex) { $b = New-Object byte[] 16; [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b); $saltHex = -join ($b | ForEach-Object { $_.ToString("x2") }) }
    $salt = [byte[]]::new($saltHex.Length / 2)
    for ($i = 0; $i -lt $salt.Length; $i++) { $salt[$i] = [Convert]::ToByte($saltHex.Substring($i * 2, 2), 16) }
    $kdf = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($pw, $salt, 200000, [System.Security.Cryptography.HashAlgorithmName]::SHA256)
    return "pbkdf2_sha256`$200000`$$saltHex`$" + (-join ($kdf.GetBytes(32) | ForEach-Object { $_.ToString("x2") }))
}
function Ask-Password([string]$prompt, [bool]$twice) {
    $f = New-Object System.Windows.Forms.Form -Property @{ Text = $title; Width = 420; Height = $(if ($twice) { 230 } else { 180 }); StartPosition = "CenterScreen"; TopMost = $true; FormBorderStyle = "FixedDialog"; MaximizeBox = $false; MinimizeBox = $false }
    $l = New-Object System.Windows.Forms.Label -Property @{ Text = $prompt; Left = 16; Top = 14; Width = 380; Height = 36 }
    $p1 = New-Object System.Windows.Forms.TextBox -Property @{ Left = 16; Top = 54; Width = 370; UseSystemPasswordChar = $true }
    $f.Controls.AddRange(@($l, $p1))
    $p2 = $null
    if ($twice) {
        $l2 = New-Object System.Windows.Forms.Label -Property @{ Text = (L "再輸入一次" "Enter it again"); Left = 16; Top = 84; Width = 380 }
        $p2 = New-Object System.Windows.Forms.TextBox -Property @{ Left = 16; Top = 104; Width = 370; UseSystemPasswordChar = $true }
        $f.Controls.AddRange(@($l2, $p2))
    }
    $ok = New-Object System.Windows.Forms.Button -Property @{ Text = "OK"; Left = 220; Top = $(if ($twice) { 140 } else { 90 }); Width = 80; DialogResult = "OK" }
    $cancel = New-Object System.Windows.Forms.Button -Property @{ Text = (L "取消" "Cancel"); Left = 306; Top = $ok.Top; Width = 80; DialogResult = "Cancel" }
    $f.Controls.AddRange(@($ok, $cancel)); $f.AcceptButton = $ok; $f.CancelButton = $cancel
    if ($f.ShowDialog() -ne "OK") { return $null }
    if ($twice -and $p1.Text -ne $p2.Text) { [void][System.Windows.Forms.MessageBox]::Show((L "兩次輸入的密碼不一樣" "The passwords do not match"), $title); return $null }
    return $p1.Text
}

# ── IT 密碼：第一次設定，之後每次都要輸入 ──
$cfg = Read-Cfg
if (-not $cfg.it_password) {
    $pw = Ask-Password (L "第一次使用，請設定 IT 密碼（至少 6 個字）。同仁不需要知道。" "First use: set an IT password (at least 6 characters).") $true
    if (-not $pw) { exit }
    if ($pw.Length -lt 6) { [void][System.Windows.Forms.MessageBox]::Show((L "密碼至少 6 個字" "At least 6 characters"), $title); exit }
    $cfg.it_password = Hash-Pw $pw ""
    Save-Cfg $cfg
} else {
    $pw = Ask-Password (L "請輸入 IT 密碼" "Enter the IT password") $false
    if ($null -eq $pw) { exit }
    $parts = "$($cfg.it_password)".Split('$')
    if ($parts.Length -ne 4 -or (Hash-Pw $pw $parts[2]) -ne $cfg.it_password) {
        [void][System.Windows.Forms.MessageBox]::Show((L "IT 密碼不正確" "Incorrect IT password"), $title); exit
    }
}

# ── 設定畫面 ──
$f = New-Object System.Windows.Forms.Form -Property @{ Text = $title; Width = 560; Height = 360; StartPosition = "CenterScreen"; FormBorderStyle = "FixedDialog"; MaximizeBox = $false }
$chk = New-Object System.Windows.Forms.CheckBox -Property @{ Text = (L "自動檢查新版本（同仁打開桌面捷徑時會問要不要更新）" "Check for new versions (staff are asked when they open the shortcut)"); Left = 16; Top = 16; Width = 520; Checked = [bool]$cfg.check }
$lw = New-Object System.Windows.Forms.Label -Property @{ Text = (L "誰可以更新" "Who can update"); Left = 16; Top = 52; Width = 120 }
$who = New-Object System.Windows.Forms.ComboBox -Property @{ Left = 140; Top = 48; Width = 390; DropDownStyle = "DropDownList" }
[void]$who.Items.Add((L "同仁自己按（建議）" "Staff themselves (recommended)")); [void]$who.Items.Add((L "只有 IT（同仁會看到「請找 IT」）" "IT only (staff see “ask IT”)"))
$who.SelectedIndex = $(if ($cfg.who -eq "it") { 1 } else { 0 })
$ls = New-Object System.Windows.Forms.Label -Property @{ Text = (L "公司共用資料夾（選填）" "Shared folder (optional)"); Left = 16; Top = 88; Width = 300 }
$share = New-Object System.Windows.Forms.TextBox -Property @{ Left = 16; Top = 110; Width = 420; Text = "$($cfg.share)" }
$browse = New-Object System.Windows.Forms.Button -Property @{ Text = (L "瀏覽…" "Browse…"); Left = 444; Top = 108; Width = 86 }
$browse.Add_Click({ $d = New-Object System.Windows.Forms.FolderBrowserDialog; if ($d.ShowDialog() -eq "OK") { $share.Text = $d.SelectedPath } })
$note = New-Object System.Windows.Forms.Label -Property @{ Left = 16; Top = 142; Width = 515; Height = 90
    Text = (L "能上網的電腦會從 GitHub 發布頁取得小更新包。不能上網的電腦：把發布頁上的 PCG-DocTools-Update-<版本>.exe 和同名的 .sha256 檔放進這個資料夾。只會安裝比目前新的小更新包，安裝前會比對檔案指紋；需要完整安裝檔的版本只會提示找 IT。" "Computers with internet use the GitHub release page. For computers without internet, put PCG-DocTools-Update-<version>.exe and its .sha256 file from the release page in this folder. Only newer small updates are installed and the file fingerprint is checked first; versions that need the full installer only show “ask IT”.") }
$save = New-Object System.Windows.Forms.Button -Property @{ Text = (L "儲存" "Save"); Left = 16; Top = 250; Width = 110 }
$now = New-Object System.Windows.Forms.Button -Property @{ Text = (L "立即檢查並更新" "Check and update now"); Left = 136; Top = 250; Width = 170 }
$close = New-Object System.Windows.Forms.Button -Property @{ Text = (L "關閉" "Close"); Left = 420; Top = 250; Width = 110; DialogResult = "Cancel" }
$f.Controls.AddRange(@($chk, $lw, $who, $ls, $share, $browse, $note, $save, $now, $close)); $f.CancelButton = $close

function Store {
    $s = $share.Text.Trim()
    if ($s.Length -gt 260 -or $s -match '[\r\n\t"<>|?*]') { [void][System.Windows.Forms.MessageBox]::Show((L "共用資料夾路徑格式不正確" "Invalid shared folder path"), $title); return $false }
    $cfg.check = $chk.Checked; $cfg.who = $(if ($who.SelectedIndex -eq 1) { "it" } else { "staff" }); $cfg.share = $s
    Save-Cfg $cfg; return $true
}
$save.Add_Click({ if (Store) { [void][System.Windows.Forms.MessageBox]::Show((L "已儲存" "Saved"), $title) } })
$now.Add_Click({
    if (-not (Store)) { return }
    $f.Cursor = "WaitCursor"
    try { $info = (& $py $up check --force 2>$null | Select-Object -Last 1) | ConvertFrom-Json } catch { $info = $null }
    $f.Cursor = "Default"
    if (-not $info -or -not $info.available) { [void][System.Windows.Forms.MessageBox]::Show((L "已經是最新版（或找不到更新來源）。" "Already up to date (or no update source found)."), $title); return }
    if ($info.kind -ne "patch") { [void][System.Windows.Forms.MessageBox]::Show(((L "新版 v{0} 需要完整安裝檔，請從發布頁下載 PCG-DocTools-Setup-{0}.exe。" "Version v{0} needs the full installer: download PCG-DocTools-Setup-{0}.exe from the release page.") -f $info.version), $title); return }
    $ans = [System.Windows.Forms.MessageBox]::Show(((L "要從 v{1} 更新到 v{0} 嗎？程式會暫時關閉，約 1 分鐘後自動開啟。" "Update from v{1} to v{0}? The app closes briefly and reopens in about 1 minute.") -f $info.version, $info.current), $title, "YesNo", "Question")
    if ($ans -ne "Yes") { return }
    try { $r = (& $py $up install 2>$null | Select-Object -Last 1) | ConvertFrom-Json } catch { $r = $null }
    if ($r -and $r.ok) { [void][System.Windows.Forms.MessageBox]::Show((L "已開始更新。" "The update has started."), $title); $f.Close() }
    else { [void][System.Windows.Forms.MessageBox]::Show(((L "更新沒有完成：{0}" "The update did not finish: {0}") -f $(if ($r) { $r.error } else { "?" })), $title) }
})
[void]$f.ShowDialog()
