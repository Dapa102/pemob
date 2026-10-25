# TabungKu Cloud — Backend Pertemuan 8 & 9

Backend REST API untuk mini proyek TabungKu. Materi Pertemuan 8 (Docker Compose, MySQL, kerangka FastAPI) dan Pertemuan 9 (CRUD SQLAlchemy, migrasi Alembic, Pydantic, laporan agregasi) digabung dalam satu stack agar dapat dijalankan sekali.

## Arsitektur

```text
+------------------+   HTTP/JSON   +------------------+        +------------+
| Flutter TabungKu | ------------> | FastAPI :8000    | -----> | MySQL 8.4  |
+------------------+               +------------------+        +------------+
                                          ^
                                          |
                                   +--------------+
                                   | Adminer :8081|
                                   +--------------+
```

Semua layanan dijalankan dengan `docker compose` pada folder ini.

## Struktur Folder

```text
tabungku-cloud/
├── .env.example              # contoh variabel lingkungan (salin ke .env)
├── .gitignore                # .env tidak boleh di-commit
├── docker-compose.yml        # mysql + api + adminer
├── README.md
└── backend/
    ├── Dockerfile
    ├── .dockerignore
    ├── requirements.txt
    ├── start.sh              # alembic upgrade head lalu uvicorn
    ├── alembic.ini
    ├── alembic/
    │   ├── env.py
    │   ├── script.py.mako
    │   └── versions/
    │       └── 0001_buat_tabel_kegiatan.py
    └── app/
        ├── config.py         # pydantic-settings (DATABASE_URL)
        ├── database.py       # engine, SessionLocal, Base, get_db
        ├── models.py         # model SQLAlchemy Kegiatan
        ├── schemas.py        # validasi Pydantic + aturan bisnis
        ├── main.py           # pendaftaran router
        └── routers/
            ├── health.py     # GET /health, GET /info
            ├── kegiatan.py   # CRUD /kegiatan
            └── laporan.py    # GET /laporan/harian, /laporan/rentang
```

Kode Flutter untuk Pertemuan 8 dan 9 berada di proyek Flutter utama:

- `lib/pertemuan8/` — konfigurasi alamat API, layanan health/info, halaman status dan pengaturan.
- `lib/pertemuan9/` — model JSON, `KegiatanApi`, `LaporanApi`, halaman demo CRUD/laporan.
- `test/pertemuan8_health_service_test.dart`
- `test/pertemuan9_kegiatan_api_test.dart`
- `test/pertemuan9_laporan_api_test.dart`

> Catatan adaptasi: modul menyarankan folder `mobile/` terpisah. Pada repositori ini seluruh praktikum Flutter berada dalam satu proyek (sesuai pola Pertemuan 1–7), sehingga kode Flutter tetap di `lib/pertemuan8` dan `lib/pertemuan9`. Backend tetap terpisah di folder ini. Cara menjalankannya sama.

## Prasyarat

- Docker Engine/Desktop + **Docker Compose V2** (`docker compose version`).
- Alokasi RAM Docker minimal 4 GB.
- Port yang dipakai: 8000 (API), 3307 (MySQL dari laptop), 8081 (Adminer).
- Koneksi internet untuk mengunduh `mysql:8.4`, `python:3.12-slim`, dan `adminer:5` (sekitar 700 MB).

Unduh image lebih dulu agar kelas tidak lambat:

```bash
docker pull mysql:8.4
docker pull python:3.12-slim
docker pull adminer:5
```

## Menjalankan

```bash
cd tabungku-cloud
cp .env.example .env
docker compose up -d --build
docker compose ps
```

Tunggu sampai layanan `mysql` berstatus `healthy` dan `api` berstatus `Up`.

Alamat penting:

| Layanan | URL |
| --- | --- |
| API | http://localhost:8000 |
| Swagger UI | http://localhost:8000/docs |
| Health | http://localhost:8000/health |
| Info | http://localhost:8000/info |
| Adminer | http://localhost:8081 |
| MySQL dari laptop | `localhost:3307` |

Adminer:
- System: MySQL / MariaDB
- Server: `mysql`
- Username: `tabungku`
- Password: `rahasia_tabungku`
- Database: `tabungku`

## Perintah Harian

```bash
docker compose logs -f api          # log API
docker compose restart api          # restart API
docker compose exec api sh          # masuk ke container API
docker compose exec api alembic current
docker compose exec api alembic check
docker compose exec mysql mysql -utabungku -p tabungku
docker compose stop mysql           # uji halaman 503 di Flutter
docker compose start mysql
docker compose down                 # container berhenti, volume tetap
docker compose down -v              # volume dihapus, data hilang
```

## Endpoint

### Health dan Info

| Method | URL | Keterangan |
| --- | --- | --- |
| GET | `/` | Pesan selamat datang |
| GET | `/health` | Status API + database + versi MySQL. Database mati → **503** dengan `database: "error"` |
| GET | `/info` | Nama aplikasi, versi, zona waktu, waktu server (latihan Pertemuan 8) |

Contoh `/health` sehat:

```json
{
  "status": "ok",
  "waktu_server": "2026-10-26T08:00:00",
  "database": "ok",
  "mysql_version": "8.4.0"
}
```

Contoh saat MySQL dimatikan (`docker compose stop mysql`):

```json
{
  "status": "error",
  "waktu_server": "2026-10-26T08:00:00",
  "database": "error",
  "mysql_version": null,
  "detail": "(2003, \"Can't connect to MySQL server on 'mysql'\")"
}
```

Kode 503 sengaja dipakai agar aplikasi dapat membedakan **API hidup, database mati** dari **API tidak dapat dihubungi** (galat jaringan).

### CRUD Kegiatan

| Method | URL | Kode sukses | Keterangan |
| --- | --- | --- | --- |
| GET | `/kegiatan?tanggal=&tipe=&selesai=&q=&urut=&limit=&offset=` | 200 | Filter, pencarian, pagination, `X-Total-Count` |
| GET | `/kegiatan/{id}` | 200 | Detail, 404 bila tidak ada |
| POST | `/kegiatan` | 201 | Validasi Pydantic + aturan bisnis |
| PUT | `/kegiatan/{id}` | 200 | Ganti seluruh data |
| PATCH | `/kegiatan/{id}` | 200 | Ubah sebagian, validasi ulang hasil gabungan |
| DELETE | `/kegiatan/{id}` | 204 | Hapus |

Contoh POST:

```json
{
  "judul": "Makan siang",
  "tanggal": "2026-10-06",
  "selesai": false,
  "tipe": "pengeluaran",
  "nominal": 15000,
  "kategori": "Makan"
}
```

Aturan bisnis yang ditolak dengan 422:
- judul kosong/spasi;
- nominal ≤ 0 untuk pemasukan/pengeluaran;
- kategori pengeluaran di luar `Makan, Transport, Belajar, Hiburan, Lainnya`;
- tanggal bukan format `YYYY-MM-DD`.

PATCH `{"nominal": 0}` pada pengeluaran juga ditolak karena data gabungan divalidasi ulang.

### Laporan (Tugas Pertemuan 9)

| Method | URL | Keterangan |
| --- | --- | --- |
| GET | `/laporan/harian?tanggal=YYYY-MM-DD` | Ringkasan + per kategori, dihitung dengan SQL |
| GET | `/laporan/rentang?mulai=...&sampai=...` | Ringkasan setiap hari, termasuk hari kosong; maksimal 31 hari |

Contoh hasil skenario modul 7:

```json
{
  "tanggal": "2026-10-06",
  "jumlah_kegiatan": 4,
  "selesai": 2,
  "pemasukan": 50000,
  "pengeluaran": 25000,
  "tabungan": 25000,
  "per_kategori": [
    { "kategori": "Makan", "total": 15000 },
    { "kategori": "Transport", "total": 10000 }
  ]
}
```

Query yang dipakai:

```sql
SELECT COUNT(*) AS jumlah,
       COALESCE(SUM(selesai), 0) AS selesai,
       COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0) AS pemasukan,
       COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0) AS pengeluaran
FROM kegiatan
WHERE tanggal = :tanggal
```

Rentang ditolak 400 bila `sampai < mulai` atau jumlah hari > 31.

## Migrasi Alembic

Migrasi dijalankan otomatis oleh `start.sh` saat container API menyala:

```bash
alembic upgrade head
exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Perintah manual:

```bash
docker compose exec api alembic current
docker compose exec api alembic check
docker compose exec api alembic history
docker compose exec api alembic downgrade -1
docker compose exec api alembic upgrade head
```

Membuat revisi otomatis (periksa hasilnya sebelum dipakai):

```bash
docker compose exec api alembic revision --autogenerate -m "tambah kolom catatan"
```

## Menghubungkan Flutter

Alamat API sesuai perangkat:

| Perangkat | Alamat |
| --- | --- |
| Emulator Android | `http://10.0.2.2:8000` |
| Simulator iOS | `http://localhost:8000` |
| HP fisik (Wi-Fi sama) | `http://IP-LAPTOP:8000` |

Jalankan:

```bash
# dari root proyek Flutter
flutter run -t lib/pertemuan8/pertemuan8.dart
# atau
flutter run -t lib/pertemuan9/pertemuan9.dart
```

Untuk HP fisik:

```bash
flutter run -t lib/pertemuan8/pertemuan8.dart \
  --dart-define=API_URL=http://192.168.1.10:8000
```

Alamat juga dapat diubah dari tab **Pengaturan** di aplikasi dan tersimpan dengan `shared_preferences`. Android sudah diberi izin `INTERNET` dan `usesCleartextTraffic="true"` khusus pengembangan.

## Pengujian

Flutter:

```bash
flutter analyze
flutter test
```

Tes yang relevan:
- `test/pertemuan8_health_service_test.dart` — sehat, 503, kode lain, validasi URL.
- `test/pertemuan9_kegiatan_api_test.dart` — JSON, filter URL, POST, PATCH, DELETE, 404, 422.
- `test/pertemuan9_laporan_api_test.dart` — laporan harian, rentang dengan hari kosong, 400.

Backend (opsional, memakai Swagger atau TestClient):
1. Buka `/docs`, jalankan POST/PUT/PATCH/DELETE dan periksa kode status.
2. Buka Adminer, pastikan isi tabel `kegiatan` sama dengan hasil GET.
3. `docker compose stop mysql` lalu buka `/health` → 503; buka halaman Status Server Flutter → API hidup, database mati.
4. `docker compose start mysql` lalu Periksa lagi → keduanya hidup.

## Troubleshooting

| Masalah | Solusi |
| --- | --- |
| `port is already allocated` | Hentikan MySQL/XAMPP lokal atau ubah port kiri (`3308:3306`). |
| `Cannot connect to the Docker daemon` | Jalankan Docker Desktop / `sudo systemctl start docker`. |
| `Can't connect to MySQL server on 'mysql'` | Tunggu `mysql` healthy; pastikan `depends_on: condition: service_healthy` dan healthcheck `-h 127.0.0.1`. |
| Perubahan `requirements.txt` tidak berpengaruh | `docker compose up -d --build`. |
| Flutter `Connection refused` di emulator | Gunakan `10.0.2.2`, bukan `localhost`. |
| HP fisik tidak tersambung | Satu Wi-Fi, izinkan port 8000 di firewall, coba buka `/health` dari browser HP. |
| `Cleartext HTTP traffic not permitted` | `android:usesCleartextTraffic="true"` (sudah diatur; hanya untuk pengembangan). |
| `Can't locate revision identified by ...` | Revisi di database tidak ada di folder. Saat pengembangan: `docker compose down -v` lalu jalankan ulang. |
| `Table 'kegiatan' already exists` | Tabel dibuat manual. Hapus tabel atau `alembic stamp 0001`. |
| `ModuleNotFoundError: No module named 'app'` | Pastikan `prepend_sys_path = .` di `alembic.ini` dan perintah dijalankan dari `/code`. |
| Lupa password MySQL setelah mengubah `.env` | Variabel `MYSQL_*` hanya dipakai saat volume pertama dibuat; reset dengan `docker compose down -v`. |
| Perubahan model tidak terdeteksi `--autogenerate` | Pastikan `from app import models` ada di `alembic/env.py`. |

## Keamanan

- `.env` tidak di-commit; hanya `.env.example`.
- Password contoh hanya untuk pengembangan.
- `usesCleartextTraffic` dan HTTP hanya untuk pengembangan. Produksi wajib HTTPS dan kredensial kuat.
- Endpoint belum memakai autentikasi JWT; materi tersebut ada pada Pertemuan 10.

## Dokumentasi Lengkap

- Pertemuan 8: [`../lib/pertemuan8/docs/README.md`](../lib/pertemuan8/docs/README.md)
- Pertemuan 9: [`../lib/pertemuan9/docs/README.md`](../lib/pertemuan9/docs/README.md)
