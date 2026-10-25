# Dokumentasi Praktikum Flutter Lanjutan - Pertemuan 8
Docker Compose dan Kerangka Backend TabungKu Cloud

## Informasi Praktikum
- Topik Praktikum: Perbedaan image, container, volume, dan network Docker; penulisan Dockerfile dan `docker-compose.yml` multi-layanan; variabel lingkungan, healthcheck, dan `depends_on`; API pertama dengan FastAPI dan Swagger UI; serta menghubungkan Flutter ke API dari emulator maupun HP fisik.
- Nama Mahasiswa: Dafa Rafi Nurwansyah
- NIM: 20240801157
- Program Studi: Teknik Informatika

---

## 1. Tujuan Pembelajaran
1. Menjelaskan perbedaan image, container, volume, dan network pada Docker.
2. Menulis Dockerfile untuk aplikasi Python dan `docker-compose.yml` berisi beberapa layanan.
3. Memakai variabel lingkungan (`.env`), healthcheck, dan `depends_on` agar layanan menyala berurutan.
4. Membuat API pertama dengan FastAPI dan membuka dokumentasinya di `/docs`.
5. Menghubungkan aplikasi Flutter ke API di laptop dari emulator maupun HP fisik.

---

## 2. Alat dan Bahan
- Docker Desktop (Windows/macOS) atau Docker Engine + plugin Compose (Linux). RAM Docker minimal 4 GB.
- Flutter SDK stabil (pengujian: 3.47.4) dan emulator Android/HP fisik.
- VS Code dengan ekstensi Docker dan Python.
- Port: 8000 (API), 3307 (MySQL dari laptop), 8081 (Adminer).
- Image: `mysql:8.4`, `python:3.12-slim`, `adminer:5` (sekitar 700 MB).
- Kode TabungKu Pertemuan 7 sebagai dasar aplikasi mobile.

---

## 3. Teori Singkat

### 3.1 Istilah Docker
| Istilah | Penjelasan | Analogi |
| --- | --- | --- |
| Image | Cetakan aplikasi yang tidak berubah (OS minimal + runtime + kode) | Resep kue |
| Container | Image yang sedang berjalan; bisa dibuat/dihapus kapan saja | Kue jadi |
| Volume | Penyimpanan di luar container; data tetap ada walau container dihapus | Kulkas |
| Network | Jaringan virtual antar-container; saling memanggil dengan nama layanan | Telepon antar-ruangan |
| Dockerfile | Langkah-langkah membuat image | Tulisan resep |
| docker-compose.yml | Daftar layanan beserta konfigurasi, dijalankan sekaligus | Menu satu paket |

### 3.2 Arsitektur TabungKu Cloud
```text
+--------------+   HTTP/JSON   +---------------+   +-----------+
| Flutter app  | ------------> | FastAPI :8000 |-> | MySQL 8.4 |
+--------------+               +---------------+   +-----------+
                                      ^
                                      |
                               +---------------+
                               | Adminer :8081 |
                               +---------------+
```

### 3.3 Alamat Server dari Perangkat
`localhost` di emulator berarti emulator itu sendiri, bukan laptop.

| Perangkat | Alamat API |
| --- | --- |
| Emulator Android | `http://10.0.2.2:8000` |
| Simulator iOS | `http://localhost:8000` |
| HP fisik (satu Wi-Fi) | `http://IP-LAPTOP:8000`, misalnya `http://192.168.1.10:8000` |

### 3.4 Mengapa 503?
Kode **503 Service Unavailable** berarti server API hidup tetapi layanan yang dibutuhkannya (database) tidak tersedia. Ini berbeda dari galat jaringan. Flutter harus membaca 503 sebagai "API hidup, database mati" agar pengguna mendapat pesan yang tepat.

---

## 4. Struktur Berkas Pertemuan 8

```text
tabungku-cloud/
├── .env.example
├── .gitignore
├── docker-compose.yml
├── README.md
└── backend/
    ├── Dockerfile
    ├── .dockerignore
    ├── requirements.txt
    ├── start.sh
    ├── alembic.ini
    ├── alembic/...
    └── app/
        ├── config.py
        ├── database.py
        ├── models.py          # ditambahkan pada Pertemuan 9
        ├── schemas.py         # ditambahkan pada Pertemuan 9
        ├── main.py
        └── routers/
            ├── health.py
            ├── kegiatan.py    # ditambahkan pada Pertemuan 9
            └── laporan.py     # tugas Pertemuan 9
```

Kode Flutter:

```text
lib/pertemuan8/
├── pertemuan8.dart              # entry point + MaterialApp
├── latihan.dart                 # membuka tab Info Server
├── tugas.dart                   # variasi tugas
├── config/api_config.dart       # alamat API + validasi + prefs
├── services/health_service.dart # GET /health + StatusServer
├── services/info_service.dart   # GET /info
├── pages/status_server_page.dart
├── pages/info_server_page.dart
├── pages/pengaturan_api_page.dart
├── pages/shell_page.dart
├── modul/modul-praktikum-flutter-pertemuan-8.pdf
└── docs/README.md

test/pertemuan8_health_service_test.dart
```

> Adaptasi struktur: modul menyarankan proyek Flutter baru di `tabungku-cloud/mobile`. Repositori ini menyimpan semua praktikum Flutter dalam satu proyek, sehingga kode mobile berada di `lib/pertemuan8` (dan `lib/pertemuan9`). Backend tetap terpisah di `tabungku-cloud/`. Fungsinya identik dan tetap dapat dijalankan dengan `flutter run -t ...`.

---

## 5. Dokumentasi Kode Lengkap

### A. Variabel Lingkungan (`.env.example`)

```env
# Salin menjadi .env lalu sesuaikan. Jangan commit .env!
COMPOSE_PROJECT_NAME=tabungku
MYSQL_ROOT_PASSWORD=rahasia_root
MYSQL_DATABASE=tabungku
MYSQL_USER=tabungku
MYSQL_PASSWORD=rahasia_tabungku
```

`COMPOSE_PROJECT_NAME=tabungku` membuat nama volume tetap `tabungku_mysql_data` (setara `name: tabungku` pada Compose V2, tetapi juga kompatibel dengan Compose V1).

`.gitignore`:

```gitignore
.env
**/__pycache__/
*.pyc
.venv/
```

Penjelasan:
1. Password tidak ditulis di `docker-compose.yml` yang ikut di-commit.
2. `.env` hanya ada di laptop masing-masing.
3. Variabel `MYSQL_*` hanya dipakai saat volume pertama kali dibuat.

---

### B. API Pertama (`backend/app/main.py`)

```python
from datetime import datetime

from fastapi import FastAPI

from .routers import health, kegiatan, laporan

app = FastAPI(title="TabungKu API", version="0.2.0")

app.include_router(health.router)
app.include_router(kegiatan.router)
app.include_router(laporan.router)


@app.get("/", tags=["beranda"])
def beranda():
    return {
        "pesan": "Selamat datang di TabungKu API. Dokumentasi: /docs",
        "waktu_server": datetime.now().isoformat(timespec="seconds"),
    }
```

Dekorator `@app.get("/")` mendaftarkan fungsi sebagai endpoint GET. Nilai `dict` otomatis diubah menjadi JSON. Dokumentasi interaktif tersedia di `/docs` (Swagger UI) dan `/redoc`.

---

### C. Konfigurasi dan Database

`backend/app/config.py`:

```python
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = (
        "mysql+pymysql://tabungku:rahasia_tabungku@localhost:3307/tabungku"
    )
    nama_aplikasi: str = "TabungKu API"
    versi: str = "0.2.0"
    zona_waktu: str = "Asia/Jakarta"


settings = Settings()
```

`backend/app/database.py`:

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from .config import settings

engine = create_engine(settings.database_url, pool_pre_ping=True)
SessionLocal = sessionmaker(
    bind=engine, autoflush=False, expire_on_commit=False,
)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

Penjelasan:
1. `pool_pre_ping=True` mengecek koneksi sebelum dipakai, berguna saat MySQL restart.
2. `get_db` adalah dependency FastAPI: satu session per request dan selalu ditutup, termasuk saat galat.
3. `Base` menjadi induk semua model tabel (dipakai Alembic pada Pertemuan 9).

---

### D. Health dan Info (`backend/app/routers/health.py`)

```python
@router.get("/health")
def health(response: Response, db: Session = Depends(get_db)):
    waktu = datetime.now().isoformat(timespec="seconds")
    try:
        if db.get_bind().dialect.name == "sqlite":
            kueri = text("SELECT sqlite_version()")
        else:
            kueri = text("SELECT VERSION()")
        versi_mysql = db.execute(kueri).scalar_one()
        return {
            "status": "ok",
            "waktu_server": waktu,
            "database": "ok",
            "mysql_version": versi_mysql,
        }
    except SQLAlchemyError as galat:
        response.status_code = 503
        return {
            "status": "error",
            "waktu_server": waktu,
            "database": "error",
            "mysql_version": None,
            "detail": str(galat.__cause__ or galat),
        }
```

Penjelasan:
1. `/health` tidak hanya membalas "ok"; ia benar-benar menjalankan `SELECT VERSION()` ke database.
2. Bila database mati, kode respons diubah menjadi **503** dan `database` bernilai `error`.
3. Fallback SQLite hanya untuk pengujian otomatis tanpa MySQL; produksi memakai MySQL.
4. `detail` membantu debugging, misalnya `(2003, "Can't connect to MySQL server on 'mysql'")`.

Endpoint latihan:

```python
@router.get("/info")
def info():
    return {
        "nama_aplikasi": settings.nama_aplikasi,
        "versi": settings.versi,
        "zona_waktu": tzname[0],
        "waktu_server": datetime.now().isoformat(timespec="seconds"),
    }
```

---

### E. Dockerfile

```dockerfile
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /code

# Salin requirements lebih dulu agar layer pip install di-cache.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["sh", "start.sh"]
```

`backend/start.sh`:

```sh
#!/bin/sh
set -e

echo "Menunggu database dan menjalankan migrasi..."
alembic upgrade head

echo "Menjalankan API..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Penjelasan:
1. `requirements.txt` disalin sebelum kode agar mengubah kode tidak memicu `pip install` ulang.
2. `--host 0.0.0.0` wajib agar API dapat diakses dari luar container.
3. `--reload` memantau perubahan kode (bind mount) saat pengembangan.
4. `start.sh` menjalankan migrasi terlebih dahulu, lalu `exec uvicorn` agar sinyal container diteruskan ke proses utama.
5. `.dockerignore` berisi `__pycache__/`, `*.pyc`, `.venv/`, `.env` agar tidak masuk image.

---

### F. `docker-compose.yml`

```yaml
services:
  mysql:
    image: mysql:8.4
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      TZ: Asia/Jakarta
    ports:
      - "3307:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    healthcheck:
      test:
        ["CMD-SHELL", "mysqladmin ping -h 127.0.0.1 -uroot -p$$MYSQL_ROOT_PASSWORD --silent"]
      interval: 5s
      timeout: 5s
      retries: 20
      start_period: 20s

  api:
    build: ./backend
    restart: unless-stopped
    environment:
      DATABASE_URL: mysql+pymysql://${MYSQL_USER}:${MYSQL_PASSWORD}@mysql:3306/${MYSQL_DATABASE}
      TZ: Asia/Jakarta
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/code
    depends_on:
      mysql:
        condition: service_healthy

  adminer:
    image: adminer:5
    restart: unless-stopped
    environment:
      ADMINER_DEFAULT_SERVER: mysql
    ports:
      - "8081:8080"
    depends_on:
      mysql:
        condition: service_healthy

volumes:
  mysql_data:
```

| Bagian | Fungsi |
| --- | --- |
| `${MYSQL_USER}` | Diisi dari `.env` di folder yang sama |
| `"3307:3306"` | Port laptop 3307 diteruskan ke port 3306 container |
| `mysql_data` | Volume bernama; data tidak hilang saat container dibuat ulang |
| `@mysql:3306` | Di network Compose, nama layanan `mysql` menjadi host |
| `healthcheck` | Menandai MySQL siap; `-h 127.0.0.1` memaksa TCP |
| `condition: service_healthy` | API baru jalan setelah MySQL benar-benar siap |
| `./backend:/code` | Bind mount; perubahan kode langsung terlihat oleh `--reload` |
| `$$` | Escape agar `$` dibaca shell di dalam container, bukan Compose |

---

### G. Menjalankan dan Checkpoint

```bash
cd tabungku-cloud
cp .env.example .env
docker compose up -d --build
docker compose ps
docker compose logs -f api
```

Checkpoint:
- `docker compose ps` menunjukkan `mysql` **healthy** dan `api` **Up**.
- `http://localhost:8000/health` membalas `{"status":"ok", ...}`.
- `http://localhost:8000/docs` menampilkan Swagger UI.
- `http://localhost:8081` menampilkan Adminer (tugas).
- Mengubah teks di `main.py` lalu menyimpan langsung terlihat setelah browser dimuat ulang.

Perintah dasar:

| Perintah | Kegunaan |
| --- | --- |
| `docker compose exec api sh` | Masuk ke shell container API |
| `docker compose exec mysql mysql -utabungku -p tabungku` | Klien MySQL |
| `docker compose restart api` | Restart satu layanan |
| `docker compose down` | Hentikan/hapus container; volume tetap |
| `docker compose down -v` | Hapus volume; seluruh data hilang |
| `docker compose stop mysql` | Uji kondisi 503 |
| `docker compose start mysql` | Nyalakan MySQL lagi |

---

### H. Sisi Flutter: Konfigurasi Alamat (`config/api_config.dart`)

```dart
const apiUrlBawaan = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

const batasWaktu = Duration(seconds: 10);

final apiUrl = ValueNotifier<String>(apiUrlBawaan);

Future<void> muatApiUrl() async {
  final prefs = await SharedPreferences.getInstance();
  apiUrl.value = prefs.getString('api_url') ?? apiUrlBawaan;
}

Future<void> simpanApiUrl(String alamat) async {
  final bersih = alamat.trim();
  apiUrl.value = bersih;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('api_url', bersih);
}

String? validasiUrl(String? teks) {
  final nilai = (teks ?? '').trim();
  if (nilai.isEmpty) return 'Alamat API wajib diisi';
  final uri = Uri.tryParse(nilai);
  if (uri == null) return 'Format URL tidak sah';
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return 'Gunakan http:// atau https://';
  }
  if (uri.host.isEmpty) return 'Host tidak boleh kosong';
  if (nilai.contains(' ')) return 'URL tidak boleh mengandung spasi';
  return null;
}
```

Penjelasan:
1. `String.fromEnvironment` memungkinkan alamat diubah tanpa mengubah kode:
   `flutter run --dart-define=API_URL=http://192.168.1.10:8000`.
2. Nilai tersimpan di `shared_preferences` menimpa nilai bawaan saat aplikasi dibuka.
3. Validasi format URL mencegah pengguna menyimpan teks seperti `10.0.2.2:8000` atau `ftp://...`.

---

### I. Layanan Health (`services/health_service.dart`)

```dart
class StatusServer {
  final int kode;
  final String status;
  final String? database;
  final String? mysqlVersion;
  final String waktuServer;
  final Duration latensi;
  final String? pesan;

  bool get apiHidup => kode == 200 || kode == 503;
  bool get databaseHidup => database == 'ok';
}

Future<StatusServer> cekServer({http.Client? client, String? alamat}) async {
  final c = client ?? http.Client();
  final dasar = (alamat ?? apiUrl.value).replaceAll(RegExp(r'/$'), '');
  final jam = Stopwatch()..start();
  try {
    final res = await c.get(Uri.parse('$dasar/health')).timeout(batasWaktu);
    jam.stop();
    if (res.statusCode != 200 && res.statusCode != 503) {
      throw HealthException('Server membalas kode ${res.statusCode}',
          kode: res.statusCode);
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return StatusServer(
      kode: res.statusCode,
      status: (data['status'] as String?) ?? 'unknown',
      database: data['database'] as String?,
      mysqlVersion: data['mysql_version'] as String?,
      waktuServer: (data['waktu_server'] as String?) ?? '-',
      pesan: data['detail'] as String?,
      latensi: jam.elapsed,
    );
  } on HealthException {
    rethrow;
  } catch (e) {
    throw HealthException('Tidak dapat menghubungi server: $e');
  } finally {
    if (client == null) c.close();
  }
}
```

Penjelasan:
1. **503 tidak dilempar sebagai exception.** Status 503 tetap menjadi `StatusServer` dengan `apiHidup = true` dan `databaseHidup = false`.
2. Hanya kode selain 200/503 dan kegagalan jaringan yang menjadi `HealthException`.
3. `Stopwatch` mengukur latensi. `client` opsional membuat fungsi mudah diuji dengan `MockClient` tanpa server.
4. Client hanya ditutup bila dibuat sendiri; client yang diberikan pengujian tidak ikut ditutup.

---

### J. Halaman Status Server (`pages/status_server_page.dart`)

```dart
@override
void initState() {
  super.initState();
  _future = cekServer();
  apiUrl.addListener(_periksa);
}

@override
void dispose() {
  apiUrl.removeListener(_periksa);
  super.dispose();
}

void _periksa() {
  if (!mounted) return;
  setState(() => _future = cekServer());
}
```

Tampilan memisahkan:
- **Status API**: hijau bila kode 200/503, merah bila jaringan gagal.
- **Status Database**: hijau bila `database == "ok"`, merah bila `error`.
- Alamat API, waktu server, latensi, versi MySQL.
- Pesan khusus "API hidup, tetapi database tidak dapat dihubungi" untuk 503.
- Tombol **Periksa lagi** mengganti `_future`.

Saat alamat API diubah di Pengaturan, listener `apiUrl` memicu pemeriksaan ulang otomatis.

---

### K. Pengaturan Alamat API (`pages/pengaturan_api_page.dart`)

```dart
Future<void> _ubahAlamat(BuildContext context) async {
  final hasil = await showDialog<String>(
    context: context,
    builder: (_) => DialogAlamatApi(awal: apiUrl.value),
  );
  if (hasil == null || !context.mounted) return;
  await simpanApiUrl(hasil);
  // ... SnackBar konfirmasi ...
}
```

Dialog memakai `Form` + `TextFormField(validator: validasiUrl)`. Alamat tersimpan di `shared_preferences` dan ditampilkan lewat `ValueListenableBuilder`.

---

### L. Entry Point Flutter

```dart
Future<void> jalankanAplikasi({
  String judul = 'TabungKu Cloud',
  int tabAwal = 0,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await muatApiUrl();
  runApp(AplikasiCloud(judul: judul, tabAwal: tabAwal));
}

Future<void> main() => jalankanAplikasi();
```

| Berkas | Kegunaan |
| --- | --- |
| `pertemuan8.dart` | Aplikasi praktikum + tugas, tab awal Status |
| `latihan.dart` | Langsung membuka tab Info Server (latihan 1) |
| `tugas.dart` | Variasi tugas, tab awal Status |

---

## 6. Penyelesaian Latihan Mandiri

### Latihan 1 — Endpoint `GET /info`
Backend:

```python
@router.get("/info")
def info():
    return {
        "nama_aplikasi": settings.nama_aplikasi,
        "versi": settings.versi,
        "zona_waktu": tzname[0],
        "waktu_server": datetime.now().isoformat(timespec="seconds"),
    }
```

Flutter menampilkannya di `pages/info_server_page.dart` dengan `FutureBuilder<InfoServer>`: nama aplikasi, versi, zona waktu, waktu server, dan latensi. Jalankan `flutter run -t lib/pertemuan8/latihan.dart` untuk langsung membuka tab Info.

### Latihan 2 — Mengubah port API menjadi 9000
Yang diubah hanya sisi laptop pada `docker-compose.yml`:

```yaml
ports:
  - "9000:8000"
```

Port di dalam container tetap 8000 karena uvicorn mendengarkan 8000. Flutter harus diarahkan ke port baru:

```bash
flutter run -t lib/pertemuan8/pertemuan8.dart \
  --dart-define=API_URL=http://10.0.2.2:9000
```

Atau ubah lewat halaman Pengaturan menjadi `http://10.0.2.2:9000`.

### Latihan 3 — Ketahanan volume MySQL
1. Jalankan stack, buat tabel uji lewat Adminer/MySQL:
   ```bash
   docker compose exec mysql mysql -utabungku -p tabungku \
     -e "CREATE TABLE uji(id INT);"
   ```
2. `docker compose down` lalu `docker compose up -d`.
3. Tabel `uji` **masih ada** karena data berada di volume `mysql_data`.
4. `docker compose down -v` lalu `docker compose up -d`.
5. Tabel `uji` **hilang** karena volume dihapus.

### Latihan 4 — Ukuran image
```bash
docker images
docker system df
```

Bandingkan `python:3.12-slim` (sekitar 130–150 MB) dengan `python:3.12` (sekitar 1 GB). Image penuh berisi compiler dan pustaka pengembangan yang tidak dibutuhkan saat runtime. Untuk produksi, `slim` lebih hemat; jika butuh kompilasi paket, gunakan multi-stage build.

---

## 7. Penyelesaian Tugas

### 7.1 Adminer
Ditambahkan pada `docker-compose.yml`:

```yaml
adminer:
  image: adminer:5
  restart: unless-stopped
  environment:
    ADMINER_DEFAULT_SERVER: mysql
  ports:
    - "8081:8080"
  depends_on:
    mysql:
      condition: service_healthy
```

Buka `http://localhost:8081`, pilih MySQL, server `mysql`, user `tabungku`, password dari `.env`, database `tabungku`.

### 7.2 `/health` Memeriksa Database
- Menjalankan `SELECT VERSION()` (MySQL) dan membalas `mysql_version`.
- Bila database tidak dapat dihubungi: **503** dengan `database: "error"`, `mysql_version: null`, dan `detail`.
- Bila API tidak dapat dihubungi sama sekali: Flutter menampilkan galat jaringan (bukan 503).

### 7.3 Halaman Status Memisahkan API dan Database
`StatusServer` memiliki `apiHidup` dan `databaseHidup`. Halaman menampilkan dua kartu terpisah. Kode 503 dibaca sebagai API hidup, database mati, dan menampilkan detail galat database.

### 7.4 Alamat API Dapat Diubah dan Tersimpan
- Tab **Pengaturan** → **Alamat API** → dialog.
- Validasi: wajib diisi, skema `http/https`, host tidak kosong, tanpa spasi.
- Disimpan dengan `shared_preferences` (`api_url`), dimuat saat `main()`.
- Mengubah alamat langsung memicu pemeriksaan ulang halaman Status dan Info.

### 7.5 Unit Test MockClient Tiga Kasus
`test/pertemuan8_health_service_test.dart`:

```dart
test('kasus sehat: API dan database hidup', () async {
  final client = MockClient((req) async {
    return http.Response(jsonEncode({
      'status': 'ok',
      'waktu_server': '2026-10-26T08:00:00',
      'database': 'ok',
      'mysql_version': '8.4.0',
    }), 200);
  });
  final status = await cekServer(
    client: client, alamat: 'http://contoh.test:8000',
  );
  expect(status.apiHidup, isTrue);
  expect(status.databaseHidup, isTrue);
});

test('kasus 503: API hidup, database mati', () async {
  final client = MockClient((req) async => http.Response(jsonEncode({
    'status': 'error', 'database': 'error',
    'detail': "Can't connect to MySQL server on 'mysql'",
  }), 503));
  final status = await cekServer(
    client: client, alamat: 'http://contoh.test:8000',
  );
  expect(status.kode, 503);
  expect(status.apiHidup, isTrue);
  expect(status.databaseHidup, isFalse);
});

test('kasus kode lain: dilempar sebagai HealthException', () async {
  final client = MockClient((req) async => http.Response('galat', 500));
  expect(
    () => cekServer(client: client, alamat: 'http://contoh.test:8000'),
    throwsA(isA<HealthException>().having((e) => e.kode, 'kode', 500)),
  );
});
```

Hasil: seluruh tes lulus (`flutter test`). Ditambah pengujian `validasiUrl`.

---

## 8. Tabel Pengujian dan Checkpoint

| No | Pemeriksaan | Cara | Hasil |
| --- | --- | --- | --- |
| 1 | Konfigurasi Compose sah | `docker compose config` (atau `docker-compose config`) | Lulus (services mysql, api, adminer terbaca) |
| 2 | Container menyala berurutan | `docker compose up -d --build`, `docker compose ps` | mysql healthy, api Up |
| 3 | Swagger UI | Buka `/docs` | Menampilkan endpoint |
| 4 | Health sehat | `GET /health` | 200, `database: ok`, `mysql_version` terisi |
| 5 | Health database mati | `docker compose stop mysql` lalu `GET /health` | 503, `database: error`, `detail` terisi |
| 6 | Adminer | Buka `localhost:8081` | Tabel `kegiatan` dan `alembic_version` terlihat |
| 7 | Status API/database terpisah | Halaman Status Server | Dua kartu status, 503 dibaca API hidup |
| 8 | Alamat API tersimpan | Ubah di Pengaturan, tutup/buka aplikasi | Alamat tetap |
| 9 | Unit test MockClient | `flutter test test/pertemuan8_health_service_test.dart` | 4 tes lulus |
| 10 | Analisis kode | `flutter analyze` | Tidak ada masalah |

Catatan verifikasi: logika backend juga diuji otomatis memakai `TestClient` dengan database SQLite dan sesi MySQL yang sengaja gagal; hasilnya 200 untuk sehat, 503 untuk database mati, dan 200 untuk `/info`. Checkpoint Docker di atas dijalankan pada mesin dengan Docker Compose V2.

---

## 9. Jawaban Pertanyaan Refleksi Modul

### 1. Apa yang terjadi pada data MySQL bila container dihapus, dan mengapa? Kapan data benar-benar hilang?
Data tetap ada karena MySQL menyimpan datanya di volume bernama `mysql_data`, bukan di lapisan container. Menghapus container hanya menghapus sistem berkas sementara. Data benar-benar hilang bila volume dihapus (`docker compose down -v` atau `docker volume rm tabungku_mysql_data`), atau bila file volume rusak.

### 2. Mengapa API memanggil database dengan host `mysql`, sedangkan dari laptop memakai `localhost:3307`?
Di dalam network Compose, setiap layanan memiliki nama DNS internal. API berada di network yang sama dengan layanan `mysql`, sehingga host `mysql` menuju container database pada port internal 3306. Dari laptop, container tidak berada di `localhost`; port 3307 diteruskan ke port 3306 container, jadi diakses lewat `localhost:3307`.

### 3. Apa risikonya bila `depends_on` tidak memakai `condition: service_healthy`?
Compose hanya menunggu container MySQL *dimulai*, bukan *siap menerima koneksi*. API dapat langsung mencoba koneksi saat MySQL masih inisialisasi dan gagal (`Can't connect to MySQL server`). Dengan healthcheck + `service_healthy`, API baru dijalankan setelah `mysqladmin ping` berhasil.

### 4. Mengapa emulator Android tidak dapat memakai `localhost` untuk menghubungi laptop?
`localhost` di dalam emulator menunjuk ke emulator itu sendiri, bukan ke komputer host. Android menyediakan alamat khusus `10.0.2.2` yang diteruskan ke `localhost` laptop. Simulator iOS berbagi network host sehingga `localhost` dapat dipakai.

### 5. Mengapa kode status 503 lebih tepat daripada 200 saat database mati?
Kode 200 berarti permintaan berhasil sepenuhnya. Saat database mati, API tidak dapat menyelesaikan pekerjaan utamanya; membalas 200 akan menyesatkan klien dan monitoring. 503 menyatakan layanan sementara tidak tersedia, tetapi juga membedakannya dari kegagalan jaringan: klien tahu API hidup dan dapat menampilkan pesan "database mati" serta mencoba lagi nanti.

---

## 10. Panduan Menjalankan Hingga Berhasil

1. Pastikan Docker berjalan:
   ```bash
   docker version
   docker compose version
   ```
2. Siapkan backend:
   ```bash
   cd tabungku-cloud
   cp .env.example .env
   docker compose up -d --build
   docker compose ps
   ```
3. Buka `http://localhost:8000/health`, `http://localhost:8000/docs`, dan `http://localhost:8081`.
4. Jalankan Flutter dari root proyek:
   ```bash
   flutter pub get
   flutter run -t lib/pertemuan8/pertemuan8.dart
   ```
5. Untuk HP fisik:
   ```bash
   flutter run -t lib/pertemuan8/pertemuan8.dart \
     --dart-define=API_URL=http://192.168.1.10:8000
   ```
6. Uji kondisi database mati:
   ```bash
   docker compose stop mysql
   ```
   Tekan **Periksa lagi** di aplikasi → API tetap hijau, database merah. Nyalakan lagi:
   ```bash
   docker compose start mysql
   ```
7. Jalankan latihan dan tugas:
   ```bash
   flutter run -t lib/pertemuan8/latihan.dart
   flutter run -t lib/pertemuan8/tugas.dart
   ```
8. Pemeriksaan:
   ```bash
   flutter analyze
   flutter test
   ```

### Troubleshooting
| Masalah | Solusi |
| --- | --- |
| Port bentrok | Hentikan XAMPP/MySQL lokal atau ubah port kiri. |
| Docker daemon mati | Jalankan Docker Desktop / `sudo systemctl start docker`. |
| API tidak bisa konek MySQL | Tunggu sehat; pastikan healthcheck dan `service_healthy`. |
| Flutter connection refused | Emulator: `10.0.2.2`; HP: IP laptop dan satu Wi-Fi. |
| HTTP diblokir | `android:usesCleartextTraffic="true"` (sudah diatur). |
| Alamat salah tersimpan | Ubah lewat Pengaturan atau hapus data aplikasi. |
| `MissingPluginException` | Hentikan aplikasi sepenuhnya lalu jalankan ulang setelah menambah paket. |

---

## 11. Referensi
1. Modul Praktikum Flutter Lanjutan - Pertemuan 8: Docker Compose dan Kerangka Backend TabungKu Cloud.
2. Dokumentasi Docker Compose: https://docs.docker.com/compose
3. FastAPI First Steps: https://fastapi.tiangolo.com/tutorial/first-steps
4. Image MySQL resmi: https://hub.docker.com/_/mysql
5. Jaringan emulator Android: https://developer.android.com/studio/run/emulator-networking
6. Adminer: https://www.adminer.org
