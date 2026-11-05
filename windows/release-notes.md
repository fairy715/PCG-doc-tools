## PCG 文件工具 {VER}

離線版的 [jt-doc-tools](https://github.com/jasoncheng7115/jt-doc-tools)（原作者 Jason Cheng）v{UPVER}，給不能上網的同仁電腦使用。

**Guide / Panduan / Hướng dẫn**：[中文](https://github.com/fairy715/PCG-doc-tools/blob/main/安裝說明.md) · [English](https://github.com/fairy715/PCG-doc-tools/blob/main/INSTALL-GUIDE-en.md)

### 下載

`{FULL}`（約 {FULL_MB} MB）：在頁面下方「Assets」點檔名下載。

### 安裝

1. 點兩下 exe。出現藍色視窗「Windows 已保護您的電腦」：按「其他資訊」→「仍要執行」（沒有程式碼簽章，第一次一定會出現）。
2. 安裝位置預設 `D:\PCG-doc-tools`（沒有 D 槽就是 `C:\PCG-doc-tools`），按「下一步」→「安裝」。不需要網路、不需要系統管理員。
3. 完成後桌面會有「PCG 文件工具」。點兩下，瀏覽器會打開 `http://127.0.0.1:8765/`。
4. 更新：新版直接裝在舊版上面即可，工作區、印章、設定（`data` 資料夾）都會保留。

### 這一版可以用的工具

不需要 Office 引擎的工具：PDF 合併分拆、頁面整理、用印與簽名、浮水印、表單填寫、文字辨識（繁中、簡中、英文、越南文、印尼文，模型已內建）、個資遮蔽、加密解密、中繼資料清除、差異比對、壓縮等。

**還不能用**：需要 Office 引擎（OxOffice／LibreOffice）的工具，例如 Word／Excel／PPT 轉 PDF、保留排版的文件翻譯、騎縫章（Word 檔）。要接大模型的功能（逐句翻譯、AI 摘要）預設關閉。

---

# English

Offline build of [jt-doc-tools](https://github.com/jasoncheng7115/jt-doc-tools) v{UPVER} for computers without internet.

1. Download `{FULL}` (about {FULL_MB} MB) from "Assets" below.
2. Double-click it. If "Windows protected your PC" appears, click "More info" → "Run anyway".
3. Default location `D:\PCG-doc-tools` (or `C:\PCG-doc-tools`). No internet or administrator rights needed.
4. Open "PCG Document Tools" on the desktop; the browser opens `http://127.0.0.1:8765/`.
5. To update, install the new version over the old one. Your data (`data` folder) is kept.

This build has the tools that do not need an Office engine (PDF merge/split, stamps, watermarks, OCR with built-in models, redaction, encryption, compare, compress…). Tools that need OxOffice/LibreOffice are not available yet.

---
授權：jt-doc-tools 以 AGPL-3.0-or-later 授權，原始碼：https://github.com/jasoncheng7115/jt-doc-tools/tree/{REF}（本安裝檔照原樣使用，未修改原作者程式；程式碼也在安裝資料夾的 `jtdt\`）。
已在乾淨的 Windows 上實際安裝、啟動並通過自我檢查（套件、程式、PDF 處理、離線文字辨識）。commit {COMMIT}
