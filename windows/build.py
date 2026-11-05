"""PCG 文件工具（jt-doc-tools 離線版）：在 Windows 上製作安裝內容（GitHub Actions 的 windows-latest 執行）。

產出 <out>/ ：
  python/    Python 3.12（NuGet 免安裝版）＋ 所有套件（已安裝好，同仁電腦不用再裝）
  jtdt/      jt-doc-tools 程式（原作者原樣，只拿掉測試、文件等執行用不到的）
  easyocr/   文字辨識模型（繁中、簡中、英文、拉丁字母語系：越南文、印尼文）
  pcg/       啟動腳本、自我檢查、版本資訊
第 1 版不含 Office 轉檔引擎（OxOffice／LibreOffice）：需要它的工具會顯示為不可用。

執行：python windows/build.py --out stage
"""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PY_VERSION = "3.12.10"
PY_URL = f"https://www.nuget.org/api/v2/package/python/{PY_VERSION}"
UPSTREAM_GIT = "https://github.com/jasoncheng7115/jt-doc-tools.git"
# 原作者的程式裡，執行時用不到的（測試、開發工具、文件網站、原作者自己的安裝程式）
SKIP_TOP = {".git", ".github", "tests", "docs", "tools", "scripts", "packaging"}
# EasyOCR：偵測模型 ＋ 各語言的辨識模型。語言組合照 jt-doc-tools 會送出去的（tesseract 代碼對應過去）
OCR_LANG_SETS = [["ch_tra", "en"], ["ch_sim", "en"], ["en"], ["vi", "en"], ["id", "en"]]
# VC++ 執行環境：PyTorch 需要。同仁電腦不一定有裝，又不能要系統管理員，所以跟著程式放（微軟允許隨程式散布）
# 執行環境版本：OCR_LANG_SETS、VC_DLLS 或其他「不在套件清單裡」的執行環境內容改了就加 1。
# 小更新包只換程式，裝之前比對已安裝的 deps_sha256、python、runtime_rev，有一個不同就要用完整安裝檔
RUNTIME_REV = 1
VC_DLLS = ["msvcp140.dll", "msvcp140_1.dll", "msvcp140_2.dll", "vcruntime140.dll", "vcruntime140_1.dll",
           "concrt140.dll", "vcomp140.dll"]


def step(msg):
    print(f"\n=== {msg} ===", flush=True)


def run(cmd, **kw):
    print("+", " ".join(str(c) for c in cmd), flush=True)
    subprocess.run([str(c) for c in cmd], check=True, **kw)


def read_upstream():
    vals = {}
    for line in (ROOT / "UPSTREAM").read_text(encoding="utf-8").splitlines():
        if "=" in line and not line.lstrip().startswith("#"):
            k, v = line.split("=", 1)
            vals[k.strip()] = v.strip()
    return vals["VERSION"], vals["REF"]


def fetch_source(ref, work: Path, dst: Path):
    step(f"jt-doc-tools 原始碼（{ref[:7]}）")
    src = work / "src"
    if src.exists():
        shutil.rmtree(src)
    src.mkdir(parents=True)
    run(["git", "init", "-q"], cwd=src)
    run(["git", "fetch", "-q", "--depth", "1", UPSTREAM_GIT, ref], cwd=src)
    run(["git", "checkout", "-q", "FETCH_HEAD"], cwd=src)
    dst.mkdir(parents=True, exist_ok=True)
    for p in src.iterdir():
        if p.name in SKIP_TOP:
            continue
        if p.is_dir():
            shutil.copytree(p, dst / p.name, ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
        else:
            shutil.copy2(p, dst / p.name)
    return src


def get_python(work: Path, dst: Path):
    step(f"Python {PY_VERSION}（NuGet 免安裝版）")
    nupkg = work / f"python-{PY_VERSION}.nupkg"
    if not nupkg.exists():
        urllib.request.urlretrieve(PY_URL, nupkg)
    with zipfile.ZipFile(nupkg) as z:
        for info in z.infolist():
            if info.filename.startswith("tools/") and not info.is_dir():
                target = dst / info.filename[len("tools/"):]
                target.parent.mkdir(parents=True, exist_ok=True)
                with z.open(info) as s, open(target, "wb") as d:
                    shutil.copyfileobj(s, d)
    py = dst / "python.exe"
    if not py.exists():
        sys.exit("NuGet 套件裡沒有 python.exe")
    return py


def install_packages(src: Path, py: Path, work: Path):
    step("套件（照原作者 uv.lock 的版本，裝進免安裝版 Python）")
    req = work / "requirements.txt"
    run([sys.executable, "-m", "pip", "install", "-q", "uv"])
    run([sys.executable, "-m", "uv", "export", "--frozen", "--no-dev", "--no-emit-project", "--no-hashes",
         "--format", "requirements-txt", "-o", str(req)], cwd=src)
    run([py, "-m", "ensurepip", "--upgrade"])
    run([py, "-m", "pip", "install", "-q", "--upgrade", "pip"])
    # --no-deps：完全照 uv.lock 的版本，不讓 pip 自己再解一次相依
    run([py, "-m", "pip", "install", "--no-deps", "--no-warn-script-location", "--disable-pip-version-check",
         "-r", str(req)])
    run([py, "-m", "pip", "check"])
    return req


def copy_vc_runtime(pydir: Path):
    step("VC++ 執行環境（跟著程式放，不用系統管理員安裝）")
    sysdir = Path(os.environ.get("SystemRoot", r"C:\Windows")) / "System32"
    torch_lib = pydir / "Lib" / "site-packages" / "torch" / "lib"
    for name in VC_DLLS:
        s = sysdir / name
        if not s.exists():
            print(f"  （這台沒有 {name}，略過）")
            continue
        for d in (pydir, torch_lib):
            if d.is_dir() and not (d / name).exists():
                shutil.copy2(s, d / name)
                print(f"  {name} → {d.relative_to(pydir.parent)}")


def fetch_ocr_models(py: Path, model_root: Path):
    step("文字辨識模型（EasyOCR）")
    code = ("import easyocr,sys\n"
            f"for langs in {OCR_LANG_SETS!r}:\n"
            "    easyocr.Reader(langs, gpu=False, verbose=False, download_enabled=True)\n"
            "    print('  ok', langs, flush=True)\n")
    env = dict(os.environ, EASYOCR_MODULE_PATH=str(model_root))
    run([py, "-c", code], env=env)
    for f in sorted((model_root / "model").glob("*.pth")):
        print(f"  {f.name}  {f.stat().st_size // 1048576} MB")


def clean(out: Path):
    for d in list(out.rglob("__pycache__")):
        shutil.rmtree(d, ignore_errors=True)


def dir_mb(p: Path):
    return sum(f.stat().st_size for f in p.rglob("*") if f.is_file()) // 1048576


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="stage")
    ap.add_argument("--work", default="build-work")
    a = ap.parse_args()
    if os.name != "nt":
        sys.exit("要在 Windows 上執行（套件要用 Windows 版安裝）")
    out, work = Path(a.out).resolve(), Path(a.work).resolve()
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)
    work.mkdir(parents=True, exist_ok=True)
    version, ref = read_upstream()
    src = fetch_source(ref, work, out / "jtdt")
    py = get_python(work, out / "python")
    req = install_packages(src, py, work)
    copy_vc_runtime(out / "python")
    fetch_ocr_models(py, out / "easyocr")
    step("啟動腳本與版本資訊")
    shutil.copytree(ROOT / "windows" / "pcg", out / "pcg")
    ico = src / "packaging" / "windows" / "assets" / "jtdt.ico"
    if ico.exists():
        shutil.copy2(ico, out / "pcg" / "app.ico")
    info = {"upstream_version": version, "upstream_ref": ref, "python": PY_VERSION, "runtime_rev": RUNTIME_REV,
            "deps_sha256": hashlib.sha256(req.read_bytes()).hexdigest(),
            "built": time.strftime("%Y-%m-%d %H:%M:%S")}
    (out / "pcg" / "build.json").write_text(json.dumps(info, ensure_ascii=False, indent=2), encoding="utf-8")
    clean(out)
    step("大小")
    for name in ("python", "jtdt", "easyocr", "pcg"):
        print(f"  {name:8s} {dir_mb(out / name):6d} MB")
    print(f"  合計     {dir_mb(out):6d} MB")


if __name__ == "__main__":
    main()
