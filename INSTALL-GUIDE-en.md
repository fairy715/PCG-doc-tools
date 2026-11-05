# PCG Document Tools: install guide

[中文](安裝說明.md) · [English](INSTALL-GUIDE-en.md) · [Bahasa Indonesia](INSTALL-GUIDE-id.md) · [Tiếng Việt](INSTALL-GUIDE-vi.md)

Latest version: **https://github.com/fairy715/PCG-doc-tools/releases/latest**

## 1. Download

Under "Assets" on the release page, click `PCG-DocTools-Setup-<version>.exe`. If the browser says the file "isn't commonly downloaded", choose "Keep". IT can also put it on a shared folder.

## 2. Install

1. Double-click the exe.
2. If "Windows protected your PC" appears, click "More info" → "Run anyway" (the installer has no code-signing certificate).
3. Location: `D:\PCG-doc-tools` by default (`C:\PCG-doc-tools` without a D drive). Click "Next" → "Install". No internet or administrator rights needed.
4. Done: tick "Open PCG Document Tools now" and click "Finish". A desktop shortcut is created.

## 3. Use

1. Double-click the desktop shortcut. The browser opens `http://127.0.0.1:8765/` (the first start takes 10–30 seconds).
2. Choose a tool → upload a file → download the result. Files are processed only on this computer.
3. OCR models are built in (Traditional/Simplified Chinese, English, Vietnamese, Indonesian); nothing is downloaded.

## For IT: admin area

- On that computer, open `http://127.0.0.1:8765/admin` (or "Admin" in the app).
- The default is **single-user mode**: no account or password, whoever uses the computer is the administrator. You can turn tools on/off, set file retention, OCR settings, etc.
- Account login (roles, `jtdt-admin`) can be enabled in the admin area for shared use. For single-user computers, keep single-user mode: this offline build has no `jtdt` command, so a forgotten password is harder to recover.

## 4. Update

No need to uninstall; your workspace, stamps and settings (`data` folder) are kept. Close PCG Document Tools first, then:

- **Small update** (`PCG-DocTools-Update-….exe`, much smaller): double-click it; done in about 1 minute. If it says new components are needed, use the full installer.
- **Full installer**: install it over the old version.
- The table at the top of each release page says which one to use. IT mass deployment: add `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART` after the exe.

## 5. Problems

- It does not open: send the two files in `D:\PCG-doc-tools\data\pcg-logs\` to IT.
- Blocked by antivirus: ask IT to add the install folder as an exception.
- Uninstall: Windows "Settings" → "Apps" → "PCG Document Tools" → "Uninstall". The `data` folder is kept; delete it manually if not needed.
