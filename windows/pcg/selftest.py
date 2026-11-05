"""PCG 文件工具：自我檢查（安裝後、發布前執行）。只用本機檔案，不連網。

    python\python.exe pcg\selftest.py
"""
import os
import sys
import time
from pathlib import Path

APP = Path(__file__).resolve().parent.parent
os.environ.setdefault("EASYOCR_MODULE_PATH", str(APP / "easyocr"))
# 資料放暫存資料夾：打包前在製作目錄跑，不能把測試資料包進安裝檔
import tempfile
os.environ["JTDT_DATA_DIR"] = tempfile.mkdtemp(prefix="pcg-doc-selftest-")
sys.path.insert(0, str(APP / "jtdt"))
os.chdir(APP / "jtdt")
fails = 0


def check(name, fn):
    global fails
    t = time.time()
    try:
        detail = fn() or ""
        print(f"[OK]   {name}  {detail}  ({time.time() - t:.1f}s)", flush=True)
    except Exception as e:  # noqa: BLE001
        fails += 1
        print(f"[FAIL] {name}  {type(e).__name__}: {e}", flush=True)


def pkgs():
    import fitz, torch, cv2, easyocr  # noqa: F401
    return f"PyMuPDF {fitz.VersionBind}, torch {torch.__version__}, opencv {cv2.__version__}"


def app_import():
    import app.main  # noqa: F401
    return "jt-doc-tools 程式載入正常"


def pdf_roundtrip():
    import fitz
    a, b = fitz.open(), fitz.open()
    a.new_page().insert_text((72, 72), "PCG page 1")
    b.new_page().insert_text((72, 72), "PCG page 2")
    a.insert_pdf(b)
    data = a.tobytes()
    c = fitz.open(stream=data, filetype="pdf")
    assert c.page_count == 2 and "page 2" in c[1].get_text()
    return "合併兩頁 PDF"


def ocr():
    import numpy as np
    from PIL import Image, ImageDraw, ImageFont
    import easyocr
    model = Path(os.environ["EASYOCR_MODULE_PATH"]) / "model"
    for f in ("craft_mlt_25k.pth", "chinese.pth", "english_g2.pth", "latin_g2.pth", "zh_sim_g2.pth"):
        assert (model / f).exists(), f"缺模型 {f}"
    img = Image.new("RGB", (520, 120), "white")
    try:
        font = ImageFont.truetype("arial.ttf", 56)
    except OSError:
        font = ImageFont.load_default()
    ImageDraw.Draw(img).text((20, 25), "PCG 2026", fill="black", font=font)
    r = easyocr.Reader(["ch_tra", "en"], gpu=False, verbose=False, download_enabled=False)
    text = " ".join(t for _, t, _ in r.readtext(np.array(img)))
    assert "2026" in text, f"辨識結果：{text!r}"
    return f"辨識結果：{text}"


check("套件", pkgs)
check("程式", app_import)
check("PDF 處理", pdf_roundtrip)
check("文字辨識（離線模型）", ocr)
print("結果：" + ("全部通過" if not fails else f"{fails} 項失敗"))
sys.exit(1 if fails else 0)
