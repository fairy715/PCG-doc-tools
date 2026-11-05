# Alat Dokumen PCG: panduan instalasi

[中文](安裝說明.md) · [English](INSTALL-GUIDE-en.md) · [Bahasa Indonesia](INSTALL-GUIDE-id.md) · [Tiếng Việt](INSTALL-GUIDE-vi.md)

Versi terbaru: **https://github.com/fairy715/PCG-doc-tools/releases/latest**

## 1. Unduh

Di bagian "Assets" pada halaman rilis, klik `PCG-DocTools-Setup-<versi>.exe`. Jika browser memperingatkan file "tidak umum diunduh", pilih "Simpan" / "Keep". IT juga bisa menaruhnya di folder bersama.

## 2. Instal

1. Klik dua kali file exe.
2. Jika muncul "Windows melindungi PC Anda" ("Windows protected your PC"), klik "Info selengkapnya" ("More info") → "Tetap jalankan" ("Run anyway"). Penginstal tidak memiliki sertifikat tanda tangan kode.
3. Lokasi: bawaan `D:\PCG-doc-tools` (`C:\PCG-doc-tools` jika tidak ada drive D). Klik tombol lanjut lalu "Instal". Tidak perlu internet atau hak administrator.
4. Selesai: centang "Buka Alat Dokumen PCG sekarang", lalu klik "Selesai". Pintasan "Alat Dokumen PCG" dibuat di desktop.

## 3. Penggunaan

1. Klik dua kali pintasan di desktop. Browser membuka `http://127.0.0.1:8765/` (pertama kali sekitar 10–30 detik).
2. Pilih alat → unggah file → unduh hasilnya. File hanya diproses di komputer ini, tidak dikirim keluar.
3. Model OCR sudah terpasang (Mandarin Tradisional/Sederhana, Inggris, Vietnam, Indonesia); tidak perlu mengunduh apa pun.

## Untuk IT: area admin

- Di komputer tersebut, buka `http://127.0.0.1:8765/admin` (atau menu "Admin" di aplikasi).
- Bawaan adalah **mode pengguna tunggal**: tanpa akun atau kata sandi; siapa pun yang memakai komputer adalah administrator. Anda dapat menyalakan/mematikan alat, mengatur masa simpan file, pengaturan OCR, dan lain-lain.
- Login akun (peran, `jtdt-admin`) dapat diaktifkan di area admin untuk pemakaian bersama. Untuk komputer satu pengguna, sebaiknya tetap mode pengguna tunggal: versi offline ini tidak memiliki perintah `jtdt`, sehingga kata sandi yang lupa lebih sulit dipulihkan.

## 4. Pembaruan

Tidak perlu menghapus versi lama; ruang kerja, stempel, dan pengaturan (folder `data`) tetap disimpan.

- **Pembaruan sekali klik (paling mudah)**: di komputer yang terhubung internet, atau jika IT sudah mengatur folder bersama, saat membuka pintasan desktop akan muncul "Versi baru tersedia. Perbarui sekarang?". Klik "Ya"; aplikasi terbuka otomatis setelah sekitar 1 menit.

Atau perbarui manual: tutup Alat Dokumen PCG terlebih dahulu, lalu:

- **Pembaruan kecil** (`PCG-DocTools-Update-….exe`, jauh lebih kecil): klik dua kali; selesai sekitar 1 menit. Jika muncul pesan perlu komponen baru, gunakan penginstal lengkap.
- **Penginstal lengkap**: instal di atas versi lama.
- Tabel di bagian atas setiap halaman rilis menjelaskan file mana yang dipakai. Distribusi massal oleh IT: tambahkan `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART` setelah nama file exe.

## 5. Jika ada masalah

- Tidak bisa dibuka: kirim dua file di `D:\PCG-doc-tools\data\pcg-logs\` ke IT.
- Diblokir antivirus: minta IT menambahkan folder instalasi sebagai pengecualian.
- Hapus instalasi: Windows "Pengaturan" → "Aplikasi" → "PCG Document Tools" → "Copot pemasangan". Folder `data` tetap ada; hapus manual jika tidak diperlukan.
