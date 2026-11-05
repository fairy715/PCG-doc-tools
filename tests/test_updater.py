"""windows/pcg/updater.py 的檢查（不連網：GitHub 回應用假的）。執行：python3 -m unittest tests/test_updater.py"""
import hashlib
import io
import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "windows", "pcg"))
import updater  # noqa: E402

PATCH = b"MZ fake"
SHA = hashlib.sha256(PATCH).hexdigest()


def rel(ver, patch=True, digest=True, url=None):
    a = [{"name": f"PCG-DocTools-Setup-{ver}.exe"}]
    if patch:
        a.append({"name": f"PCG-DocTools-Update-{ver}.exe",
                  "browser_download_url": url or f"{updater.DL_PREFIX}v{ver}/PCG-DocTools-Update-{ver}.exe",
                  "digest": f"sha256:{SHA}" if digest else None})
    return {"tag_name": f"v{ver}", "assets": a}


class Updater(unittest.TestCase):
    def test_versions(self):
        self.assertEqual(updater.parse_ver("v1.17.26-pcg.3"), (1, 17, 26, 3))
        self.assertGreater(updater.parse_ver("1.17.30-pcg.4"), updater.parse_ver("1.17.26-pcg.10"))
        self.assertIsNone(updater.parse_ver("dev"))

    def test_github(self):
        r = updater.check("1.17.26-pcg.3", github_fetch=lambda u: rel("1.17.26-pcg.4"))
        self.assertEqual((r["kind"], r["sha256"]), ("patch", SHA))
        self.assertIsNone(updater.check("1.17.26-pcg.4", github_fetch=lambda u: rel("1.17.26-pcg.4")))
        self.assertEqual(updater.check("1.17.26-pcg.3", github_fetch=lambda u: rel("1.17.26-pcg.4", patch=False))["kind"], "full")
        self.assertIsNone(updater.check("1.17.26-pcg.3", github_fetch=lambda u: rel("1.17.26-pcg.4", digest=False)))
        self.assertIsNone(updater.check("1.17.26-pcg.3", github_fetch=lambda u: rel(
            "1.17.26-pcg.4", url="https://evil.example/x.exe")))

    def test_share_download(self):
        tmp = Path(tempfile.mkdtemp())
        share = tmp / "share"
        share.mkdir()
        (share / "PCG-DocTools-Update-1.17.26-pcg.5.exe").write_bytes(PATCH)
        (share / "PCG-DocTools-Update-1.17.26-pcg.5.exe.sha256").write_text(SHA + "  x\n")
        r = updater.check("1.17.26-pcg.3", share=str(share), github_fetch=lambda u: rel("1.17.26-pcg.4"))
        self.assertEqual((r["version"], r["source"]), ("1.17.26-pcg.5", "share"))
        self.assertEqual(updater.download(r, tmp / "dl").read_bytes(), PATCH)
        (share / "PCG-DocTools-Update-1.17.26-pcg.5.exe").write_bytes(b"tampered")
        with self.assertRaises(RuntimeError):
            updater.download(updater.from_share(str(share)), tmp / "dl2")
        g = updater.check("1.17.26-pcg.3", github_fetch=lambda u: rel("1.17.26-pcg.4"))
        self.assertEqual(updater.download(g, tmp / "dl3", opener=lambda u: io.BytesIO(PATCH)).read_bytes(), PATCH)
        with self.assertRaises(RuntimeError):
            updater.download(g, tmp / "dl4", opener=lambda u: io.BytesIO(b"other"))


if __name__ == "__main__":
    unittest.main()
