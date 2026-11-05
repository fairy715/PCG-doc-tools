r"""PCG 文件工具：一鍵更新（小更新包）。原作者的畫面不改，所以由桌面捷徑的啟動腳本（launch.ps1）在開啟前檢查。

    python\python.exe pcg\updater.py check [--force]      有沒有新版（印一行 JSON）
    python\python.exe pcg\updater.py install              下載／複製、比對指紋、在背景啟動小更新包（裝完自動開啟）
    python\python.exe pcg\updater.py skip <版本> <天數>    同仁按「稍後」：這一版幾天內不再問

更新來源（先找到較新的就用）：
  1. 公司共用資料夾（IT 在「更新設定」填）：放 PCG-DocTools-Update-<版本>.exe 與同名 .sha256。不能上網的電腦也能更新
  2. GitHub 發布頁（repo 公開時）：只認這個 repo 的發布附檔，一定要有 SHA-256 指紋
只下載小更新包；新版只有完整安裝檔時回報 kind="full"，畫面請同仁找 IT。
設定在 data\pcg-update.json（更新、重裝都不會動到）。
"""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import threading
import time
import urllib.request
from pathlib import Path

APP = Path(__file__).resolve().parent.parent
REPO = "fairy715/PCG-doc-tools"
API = f"https://api.github.com/repos/{REPO}/releases/latest"
DL_PREFIX = f"https://github.com/{REPO}/releases/download/"
PATCH_RE = re.compile(r"^PCG-DocTools-Update-(\d+\.\d+\.\d+-pcg\.\d+)\.exe$", re.I)
FULL_RE = re.compile(r"^PCG-DocTools-Setup-(\d+\.\d+\.\d+-pcg\.\d+)\.exe$", re.I)
MAX_BYTES = 300 * 1024 * 1024
DATA = APP / "data"
SETTINGS = DATA / "pcg-update.json"
STATE = DATA / "pcg-update-state.json"
DEFAULTS = {"check": True, "who": "staff", "share": ""}


def parse_ver(v):
    m = re.fullmatch(r"v?(\d+)\.(\d+)\.(\d+)-pcg\.(\d+)", str(v or "").strip())
    return tuple(int(x) for x in m.groups()) if m else None


def _load(p, default):
    try:
        return {**default, **json.loads(p.read_text(encoding="utf-8"))}
    except (OSError, ValueError):
        return dict(default)


def settings():
    s = _load(SETTINGS, DEFAULTS)
    s["who"] = "it" if s.get("who") == "it" else "staff"
    return s


def current():
    return str(_load(APP / "pcg" / "version.json", {"version": "dev"}).get("version") or "dev")


def _sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def from_share(folder):
    if not folder:
        return None
    d = Path(folder)
    try:
        names = [p.name for p in d.iterdir() if p.is_file()]
    except OSError:
        return None
    best = None
    for n in names:
        for rx, kind in ((PATCH_RE, "patch"), (FULL_RE, "full")):
            m = rx.match(n)
            v = parse_ver(m.group(1)) if m else None
            if v and (best is None or v > best[0] or (v == best[0] and kind == "patch")):
                best = (v, m.group(1), kind, n)
    if not best:
        return None
    _, ver, kind, name = best
    sha = ""
    side = d / (name + ".sha256")
    if kind == "patch" and side.is_file():
        try:
            sha = side.read_text(encoding="utf-8", errors="replace").split()[0].lower()
        except (OSError, IndexError):
            sha = ""
    return {"version": ver, "kind": kind, "path": str(d / name), "sha256": sha, "source": "share"}


def from_github(fetch=None):
    if fetch is None:
        def fetch(url):
            req = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json",
                                                       "User-Agent": "PCG-doc-tools-updater"})
            with urllib.request.urlopen(req, timeout=6) as r:
                return json.loads(r.read().decode("utf-8"))
    try:
        rel = fetch(API)
    except Exception:  # noqa: BLE001  沒網路、repo 改私人：當作沒有更新
        return None
    ver = str(rel.get("tag_name") or "").lstrip("v")
    if not parse_ver(ver):
        return None
    patch, full = None, False
    for a in rel.get("assets") or []:
        name = str(a.get("name") or "")
        if PATCH_RE.match(name):
            patch = a
        elif FULL_RE.match(name):
            full = True
    if patch:
        url = str(patch.get("browser_download_url") or "")
        digest = str(patch.get("digest") or "")
        if not url.startswith(DL_PREFIX) or not digest.startswith("sha256:"):
            return None
        return {"version": ver, "kind": "patch", "url": url, "sha256": digest.split(":", 1)[1].lower(),
                "source": "github"}
    return {"version": ver, "kind": "full", "source": "github"} if full else None


def check(cur, share="", github_fetch=None, use_github=True):
    c = parse_ver(cur)
    if not c:
        return None
    cands = [x for x in (from_share(share), from_github(github_fetch) if use_github else None) if x]
    newer = [x for x in cands if parse_ver(x["version"]) > c]
    if not newer:
        return None
    newer.sort(key=lambda x: (parse_ver(x["version"]), x["kind"] == "patch", x["source"] == "share"), reverse=True)
    return newer[0]


def download(latest, dest: Path, opener=None):
    if latest.get("kind") != "patch":
        raise RuntimeError("need_full")
    dest.mkdir(parents=True, exist_ok=True)
    dst = dest / f"PCG-DocTools-Update-{latest['version']}.exe"
    tmp = dst.with_suffix(".part")
    if latest["source"] == "share":
        shutil.copyfile(latest["path"], tmp)
    else:
        if not latest["url"].startswith(DL_PREFIX):
            raise RuntimeError("bad_url")
        opener = opener or (lambda u: urllib.request.urlopen(
            urllib.request.Request(u, headers={"User-Agent": "PCG-doc-tools-updater"}), timeout=60))
        n = 0
        with opener(latest["url"]) as r, open(tmp, "wb") as f:
            while True:
                chunk = r.read(1 << 20)
                if not chunk:
                    break
                n += len(chunk)
                if n > MAX_BYTES:
                    raise RuntimeError("too_big")
                f.write(chunk)
    want = (latest.get("sha256") or "").lower()
    if (latest["source"] == "github" and not want) or (want and _sha256(tmp) != want):
        tmp.unlink(missing_ok=True)
        raise RuntimeError("bad_fingerprint")
    os.replace(tmp, dst)
    return dst


def launch(exe: Path):
    """在背景啟動小更新包（跟啟動腳本脫鉤）。/SILENT 只顯示進度；/RELAUNCH=1 裝完自動開啟"""
    args = [str(exe), "/SILENT", "/NORESTART", "/RELAUNCH=1"]
    flags = 0x00000008 | 0x00000200
    try:
        subprocess.Popen(args, creationflags=flags | 0x01000000, close_fds=True)
    except OSError:
        subprocess.Popen(args, creationflags=flags, close_fds=True)


def _with_timeout(fn, seconds):
    box = {}
    t = threading.Thread(target=lambda: box.setdefault("r", fn()), daemon=True)
    t.start()
    t.join(seconds)
    return box.get("r")


def main(argv):
    cmd = argv[1] if len(argv) > 1 else "check"
    s = settings()
    cur = current()
    out = {"ok": True, "current": cur, "who": s["who"]}
    if cmd == "check":
        force = "--force" in argv
        if not s["check"] and not force:
            out.update(available=False, disabled=True)
        else:
            latest = _with_timeout(lambda: check(cur, s["share"]), 15)
            st = _load(STATE, {})
            skipped = (not force and latest and st.get("skip") == latest["version"]
                       and time.time() < float(st.get("until") or 0))
            out.update(available=bool(latest) and not skipped,
                       version=(latest or {}).get("version"), kind=(latest or {}).get("kind"),
                       source=(latest or {}).get("source"))
    elif cmd == "install":
        latest = _with_timeout(lambda: check(cur, s["share"]), 30)
        if not latest:
            out.update(ok=False, error="none")
        else:
            try:
                exe = download(latest, DATA / "pcg-updates")
                launch(exe)
                out.update(version=latest["version"])
            except Exception as e:  # noqa: BLE001
                out.update(ok=False, error=str(e)[:200])
    elif cmd == "skip" and len(argv) >= 4:
        DATA.mkdir(parents=True, exist_ok=True)
        STATE.write_text(json.dumps({"skip": argv[2], "until": time.time() + float(argv[3]) * 86400}), encoding="utf-8")
    print(json.dumps(out, ensure_ascii=False))
    return 0 if out["ok"] else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
