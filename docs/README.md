# Dokumentasi Praktikum Flutter Lanjutan

Kumpulan dokumentasi praktikum per pertemuan. Setiap dokumentasi memuat tujuan pembelajaran, teori singkat, struktur berkas, penjelasan kode, penyelesaian latihan dan tugas, tabel pengujian, jawaban refleksi, panduan menjalankan, serta troubleshooting.

| Pertemuan | Topik | Dokumentasi |
| :---: | --- | --- |
| 1 | Pengenalan Flutter, Instalasi, dan Pembuatan Aplikasi Pertama | [`lib/pertemuan1/docs/README.md`](../lib/pertemuan1/docs/README.md) |
| 2 | Tata Letak, ListView, dan Navigasi Antar Halaman | [`lib/pertemuan2/docs/README.md`](../lib/pertemuan2/docs/README.md) |
| 3 | Formulir, Validasi Masukan, dan Manajemen State dengan Provider | [`lib/pertemuan3/docs/README.md`](../lib/pertemuan3/docs/README.md) |
| 4 | Mengambil Data dari REST API (HTTP, Async, FutureBuilder) | [`lib/pertemuan4/docs/README.md`](../lib/pertemuan4/docs/README.md) |
| 5 | Penyimpanan Lokal (SharedPreferences dan SQLite) | [`lib/pertemuan5/docs/README.md`](../lib/pertemuan5/docs/README.md) |
| 6 | Tema, Routing dan Navigasi, serta Animasi | [`lib/pertemuan6/docs/README.md`](../lib/pertemuan6/docs/README.md) |
| 7 | Mini Proyek Terpadu — TabungKu (To-Do List + Manajemen Keuangan) | [`lib/pertemuan7/docs/README.md`](../lib/pertemuan7/docs/README.md) |
| 8 | Docker Compose dan Kerangka Backend TabungKu Cloud | [`lib/pertemuan8/docs/README.md`](../lib/pertemuan8/docs/README.md) |
| 9 | REST API CRUD dengan FastAPI, SQLAlchemy, dan Alembic | [`lib/pertemuan9/docs/README.md`](../lib/pertemuan9/docs/README.md) |

## Dokumentasi Backend

Backend TabungKu Cloud untuk Pertemuan 8–9 berada di folder [`tabungku-cloud/`](../tabungku-cloud/). Penjelasan arsitektur, perintah Docker Compose, endpoint, migrasi Alembic, dan troubleshooting tersedia di [`tabungku-cloud/README.md`](../tabungku-cloud/README.md).

## Menjalankan Aplikasi per Pertemuan

Dari root proyek Flutter:

```bash
flutter pub get

# Pertemuan 7 — aplikasi TabungKu (SQLite)
flutter run -t lib/pertemuan7/pertemuan7.dart

# Pertemuan 8 — status dan info server
flutter run -t lib/pertemuan8/pertemuan8.dart

# Pertemuan 9 — demo CRUD dan laporan API
flutter run -t lib/pertemuan9/pertemuan9.dart
```

Pemeriksaan umum:

```bash
flutter analyze
flutter test
```
