# PCG 文件工具（jt-doc-tools 離線版）

把 [jt-doc-tools](https://github.com/jasoncheng7115/jt-doc-tools)（Jason Tools 文件工具箱，原作者 Jason Cheng）包成**離線 Windows 安裝檔**，給不能上網的同仁電腦使用。

- **同仁**：看 [安裝說明](安裝說明.md)（[English](INSTALL-GUIDE-en.md) · [Bahasa Indonesia](INSTALL-GUIDE-id.md) · [Tiếng Việt](INSTALL-GUIDE-vi.md)），從 [Releases](https://github.com/fairy715/PCG-doc-tools/releases/latest) 下載
- **這個 repo 只有打包工具**，不放原作者的程式：打包時照 `UPSTREAM` 指定的版本從原作者的 GitHub 抓下來，原樣包進安裝檔

## 架構

安裝到 `D:\PCG-doc-tools`（沒有 D 槽就是 `C:\PCG-doc-tools`），不需要網路、不需要系統管理員：

| 資料夾 | 內容 | 更新時 |
|---|---|---|
| `python\` | Python 3.12（免安裝版）＋所有套件（含 PyTorch、EasyOCR）、VC++ 執行環境 | 換掉 |
| `jtdt\` | jt-doc-tools 程式（原作者原樣） | 換掉 |
| `easyocr\` | 文字辨識模型：繁中、簡中、英文、拉丁字母語系（越南文、印尼文） | 換掉 |
| `oxoffice\` | Office 轉檔引擎 OxOffice（台灣版 LibreOffice）：MSI 在打包機上解開，同仁電腦不用系統管理員 | 換掉 |
| `pcg\` | 啟動腳本、自我檢查、版本資訊 | 換掉 |
| `data\` | 使用者的工作區、印章、設定、紀錄 | **保留** |

桌面捷徑在背景啟動程式，只開給這台電腦（`http://127.0.0.1:8765/`），用瀏覽器操作。

## 版本

- **第 1 版**（`1.17.26-pcg.1`、`pcg.2`）：不含 Office 轉檔引擎
- **第 2 版（目前）**：內建 OxOffice，Office 轉 PDF、格式互轉等工具可以用；自我檢查會實際把 Word 轉成 PDF
- **之後**：接集團 Open WebUI（保留排版的文件翻譯、逐句翻譯要用大模型）
- 為什麼不用 OnlyOffice：原作者的程式是呼叫 LibreOffice 系列的 `soffice` 指令與它的轉檔濾鏡名稱，OnlyOffice 的轉檔方式完全不同，要改原作者大量程式才能換

## 小更新包

每次發布同時產出完整安裝檔（`PCG-DocTools-Setup-*.exe`）與小更新包（`PCG-DocTools-Update-*.exe`）。小更新包只有程式（`jtdt\`、`pcg\`），Python、套件、文字辨識模型沿用已安裝的：

- 裝之前比對已安裝的 `pcg\build.json`（套件清單 `deps_sha256`、`python`、`runtime_rev`），不同就拒絕，提示改用完整安裝檔
- 裝完跑自我檢查，紀錄在 `data\pcg-logs\update.log`
- 發布流程實測：正常更新成功、執行環境不同時拒絕且不動到程式
- 跟上一版的 `build.json`（發布頁附檔）比較，執行環境有變的那一版不放小更新包
- 改了 `windows/build.py` 的 `OCR_LANG_SETS`、`VC_DLLS` 等不在套件清單裡的內容時，要把 `RUNTIME_REV` 加 1

## 更新原作者的版本

1. 修改 `UPSTREAM` 的 `VERSION` 與 `REF`（原作者 v1.17 起沒有打 tag，用 commit 固定）
2. Actions →「發布安裝包」→ Run workflow
3. 流程會在乾淨的 Windows 上安裝、啟動、自我檢查，通過才發布

## 授權

jt-doc-tools 以 **AGPL-3.0-or-later** 授權；本 repo 的打包工具同樣以 AGPL-3.0-or-later 釋出（見 [LICENSE](LICENSE)）。
安裝檔照原樣使用原作者的程式，原始碼就在安裝資料夾的 `jtdt\`，每一版的發布說明也附上對應的原作者原始碼連結。
