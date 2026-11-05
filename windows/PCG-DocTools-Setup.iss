; PCG 文件工具（jt-doc-tools 離線版）：Windows 安裝程式（Inno Setup 6）
; 產生：.github/workflows/release.yml → ISCC.exe /DAppVersion=<版本> /DStage=<windows\build.py 的產出> windows\PCG-DocTools-Setup.iss
; 全部內容（Python、套件、程式、文字辨識模型）都在安裝檔裡：不連網、不需要系統管理員
#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef Stage
  #define Stage "..\stage"
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
PrivilegesRequired=lowest
UsedUserAreasWarning=no
DirExistsWarning=no
OutputDir=..\dist
OutputBaseFilename=PCG-DocTools-Setup-{#AppVersion}
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
#ifexist LangDir + "\ChineseTraditional.isl"
zh.ShortcutName=PCG 文件工具
zh.LaunchNow=立即開啟 PCG 文件工具
#endif
#ifexist LangDir + "\Indonesian.isl"
id.ShortcutName=Alat Dokumen PCG
id.LaunchNow=Buka Alat Dokumen PCG sekarang
#endif
#ifexist LangDir + "\Vietnamese.isl"
vi.ShortcutName=Công cụ tài liệu PCG
vi.LaunchNow=Mở Công cụ tài liệu PCG ngay
#endif

[InstallDelete]
; 更新時先清掉舊的程式與套件（舊版留下的檔案會跟新版衝突）；使用者的 data\ 不動
Type: filesandordirs; Name: "{app}\python"
Type: filesandordirs; Name: "{app}\jtdt"
Type: filesandordirs; Name: "{app}\pcg"

[Files]
Source: "{#Stage}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

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
Type: filesandordirs; Name: "{app}\pcg"

[Code]
function GetDefaultDir(Param: String): String;
begin
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
  Exec('powershell.exe', '-NoProfile -ExecutionPolicy Bypass -Command "Get-Process python -ErrorAction SilentlyContinue | Where-Object { $_.Path -like ''' +
       ExpandConstant('{app}') + '\python\*'' } | Stop-Process -Force"', '', SW_HIDE, ewWaitUntilTerminated, RC);
  Result := '';
end;
