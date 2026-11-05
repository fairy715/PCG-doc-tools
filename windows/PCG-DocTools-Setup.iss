; PCG 文件工具（jt-doc-tools 離線版）：Windows 安裝程式（Inno Setup 6）
; 產生：.github/workflows/release.yml → ISCC.exe /DAppVersion=<版本> /DStage=<windows\build.py 的產出> windows\PCG-DocTools-Setup.iss
; 全部內容（Python、套件、程式、文字辨識模型）都在安裝檔裡：不連網、不需要系統管理員
#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef Stage
  #define Stage "..\stage"
#endif
; 小更新包：/DPatchOnly /DDepsSha=<套件清單 SHA-256> /DPyVer=<Python 版本> /DRuntimeRev=<build.py 的 RUNTIME_REV>
#ifndef DepsSha
  #define DepsSha ""
#endif
#ifndef PyVer
  #define PyVer ""
#endif
#ifndef RuntimeRev
  #define RuntimeRev "1"
#endif
#define LangDir "lang"

[Setup]
AppId=PCG-doc-tools
AppName=PCG Document Tools
AppVersion={#AppVersion}
AppVerName=PCG Document Tools {#AppVersion}
AppPublisher=PCG
DefaultDirName={code:GetDefaultDir}
DisableProgramGroupPage=yes
#ifdef PatchOnly
DisableDirPage=yes
UsePreviousAppDir=no
#endif
PrivilegesRequired=lowest
UsedUserAreasWarning=no
DirExistsWarning=no
OutputDir=..\dist
#ifdef PatchOnly
OutputBaseFilename=PCG-DocTools-Update-{#AppVersion}
#else
OutputBaseFilename=PCG-DocTools-Setup-{#AppVersion}
#endif
UninstallDisplayName=PCG Document Tools
Compression=lzma2/max
SolidCompression=yes
LZMAUseSeparateProcess=yes
LZMANumBlockThreads=4
WizardStyle=modern
ShowLanguageDialog=auto
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
#ifexist LangDir + "\ChineseTraditional.isl"
Name: "zh"; MessagesFile: "{#LangDir}\ChineseTraditional.isl"
#endif
Name: "en"; MessagesFile: "compiler:Default.isl"
#ifexist LangDir + "\Indonesian.isl"
Name: "id"; MessagesFile: "{#LangDir}\Indonesian.isl"
#endif
#ifexist LangDir + "\Vietnamese.isl"
Name: "vi"; MessagesFile: "{#LangDir}\Vietnamese.isl"
#endif

[CustomMessages]
en.ShortcutName=PCG Document Tools
en.LaunchNow=Open PCG Document Tools now
en.NotInstalled=PCG Document Tools is not installed on this computer.%n%nThis small update only works on a computer that already has it. Use the full installer (PCG-DocTools-Setup-….exe).
en.NeedFull=This update needs new components that are only in the full installer.%n%nPlease use PCG-DocTools-Setup-{#AppVersion}.exe instead. Your data is kept.
en.Updating=Updating and checking the program. Please wait...
en.UpdateFailed=The update was installed but the self-check failed. Please send this file to IT:%n%1
#ifexist LangDir + "\ChineseTraditional.isl"
zh.ShortcutName=PCG 文件工具
zh.LaunchNow=立即開啟 PCG 文件工具
zh.NotInstalled=這台電腦還沒有安裝 PCG 文件工具。%n%n小更新包只能更新已經裝好的電腦，請改用完整安裝檔（PCG-DocTools-Setup-….exe）。
zh.NeedFull=這次更新包含新的套件或模型，只有完整安裝檔才有。%n%n請改用 PCG-DocTools-Setup-{#AppVersion}.exe，資料都會保留。
zh.Updating=正在更新並檢查程式，請稍候…
zh.UpdateFailed=已更新，但自我檢查沒有通過。請把這個檔案交給 IT：%n%1
#endif
#ifexist LangDir + "\Indonesian.isl"
id.ShortcutName=Alat Dokumen PCG
id.LaunchNow=Buka Alat Dokumen PCG sekarang
id.NotInstalled=Alat Dokumen PCG belum terpasang di komputer ini.%n%nPembaruan kecil ini hanya untuk komputer yang sudah memasangnya. Gunakan penginstal lengkap (PCG-DocTools-Setup-….exe).
id.NeedFull=Pembaruan ini memerlukan komponen baru yang hanya ada di penginstal lengkap.%n%nGunakan PCG-DocTools-Setup-{#AppVersion}.exe. Data Anda tetap disimpan.
id.Updating=Memperbarui dan memeriksa program. Mohon tunggu...
id.UpdateFailed=Pembaruan terpasang, tetapi pemeriksaan mandiri gagal. Kirim file ini ke IT:%n%1
#endif
#ifexist LangDir + "\Vietnamese.isl"
vi.ShortcutName=Công cụ tài liệu PCG
vi.LaunchNow=Mở Công cụ tài liệu PCG ngay
vi.NotInstalled=Máy tính này chưa cài Công cụ tài liệu PCG.%n%nGói cập nhật nhỏ chỉ dùng cho máy đã cài. Hãy dùng bộ cài đầy đủ (PCG-DocTools-Setup-….exe).
vi.NeedFull=Bản cập nhật này cần thành phần mới, chỉ có trong bộ cài đầy đủ.%n%nHãy dùng PCG-DocTools-Setup-{#AppVersion}.exe. Dữ liệu của bạn vẫn được giữ.
vi.Updating=Đang cập nhật và kiểm tra chương trình. Vui lòng chờ...
vi.UpdateFailed=Đã cập nhật nhưng tự kiểm tra không đạt. Hãy gửi tệp này cho IT:%n%1
#endif

[InstallDelete]
; 更新時先清掉舊的程式與套件（舊版留下的檔案會跟新版衝突）；使用者的 data\ 不動
#ifndef PatchOnly
Type: filesandordirs; Name: "{app}\python"
Type: filesandordirs; Name: "{app}\oxoffice"
#endif
Type: filesandordirs; Name: "{app}\jtdt"
Type: filesandordirs; Name: "{app}\pcg"

[Files]
#ifdef PatchOnly
; 小更新包：只有程式（原作者的 jtdt\ 與啟動腳本 pcg\）；Python、套件、文字辨識模型沿用已安裝的
Source: "{#Stage}\jtdt\*"; DestDir: "{app}\jtdt"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "{#Stage}\pcg\*"; DestDir: "{app}\pcg"; Flags: recursesubdirs createallsubdirs ignoreversion
#else
Source: "{#Stage}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion
#endif

[Icons]
Name: "{autodesktop}\{cm:ShortcutName}"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\pcg\launch.vbs"""; WorkingDir: "{app}"; IconFilename: "{app}\pcg\app.ico"
Name: "{autoprograms}\{cm:ShortcutName}"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\pcg\launch.vbs"""; WorkingDir: "{app}"; IconFilename: "{app}\pcg\app.ico"

[Run]
Filename: "{sys}\wscript.exe"; Parameters: """{app}\pcg\launch.vbs"""; Description: "{cm:LaunchNow}"; Flags: postinstall nowait skipifsilent

[UninstallRun]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -Command ""Get-Process python -ErrorAction SilentlyContinue | Where-Object {{ $_.Path -like '{app}\python\*' } | Stop-Process -Force"""; Flags: runhidden; RunOnceId: "StopPCGDoc"

[UninstallDelete]
; 程式、套件、模型一起移除；使用者的 data\（工作區、印章、設定）保留
Type: filesandordirs; Name: "{app}\python"
Type: filesandordirs; Name: "{app}\jtdt"
Type: filesandordirs; Name: "{app}\easyocr"
Type: filesandordirs; Name: "{app}\oxoffice"
Type: filesandordirs; Name: "{app}\pcg"

[Code]
var
  PrevDir: String;

{ 已安裝的位置：PrivilegesRequired=lowest 寫在 HKCU；以系統管理員執行過的會在 HKLM }
function FindPrevDir(): String;
var
  Key: String;
begin
  Key := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\PCG-doc-tools_is1';
  Result := '';
  if not RegQueryStringValue(HKCU, Key, 'Inno Setup: App Path', Result) then
    if not RegQueryStringValue(HKLM64, Key, 'Inno Setup: App Path', Result) then
      RegQueryStringValue(HKLM32, Key, 'Inno Setup: App Path', Result);
end;

{ 已安裝的執行環境跟這一版要的一樣嗎：比對 pcg\build.json 的 deps_sha256、python、runtime_rev（舊版沒有 runtime_rev＝1） }
function RuntimeMatches(Dir: String): Boolean;
var
  Raw: AnsiString;
  S, Rev: String;
begin
  Result := False;
  if not LoadStringFromFile(AddBackslash(Dir) + 'pcg\build.json', Raw) then
    exit;
  S := String(Raw);
  if Pos('"runtime_rev": ', S) > 0 then
    Rev := '"runtime_rev": {#RuntimeRev}'
  else
    Rev := '';
  Result := (Pos('"deps_sha256": "{#DepsSha}"', S) > 0) and (Pos('"python": "{#PyVer}"', S) > 0) and
            ((Rev = '') and ('{#RuntimeRev}' = '1') or (Rev <> '') and (Pos(Rev, S) > 0));
end;

#ifdef PatchOnly
function InitializeSetup(): Boolean;
begin
  PrevDir := FindPrevDir();
  if (PrevDir = '') or (not FileExists(AddBackslash(PrevDir) + 'python\python.exe')) then
  begin
    SuppressibleMsgBox(CustomMessage('NotInstalled'), mbCriticalError, MB_OK, IDOK);
    Result := False;
    exit;
  end;
  if not RuntimeMatches(PrevDir) then
  begin
    SuppressibleMsgBox(CustomMessage('NeedFull'), mbCriticalError, MB_OK, IDOK);
    Result := False;
    exit;
  end;
  Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  RC: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    WizardForm.StatusLabel.Caption := CustomMessage('Updating');
    WizardForm.ProgressGauge.Style := npbstMarquee;
    if (not Exec('powershell.exe', '-NoProfile -ExecutionPolicy Bypass -File "' + ExpandConstant('{app}\pcg\update.ps1') +
                 '" -AppDir "' + ExpandConstant('{app}') + '"', '', SW_HIDE, ewWaitUntilTerminated, RC)) or (RC <> 0) then
      SuppressibleMsgBox(FmtMessage(CustomMessage('UpdateFailed'), [ExpandConstant('{app}\data\pcg-logs\update.log')]),
                         mbCriticalError, MB_OK, IDOK);
    WizardForm.ProgressGauge.Style := npbstNormal;
  end;
end;
#endif

function GetDefaultDir(Param: String): String;
begin
#ifdef PatchOnly
  Result := PrevDir;
  exit;
#endif
  { 有 D 槽就裝 D 槽，沒有就裝系統磁碟（不放使用者資料夾：中文使用者名稱會讓部分套件出錯） }
  if DirExists('D:\') then
    Result := 'D:\PCG-doc-tools'
  else
    Result := ExpandConstant('{sd}') + '\PCG-doc-tools';
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  RC: Integer;
begin
  { 更新時先關掉還在跑的程式，否則檔案被佔用 }
  Exec('powershell.exe', '-NoProfile -ExecutionPolicy Bypass -Command "Get-Process python,soffice,soffice.bin -ErrorAction SilentlyContinue | Where-Object { $_.Path -like ''' +
       ExpandConstant('{app}') + '\*'' } | Stop-Process -Force"', '', SW_HIDE, ewWaitUntilTerminated, RC);
  Result := '';
end;
