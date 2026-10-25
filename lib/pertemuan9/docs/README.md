# Dokumentasi Praktikum Flutter Lanjutan - Pertemuan 9
REST API CRUD dengan FastAPI, SQLAlchemy, dan Alembic

## Informasi Praktikum
- Topik Praktikum: Perancangan endpoint REST, pemetaan tabel dengan SQLAlchemy 2, migrasi skema dengan Alembic, validasi Pydantic dan aturan bisnis, CRUD lengkap dengan filter/pagination/PUT/PATCH, laporan agregasi SQL, serta lapisan layanan API di Flutter yang dapat diuji tanpa server.
- Nama Mahasiswa: Dafa Rafi Nurwansyah
- NIM: 20240801157
- Program Studi: Teknik Informatika
- Prasyarat: Pertemuan 8 (stack Docker Compose TabungKu Cloud berjalan).

---

## 1. Tujuan Pembelajaran
1. Merancang endpoint REST untuk satu sumber daya: method, URL, kode status, dan format JSON.
2. Memetakan tabel ke kelas Python dengan ORM SQLAlchemy 2.
3. Mengelola perubahan skema database dengan migrasi Alembic.
4. Memvalidasi data masuk dan aturan bisnis dengan Pydantic.
5. Membuat endpoint CRUD lengkap dengan filter, pagination, PUT, dan PATCH, lalu mengujinya di Swagger UI.
6. Membuat lapisan layanan API di Flutter yang dapat diuji tanpa server.

---

## 2. Alat dan Bahan
- Hasil Pertemuan 8: `tabungku-cloud/` dengan MySQL, FastAPI, dan Adminer.
- Docker Engine/Desktop + Docker Compose V2.
- Browser untuk Swagger UI (`http://localhost:8000/docs`) dan Adminer (`http://localhost:8081`).
- Flutter SDK stabil (pengujian: 3.47.4) dan Dart 3.13.3.
- Paket Flutter: `http`, `shared_preferences` (sudah dipakai Pertemuan 8).
- Port: 8000 (API), 3307 (MySQL dari laptop), 8081 (Adminer).

---

## 3. Teori Singkat

### 3.1 Endpoint REST
REST memodelkan data sebagai *resource* yang diakses lewat URL. Method HTTP menentukan aksinya.

| Method + URL | Aksi | Kode sukses | Kode gagal umum |
| --- | --- | --- | --- |
| `GET /kegiatan?tanggal=...` | Daftar dengan filter | 200 | 422 parameter salah |
| `GET /kegiatan/{id}` | Detail satu data | 200 | 404 tidak ditemukan |
| `POST /kegiatan` | Membuat data baru | 201 Created | 422 data tidak valid |
| `PUT /kegiatan/{id}` | Mengganti seluruh data | 200 | 404, 422 |
| `PATCH /kegiatan/{id}` | Mengubah sebagian field | 200 | 404, 422 |
| `DELETE /kegiatan/{id}` | Menghapus | 204 No Content | 404 |

### 3.2 ORM dan SQLAlchemy 2
ORM (Object Relational Mapping) memetakan tabel menjadi kelas, sehingga kode cukup memanggil `db.add(k)` tanpa menulis `INSERT` manual. Query yang dibuat ORM memakai parameter, sehingga aman dari SQL injection. SQLAlchemy 2 memakai anotasi `Mapped[...]` sebagai sumber tipe kolom.

### 3.3 Alembic
Pada Pertemuan 7, skema SQLite dibuat di `onCreate` dan diubah lewat `onUpgrade` dengan nomor versi. Alembic menerapkan konsep yang sama di server:

- Setiap perubahan skema ditulis sebagai berkas revisi bernomor (`0001`, `0002`, ...).
- `alembic upgrade head` menerapkan revisi yang belum dijalankan.
- Riwayat revisi dicatat di tabel `alembic_version`.
- `alembic check` membandingkan model dengan database dan memberi tahu bila ada selisih.

Dengan cara ini semua laptop dan server memiliki skema yang sama.

### 3.4 Pydantic
Pydantic memeriksa JSON masuk berdasarkan *type hint*. Bila ada yang salah, FastAPI otomatis membalas **422** beserta lokasi dan pesan galatnya. Aturan bisnis Pertemuan 7 (nominal > 0, kategori wajib untuk pengeluaran) ditulis sebagai validator.

### 3.5 Session per request
Setiap request mendapat satu `Session` database dari dependency `get_db`. Session itu otomatis ditutup setelah respons dikirim, termasuk saat terjadi galat.

### 3.6 Perbedaan tipe data SQLite dan MySQL

| SQLite (Pertemuan 7) | MySQL (Pertemuan 9) | Alasan |
| --- | --- | --- |
| `tanggal TEXT` `'yyyy-MM-dd'` | `DATE` | Tipe tanggal asli; bisa dibandingkan dan memakai `BETWEEN` |
| `selesai INTEGER 0/1` | `BOOLEAN` (`tinyint(1)`) | Di JSON tetap `true`/`false` |
| `tipe TEXT` | `ENUM('tanpa','pemasukan','pengeluaran')` | Database menolak nilai di luar daftar |
| tidak ada | `created_at`, `updated_at` | Jejak waktu untuk admin dan sinkronisasi |

### 3.7 Agregasi di SQL
Laporan tidak boleh dihitung dengan mengambil seluruh baris ke Python lalu menjumlahkannya. MySQL melakukan agregasi yang jauh lebih efisien:

- `COUNT(*)` menghitung jumlah baris.
- `SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END)` menjumlahkan hanya pemasukan.
- `COALESCE(..., 0)` mengganti `NULL` (saat tidak ada baris) dengan `0`.
- `GROUP BY` mengelompokkan per kategori atau per tanggal.

---

## 4. Struktur Berkas Pertemuan 9

Backend (satu stack dengan Pertemuan 8):

```text
tabungku-cloud/
├── .env.example
├── docker-compose.yml
├── README.md
└── backend/
    ├── Dockerfile
    ├── requirements.txt
    ├── start.sh
    ├── alembic.ini
    ├── alembic/
    │   ├── env.py
    │   ├── script.py.mako
    │   └── versions/
    │       └── 0001_buat_tabel_kegiatan.py
    └── app/
        ├── config.py
        ├── database.py
        ├── models.py
        ├── schemas.py
        ├── main.py
        └── routers/
            ├── health.py
            ├── kegiatan.py
            └── laporan.py
```

Flutter:

```text
lib/pertemuan9/
├── pertemuan9.dart                  # entry point + MaterialApp + ShellPage
├── latihan.dart                     # tab Kegiatan dengan panel latihan
├── tugas.dart                       # langsung membuka tab Laporan
├── models/kegiatan.dart             # Kegiatan, KategoriTotal, Ringkasan, laporan
├── services/api_exception.dart      # pesan galat FastAPI -> siap tampil
├── services/kegiatan_api.dart       # daftar, detail, tambah, ubah, setSelesai, hapus
├── services/laporan_api.dart        # harian, rentang
├── pages/kegiatan_page.dart         # daftar + filter + hapus + toggle selesai
├── pages/form_kegiatan_page.dart    # form tambah/ubah (POST/PUT)
├── pages/laporan_page.dart          # laporan harian + grafik 7 hari
├── pages/shell_page.dart            # tiga tab: Kegiatan, Laporan, Pengaturan
├── utils/format.dart                # Rupiah, tanggal ISO, label pendek
├── modul/modul-praktikum-flutter-pertemuan-9.pdf
└── docs/README.md

test/pertemuan9_kegiatan_api_test.dart
test/pertemuan9_laporan_api_test.dart
```

> Adaptasi struktur: modul menyarankan proyek Flutter baru di `tabungku-cloud/mobile`. Repositori ini menyimpan semua praktikum Flutter dalam satu proyek, sehingga kode mobile berada di `lib/pertemuan9` dan memakai konfigurasi alamat dari `lib/pertemuan8/config/api_config.dart`. Backend tetap terpisah di `tabungku-cloud/`. Fungsinya identik dan dijalankan dengan `flutter run -t lib/pertemuan9/pertemuan9.dart`.
>
> Modul menyebut UI Pertemuan 9 belum diubah dan integrasi penuh dilakukan pada Pertemuan 11. Di repositori ini ditambahkan **aplikasi demo** tiga tab agar seluruh endpoint dapat dicoba langsung dari HP. Lapisan layanan (`KegiatanApi`, `LaporanApi`) tetap menjadi bagian yang akan dipakai UI TabungKu pada Pertemuan 11.

---

## 5. Dokumentasi Kode Lengkap

### A. Session dan Base (`backend/app/database.py`)

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from .config import settings

# pool_pre_ping: cek koneksi sebelum dipakai, berguna bila MySQL sempat restart.
engine = create_engine(settings.database_url, pool_pre_ping=True)

SessionLocal = sessionmaker(
    bind=engine, autoflush=False, expire_on_commit=False,
)


class Base(DeclarativeBase):
    """Kelas induk semua model tabel."""


def get_db():
    """Dependency FastAPI: satu session per request, selalu ditutup."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

Penjelasan:
1. `expire_on_commit=False` membuat objek tetap dapat dibaca setelah `commit()` tanpa query ulang.
2. `get_db` dipakai lewat `db: Session = Depends(get_db)`; FastAPI menutup session pada blok `finally`.
3. `Base.metadata` menjadi sumber informasi tabel untuk Alembic.

---

### B. Model Kegiatan (`backend/app/models.py`)

```python
import enum
from datetime import date, datetime

from sqlalchemy import Date, DateTime, Enum, String, func
from sqlalchemy.orm import Mapped, mapped_column

from .database import Base


class Tipe(str, enum.Enum):
    tanpa = "tanpa"
    pemasukan = "pemasukan"
    pengeluaran = "pengeluaran"


class Kegiatan(Base):
    __tablename__ = "kegiatan"

    id: Mapped[int] = mapped_column(primary_key=True)
    judul: Mapped[str] = mapped_column(String(100))
    # index=True: hampir semua query memfilter atau mengurutkan tanggal.
    tanggal: Mapped[date] = mapped_column(Date, index=True)
    selesai: Mapped[bool] = mapped_column(default=False)
    tipe: Mapped[Tipe] = mapped_column(Enum(Tipe), default=Tipe.tanpa)
    nominal: Mapped[int] = mapped_column(default=0)
    kategori: Mapped[str] = mapped_column(String(30), default="-")
    created_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.now(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.now(), onupdate=func.now(),
    )
```

Penjelasan:
1. `Tipe` mewarisi `str` dan `enum.Enum` agar JSON berisi teks `"pemasukan"`, bukan angka.
2. `index=True` pada `tanggal` mempercepat filter dan `BETWEEN` laporan.
3. `created_at` diisi database saat `INSERT`; `updated_at` diperbarui otomatis saat `UPDATE`.
4. `ENUM` MySQL menolak nilai tipe di luar daftar, sehingga data tetap konsisten walau ada klien lain.

---

### C. Migrasi Alembic

`backend/alembic.ini` (bagian penting):

```ini
[alembic]
script_location = alembic
file_template = %%(rev)s_%%(slug)s
prepend_sys_path = .

# URL database sengaja tidak ditulis di sini. env.py membacanya dari
# app.config.settings agar hanya ada satu sumber konfigurasi.
```

`file_template` menghasilkan nama berkas seperti `0001_buat_tabel_kegiatan.py` sehingga urutan revisi mudah dibaca.

`backend/alembic/env.py`:

```python
from logging.config import fileConfig

from alembic import context
from sqlalchemy import create_engine, pool

from app import models  # noqa: F401  (mendaftarkan tabel ke Base.metadata)
from app.config import settings
from app.database import Base

config = context.config
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """Menjalankan migrasi tanpa koneksi (menghasilkan SQL saja)."""
    context.configure(
        url=settings.database_url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Menjalankan migrasi dengan koneksi ke database."""
    connectable = create_engine(
        settings.database_url, poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
        )
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

Poin penting:
1. `from app import models` wajib; tanpa impor ini, `Base.metadata` kosong dan `--autogenerate` tidak mendeteksi tabel.
2. URL database hanya dibaca dari `settings`, tidak diduplikasi di `alembic.ini`.
3. Mode offline (`alembic upgrade head --sql`) berguna untuk memeriksa SQL yang akan dijalankan.

`backend/alembic/versions/0001_buat_tabel_kegiatan.py`:

```python
"""buat tabel kegiatan"""
from alembic import op
import sqlalchemy as sa

revision: str = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "kegiatan",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("judul", sa.String(100), nullable=False),
        sa.Column("tanggal", sa.Date(), nullable=False),
        sa.Column(
            "selesai", sa.Boolean(), nullable=False,
            server_default=sa.false(),
        ),
        sa.Column(
            "tipe",
            sa.Enum("tanpa", "pemasukan", "pengeluaran", name="tipe"),
            nullable=False,
            server_default="tanpa",
        ),
        sa.Column(
            "nominal", sa.Integer(), nullable=False, server_default="0",
        ),
        sa.Column(
            "kategori", sa.String(30), nullable=False, server_default="-",
        ),
        sa.Column(
            "created_at", sa.DateTime(), nullable=False,
            server_default=sa.func.now(),
        ),
        sa.Column(
            "updated_at", sa.DateTime(), nullable=False,
            server_default=sa.func.now(),
        ),
    )
    op.create_index("ix_kegiatan_tanggal", "kegiatan", ["tanggal"])


def downgrade() -> None:
    op.drop_index("ix_kegiatan_tanggal", table_name="kegiatan")
    op.drop_table("kegiatan")
```

`server_default` dipakai agar baris yang dibuat di luar aplikasi (misalnya lewat Adminer) tetap mendapat nilai awal yang sah.

Migrasi dijalankan otomatis setiap container API menyala (`backend/start.sh`):

```sh
#!/bin/sh
set -e

echo "Menunggu database dan menjalankan migrasi..."
alembic upgrade head

echo "Menjalankan API..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Di `docker-compose.yml`, bind mount `./backend:/code` membuat berkas revisi hasil autogenerate langsung terlihat di laptop.

Perintah pemeriksaan:

```bash
docker compose exec api alembic current
# 0001 (head)

docker compose exec api alembic check
# No new upgrade operations detected.
```

`alembic check` memastikan model dan database tidak berbeda. Jika ada selisih, Alembic menyarankan revisi baru.

---

### D. Skema Pydantic dan Aturan Bisnis (`backend/app/schemas.py`)

```python
from datetime import date, datetime

from pydantic import (
    BaseModel, ConfigDict, Field, field_validator, model_validator,
)

from .models import Tipe

KATEGORI_PENGELUARAN = [
    "Makan", "Transport", "Belajar", "Hiburan", "Lainnya",
]


class KegiatanBase(BaseModel):
    judul: str = Field(
        min_length=1, max_length=100, examples=["Makan siang"],
    )
    tanggal: date = Field(examples=["2026-10-06"])
    selesai: bool = False
    tipe: Tipe = Tipe.tanpa
    nominal: int = Field(default=0, ge=0, examples=[15000])
    kategori: str = Field(default="-", examples=["Makan"])


class KegiatanInput(KegiatanBase):
    """Data dari klien untuk POST dan PUT."""

    @field_validator("judul")
    @classmethod
    def judul_tidak_kosong(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("judul wajib diisi")
        return v

    @model_validator(mode="after")
    def cek_aturan_bisnis(self):
        if self.tipe == Tipe.tanpa:
            self.nominal = 0
            self.kategori = "-"
            return self
        if self.nominal <= 0:
            raise ValueError(
                "nominal wajib lebih dari 0 untuk pemasukan/pengeluaran"
            )
        if self.tipe == Tipe.pemasukan:
            self.kategori = "-"
        elif self.kategori not in KATEGORI_PENGELUARAN:
            raise ValueError(
                "kategori pengeluaran harus salah satu dari: "
                + ", ".join(KATEGORI_PENGELUARAN)
            )
        return self


class KegiatanPatch(BaseModel):
    """PATCH: semua field opsional, hanya yang dikirim yang diubah."""

    judul: str | None = None
    tanggal: date | None = None
    selesai: bool | None = None
    tipe: Tipe | None = None
    nominal: int | None = Field(default=None, ge=0)
    kategori: str | None = None


class KegiatanOut(KegiatanBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime
```

Aturan yang ditegakkan:

| Input | Hasil |
| --- | --- |
| `judul` kosong atau hanya spasi | 422 `judul wajib diisi` |
| `tipe = tanpa` | `nominal` dipaksa `0`, `kategori` dipaksa `-` |
| `tipe = pemasukan` | `kategori` otomatis `-` (walau klien mengirim `Makan`) |
| `tipe = pengeluaran`, `nominal <= 0` | 422 nominal wajib lebih dari 0 |
| `tipe = pengeluaran`, kategori di luar daftar | 422 berisi daftar kategori sah |
| `tanggal = "06-10-2026"` | 422; format wajib `YYYY-MM-DD` |

> Catatan: `Field(ge=0)` pada `KegiatanPatch` menolak nominal negatif lebih awal, sedangkan `nominal = 0` tetap lolos ke validator bisnis saat PATCH agar hasil gabungan dinilai ulang.

---

### E. Router CRUD (`backend/app/routers/kegiatan.py`)

```python
from datetime import date

from fastapi import (
    APIRouter, Depends, HTTPException, Query, Response, status,
)
from fastapi.exceptions import RequestValidationError
from pydantic import ValidationError
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Kegiatan, Tipe
from ..schemas import KegiatanInput, KegiatanOut, KegiatanPatch

router = APIRouter(prefix="/kegiatan", tags=["kegiatan"])


def _ambil_atau_404(db: Session, kegiatan_id: int) -> Kegiatan:
    k = db.get(Kegiatan, kegiatan_id)
    if k is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND, "Kegiatan tidak ditemukan",
        )
    return k
```

#### 1. Daftar dengan filter dan pagination

```python
@router.get("", response_model=list[KegiatanOut])
def daftar_kegiatan(
    response: Response,
    tanggal: date | None = None,
    tipe: Tipe | None = None,
    selesai: bool | None = None,
    q: str | None = Query(None, description="Cari di judul"),
    urut: str = Query(
        "terbaru",
        pattern="^(terbaru|terlama)$",
        description="terbaru atau terlama",
    ),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
):
    stmt = select(Kegiatan)
    if tanggal:
        stmt = stmt.where(Kegiatan.tanggal == tanggal)
    if tipe:
        stmt = stmt.where(Kegiatan.tipe == tipe)
    if selesai is not None:
        stmt = stmt.where(Kegiatan.selesai == selesai)
    if q:
        stmt = stmt.where(Kegiatan.judul.contains(q))

    total = db.scalar(select(func.count()).select_from(stmt.subquery()))
    response.headers["X-Total-Count"] = str(total)

    if urut == "terlama":
        stmt = stmt.order_by(Kegiatan.id.asc())
    else:
        stmt = stmt.order_by(Kegiatan.selesai, Kegiatan.id.desc())
    stmt = stmt.limit(limit).offset(offset)
    return db.scalars(stmt).all()
```

Penjelasan:
1. `stmt` dibangun bertahap; filter hanya ditambahkan bila parameternya diisi.
2. `X-Total-Count` dihitung dari subquery **sebelum** `limit/offset`, jadi berisi jumlah seluruh data yang cocok.
3. `selesai` memakai `is not None` agar `false` tetap dianggap filter, bukan "tidak diisi".
4. Urutan `terbaru` menaruh yang belum selesai lebih dulu (`selesai = 0`), lalu id terbesar. Urutan `terlama` memakai id naik.
5. `limit` dibatasi 1–200 agar satu permintaan tidak mengambil seluruh tabel.

#### 2. Detail, POST, PUT

```python
@router.get("/{kegiatan_id}", response_model=KegiatanOut)
def detail_kegiatan(kegiatan_id: int, db: Session = Depends(get_db)):
    return _ambil_atau_404(db, kegiatan_id)


@router.post(
    "", response_model=KegiatanOut,
    status_code=status.HTTP_201_CREATED,
)
def tambah_kegiatan(data: KegiatanInput, db: Session = Depends(get_db)):
    k = Kegiatan(**data.model_dump())
    db.add(k)
    db.commit()
    db.refresh(k)  # id dan created_at diisi database
    return k


@router.put("/{kegiatan_id}", response_model=KegiatanOut)
def ganti_kegiatan(
    kegiatan_id: int,
    data: KegiatanInput,
    db: Session = Depends(get_db),
):
    k = _ambil_atau_404(db, kegiatan_id)
    for kolom, nilai in data.model_dump().items():
        setattr(k, kolom, nilai)
    db.commit()
    db.refresh(k)
    return k
```

`db.refresh(k)` wajib setelah `commit()` agar `id`, `created_at`, dan nilai `server_default` terbaca dari database.

#### 3. PATCH dengan validasi ulang

```python
@router.patch("/{kegiatan_id}", response_model=KegiatanOut)
def ubah_sebagian(
    kegiatan_id: int,
    data: KegiatanPatch,
    db: Session = Depends(get_db),
):
    """Contoh: {"selesai": true} untuk mencentang kegiatan."""
    k = _ambil_atau_404(db, kegiatan_id)
    gabungan = KegiatanOut.model_validate(k).model_dump()
    gabungan.update(data.model_dump(exclude_unset=True))
    try:
        # Validasi ulang agar aturan bisnis tetap berlaku setelah digabung.
        valid = KegiatanInput.model_validate(gabungan)
    except ValidationError as e:
        raise RequestValidationError(
            e.errors(include_url=False, include_context=False)
        ) from e
    for kolom, nilai in valid.model_dump().items():
        setattr(k, kolom, nilai)
    db.commit()
    db.refresh(k)
    return k
```

Alur PATCH:
1. Ambil data lama, ubah ke `dict`.
2. Timpa hanya field yang dikirim (`exclude_unset=True`).
3. Validasi ulang **seluruh** data gabungan memakai aturan `KegiatanInput`.
4. Jika gagal, FastAPI membalas 422 dengan format yang sama seperti validasi bawaan.
5. Jika lolos, semua kolom hasil validasi ditulis kembali.

Tanpa langkah ini, `{"nominal": 0}` pada pengeluaran akan lolos dan melanggar aturan bisnis Pertemuan 7.

#### 4. DELETE

```python
@router.delete(
    "/{kegiatan_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def hapus_kegiatan(kegiatan_id: int, db: Session = Depends(get_db)):
    db.delete(_ambil_atau_404(db, kegiatan_id))
    db.commit()
```

DELETE membalas **204 No Content** tanpa badan respons. Menghapus id yang tidak ada menghasilkan **404**.

---

### F. Laporan Agregasi (`backend/app/routers/laporan.py`)

```python
router = APIRouter(prefix="/laporan", tags=["laporan"])

_QUERY_HARIAN = text(
    """
    SELECT COUNT(*) AS jumlah,
           COALESCE(SUM(selesai), 0) AS selesai,
           COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0)
               AS pemasukan,
           COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0)
               AS pengeluaran
    FROM kegiatan
    WHERE tanggal = :tanggal
    """
)

_QUERY_KATEGORI = text(
    """
    SELECT kategori, SUM(nominal) AS total
    FROM kegiatan
    WHERE tanggal = :tanggal AND tipe = 'pengeluaran'
    GROUP BY kategori
    ORDER BY total DESC
    """
)

_QUERY_RENTANG = text(
    """
    SELECT tanggal,
           COUNT(*) AS jumlah,
           COALESCE(SUM(selesai), 0) AS selesai,
           COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0)
               AS pemasukan,
           COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0)
               AS pengeluaran
    FROM kegiatan
    WHERE tanggal BETWEEN :mulai AND :sampai
    GROUP BY tanggal
    ORDER BY tanggal
    """
)
```

#### 1. Laporan harian

```python
@router.get("/harian")
def laporan_harian(
    tanggal: date = Query(..., examples=["2026-10-06"]),
    db: Session = Depends(get_db),
):
    baris = db.execute(
        _QUERY_HARIAN, {"tanggal": tanggal},
    ).mappings().one()
    kategori = db.execute(
        _QUERY_KATEGORI, {"tanggal": tanggal},
    ).mappings().all()
    hasil = {"tanggal": tanggal.isoformat(), **_ringkasan(baris)}
    hasil["per_kategori"] = [
        {"kategori": r["kategori"], "total": int(r["total"] or 0)}
        for r in kategori
    ]
    return hasil
```

`_ringkasan` mengubah hasil query menjadi:

```python
{
    "jumlah_kegiatan": ...,
    "selesai": ...,
    "pemasukan": ...,
    "pengeluaran": ...,
    "tabungan": pemasukan - pengeluaran,
}
```

Karena memakai `COALESCE`, tanggal tanpa data tetap membalas angka `0`, bukan `null`.

#### 2. Laporan rentang

```python
@router.get("/rentang")
def laporan_rentang(
    mulai: date = Query(..., examples=["2026-10-01"]),
    sampai: date = Query(..., examples=["2026-10-07"]),
    db: Session = Depends(get_db),
):
    if sampai < mulai:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            "rentang terbalik: sampai harus >= mulai",
        )
    jumlah_hari = (sampai - mulai).days + 1
    if jumlah_hari > 31:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            "rentang maksimal 31 hari",
        )

    baris = db.execute(
        _QUERY_RENTANG, {"mulai": mulai, "sampai": sampai},
    ).mappings().all()
    per_tanggal = {_tanggal_iso(r["tanggal"]): r for r in baris}

    hari = []
    for i in range(jumlah_hari):
        t = mulai + timedelta(days=i)
        kunci = t.isoformat()
        if kunci in per_tanggal:
            hari.append({"tanggal": kunci, **_ringkasan(per_tanggal[kunci])})
        else:
            hari.append({
                "tanggal": kunci,
                "jumlah_kegiatan": 0,
                "selesai": 0,
                "pemasukan": 0,
                "pengeluaran": 0,
                "tabungan": 0,
            })

    return {
        "mulai": mulai.isoformat(),
        "sampai": sampai.isoformat(),
        "jumlah_hari": jumlah_hari,
        "hari": hari,
    }
```

Penjelasan:
1. Satu query `GROUP BY tanggal` mengambil semua hari yang punya data.
2. Hari kosong diisi `0` oleh Python agar grafik tetap memiliki satu titik per tanggal.
3. Rentang terbalik atau lebih dari 31 hari ditolak **400 Bad Request**.
4. `_tanggal_iso` menangani perbedaan tipe hasil: MySQL mengembalikan `date`, SQLite (untuk pengujian) mengembalikan `str`.

---

### G. Pendaftaran Router (`backend/app/main.py`)

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

Swagger UI membaca seluruh router dan menampilkan skema request/response secara otomatis di `/docs`.

---

### H. Model JSON Flutter (`lib/pertemuan9/models/kegiatan.dart`)

```dart
enum Tipe { tanpa, pemasukan, pengeluaran }

class Kegiatan {
  final int? id;
  final String judul;
  final String tanggal;
  final bool selesai;
  final Tipe tipe;
  final int nominal;
  final String kategori;

  const Kegiatan({
    this.id,
    required this.judul,
    required this.tanggal,
    this.selesai = false,
    this.tipe = Tipe.tanpa,
    this.nominal = 0,
    this.kategori = '-',
  });

  /// JSON untuk POST/PUT. id tidak dikirim karena ada di URL.
  Map<String, Object?> toJson() => {
    'judul': judul,
    'tanggal': tanggal,
    'selesai': selesai,
    'tipe': tipe.name,
    'nominal': nominal,
    'kategori': kategori,
  };

  factory Kegiatan.fromJson(Map<String, dynamic> j) => Kegiatan(
    id: j['id'] as int,
    judul: j['judul'] as String,
    tanggal: j['tanggal'] as String,
    selesai: j['selesai'] as bool,
    tipe: Tipe.values.byName(j['tipe'] as String),
    nominal: j['nominal'] as int,
    kategori: j['kategori'] as String,
  );
}
```

Perbedaan dengan `toMap()` SQLite:
1. `selesai` berupa `bool`, bukan `0/1`.
2. `id` tidak dikirim saat POST/PUT karena sudah ada di URL.
3. `tipe.name` menghasilkan teks yang diterima `ENUM` MySQL.

Model laporan:

```dart
class Ringkasan {
  final int jumlahKegiatan;
  final int selesai;
  final int pemasukan;
  final int pengeluaran;
  final int tabungan;

  factory Ringkasan.fromJson(Map<String, dynamic> j) => Ringkasan(
    jumlahKegiatan: j['jumlah_kegiatan'] as int,
    selesai: j['selesai'] as int,
    pemasukan: j['pemasukan'] as int,
    pengeluaran: j['pengeluaran'] as int,
    tabungan: j['tabungan'] as int,
  );
}

class LaporanHarian {
  final String tanggal;
  final Ringkasan ringkasan;
  final List<KategoriTotal> perKategori;
}
```

`KategoriTotal`, `HariLaporan`, dan `LaporanRentang` mengikuti pola yang sama dan membaca `per_kategori` serta `hari` sebagai list.

---

### I. ApiException (`lib/pertemuan9/services/api_exception.dart`)

```dart
class ApiException implements Exception {
  final int? kode;
  final String pesan;

  const ApiException(this.pesan, {this.kode});

  /// - HTTPException -> {"detail": "Kegiatan tidak ditemukan"}
  /// - validasi 422 -> {"detail": [{"loc": [...], "msg": "..."}]}
  factory ApiException.dariRespons(http.Response res) {
    var pesan = 'Server membalas kode ${res.statusCode}';
    try {
      final detail =
          (jsonDecode(res.body) as Map<String, dynamic>)['detail'];
      if (detail is String) {
        pesan = detail;
      } else if (detail is List) {
        pesan = detail.map((e) {
          final item = e as Map<String, dynamic>;
          final msg = (item['msg'] as String? ?? 'Data tidak valid')
              .replaceFirst('Value error, ', '');
          final loc = item['loc'];
          if (loc is List && loc.isNotEmpty) {
            return '${loc.last}: $msg';
          }
          return msg;
        }).join('\n');
      }
    } catch (_) {
      // Badan respons bukan JSON (misalnya halaman galat 502 dari proxy).
    }
    return ApiException(pesan, kode: res.statusCode);
  }

  @override
  String toString() => pesan;
}
```

Dua bentuk galat FastAPI ditangani:
1. `HTTPException` → `detail` berupa teks, misalnya `Kegiatan tidak ditemukan`.
2. Validasi → `detail` berupa daftar; lokasi field diambil dari `loc.last` sehingga pesan menjadi `nominal: nominal wajib lebih dari 0`. Awalan `Value error, ` dibuang agar pesan ramah pengguna.

---

### J. KegiatanApi (`lib/pertemuan9/services/kegiatan_api.dart`)

```dart
class KegiatanApi {
  final http.Client _client;
  final String _alamat;

  KegiatanApi({http.Client? client, String? alamat})
    : _client = client ?? http.Client(),
      _alamat = (alamat ?? apiUrl.value).replaceAll(RegExp(r'/$'), '');

  static const _json = {'Content-Type': 'application/json'};

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$_alamat$path');
    return query == null || query.isEmpty
        ? uri
        : uri.replace(queryParameters: query);
  }

  http.Response _cek(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException.dariRespons(res);
    }
    return res;
  }
```

Method yang tersedia:

| Method | Endpoint | Kegunaan |
| --- | --- | --- |
| `daftar(...)` | `GET /kegiatan` | Filter tanggal/tipe/selesai, pencarian, urutan, pagination |
| `detail(id)` | `GET /kegiatan/{id}` | Satu kegiatan |
| `tambah(k)` | `POST /kegiatan` | Membuat data, mengharapkan 201 |
| `ubah(id, k)` | `PUT /kegiatan/{id}` | Mengganti seluruh data |
| `setSelesai(id, bool)` | `PATCH /kegiatan/{id}` | Hanya mengirim `{"selesai": ...}` |
| `hapus(id)` | `DELETE /kegiatan/{id}` | Mengharapkan 204 |

Contoh `daftar`:

```dart
Future<List<Kegiatan>> daftar({
  String? tanggal,
  Tipe? tipe,
  bool? selesai,
  String? q,
  String urut = 'terbaru',
  int? limit,
  int? offset,
}) async {
  final query = <String, String>{
    'tanggal': ?tanggal,
    if (tipe != null) 'tipe': tipe.name,
    if (selesai != null) 'selesai': selesai.toString(),
    if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
    'urut': urut,
    if (limit != null) 'limit': limit.toString(),
    if (offset != null) 'offset': offset.toString(),
  };
  final res = _cek(
    await _client.get(_uri('/kegiatan', query)).timeout(batasWaktu),
  );
  final data = jsonDecode(res.body) as List<dynamic>;
  return data
      .map((e) => Kegiatan.fromJson(e as Map<String, dynamic>))
      .toList();
}
```

`{'tanggal': ?tanggal}` adalah *null-aware element* Dart 3.8+: entri hanya dimasukkan bila `tanggal` tidak null.

Contoh PATCH:

```dart
Future<Kegiatan> setSelesai(int id, bool selesai) async {
  final res = _cek(
    await _client.patch(
      _uri('/kegiatan/$id'),
      headers: _json,
      body: jsonEncode({'selesai': selesai}),
    ).timeout(batasWaktu),
  );
  return Kegiatan.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
}
```

`_alamat` diambil dari `apiUrl` Pertemuan 8, sehingga alamat API yang diubah di tab Pengaturan langsung dipakai. Tanda `/` di akhir dibuang agar tidak muncul `//kegiatan`.

---

### K. LaporanApi (`lib/pertemuan9/services/laporan_api.dart`)

```dart
class LaporanApi {
  final http.Client _client;
  final String _alamat;

  LaporanApi({http.Client? client, String? alamat})
    : _client = client ?? http.Client(),
      _alamat = (alamat ?? apiUrl.value).replaceAll(RegExp(r'/$'), '');

  Future<LaporanHarian> harian(String tanggal) async {
    final res = _cek(
      await _client
          .get(_uri('/laporan/harian', {'tanggal': tanggal}))
          .timeout(batasWaktu),
    );
    return LaporanHarian.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  Future<LaporanRentang> rentang(String mulai, String sampai) async {
    final res = _cek(
      await _client
          .get(_uri('/laporan/rentang', {
            'mulai': mulai,
            'sampai': sampai,
          }))
          .timeout(batasWaktu),
    );
    return LaporanRentang.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  void tutup() => _client.close();
}
```

Semua respons di luar 2xx (termasuk 400 rentang terbalik) dilempar sebagai `ApiException` yang siap ditampilkan.

---

### L. Halaman Demo Flutter

| Berkas | Isi |
| --- | --- |
| `pages/kegiatan_page.dart` | `FutureBuilder` memuat `GET /kegiatan`; checkbox memanggil PATCH; menu Ubah/Hapus; tarik untuk muat ulang; tombol uji tanggal salah |
| `pages/form_kegiatan_page.dart` | Form tambah/ubah; validasi lokal + pesan 422 dari backend; `SegmentedButton` untuk tipe; pemilih tanggal |
| `pages/laporan_page.dart` | Kartu tabungan/pemasukan/pengeluaran, daftar kategori, grafik 7 hari dari `/laporan/rentang` |
| `pages/shell_page.dart` | `NavigationBar` + `IndexedStack` tiga tab: Kegiatan, Laporan, Pengaturan |
| `pertemuan9.dart` | `jalankanApiApp()` memuat `apiUrl` lalu menjalankan `ApiApp` |
| `latihan.dart` | `modeLatihan: true` menampilkan panel filter/urutan dan tombol uji tanggal |
| `tugas.dart` | `tabAwal: 1` langsung membuka tab Laporan |

Contoh pemuatan data dan penanganan galat:

```dart
Future<List<Kegiatan>> _ambil() {
  return _api.daftar(selesai: _selesai, urut: _urut);
}

void _muat() {
  if (!mounted) return;
  setState(() => _future = _ambil());
}
```

`FutureBuilder` membedakan tiga keadaan: menunggu (spinner), galat (kartu merah + tombol **Coba lagi**), dan data (daftar atau pesan kosong). Saat backend mati, pesan menyarankan menjalankan `docker compose up -d` dan memeriksa alamat API.

Form mengirim data berikut:

```dart
final data = Kegiatan(
  id: widget.kegiatan?.id,
  judul: _judul.text.trim(),
  tanggal: tanggalIso(_tanggal),
  selesai: widget.kegiatan?.selesai ?? false,
  tipe: _tipe,
  nominal: _tipe == Tipe.tanpa ? 0 : int.parse(_nominal.text.trim()),
  kategori: _tipe == Tipe.pengeluaran ? _kategori : '-',
);
```

Nilai `tanggal` selalu `YYYY-MM-DD`, sesuai kontrak API. Validasi ganda tetap dipakai: form mencegah input salah sejak awal, backend tetap memvalidasi karena API dapat dipanggil klien lain.

---

## 6. Penyelesaian Latihan Mandiri

### Latihan 1 — Filter `selesai` pada `GET /kegiatan`

Backend menambahkan parameter opsional:

```python
selesai: bool | None = None,

if selesai is not None:
    stmt = stmt.where(Kegiatan.selesai == selesai)
```

`is not None` penting: `?selesai=false` harus menghasilkan filter `false`, bukan diabaikan.

Flutter menambahkan parameter dan chip:

```dart
Future<List<Kegiatan>> daftar({bool? selesai, ...}) { ... }
```

```dart
ChoiceChip(
  label: const Text('Selesai'),
  selected: _selesai == true,
  onSelected: (_) {
    setState(() {
      _selesai = true;
      _future = _ambil();
    });
  },
),
```

Tersedia tiga pilihan: **Semua** (`null`), **Selesai** (`true`), **Belum** (`false`). Jalankan `flutter run -t lib/pertemuan9/latihan.dart` untuk mencoba.

### Latihan 2 — Parameter `urut`

Backend:

```python
urut: str = Query("terbaru", pattern="^(terbaru|terlama)$"),

if urut == "terlama":
    stmt = stmt.order_by(Kegiatan.id.asc())
else:
    stmt = stmt.order_by(Kegiatan.selesai, Kegiatan.id.desc())
```

`pattern` membuat nilai selain `terbaru`/`terlama` ditolak **422** oleh FastAPI, tanpa kode validasi manual.

Flutter memakai dropdown:

```dart
DropdownButton<String>(
  value: _urut,
  items: const [
    DropdownMenuItem(value: 'terbaru', child: Text('Terbaru')),
    DropdownMenuItem(value: 'terlama', child: Text('Terlama')),
  ],
  onChanged: (v) {
    setState(() {
      _urut = v ?? 'terbaru';
      _future = _ambil();
    });
  },
)
```

### Latihan 3 — Revisi Alembic `0001b` menambah kolom `catatan`

1. Tambahkan kolom pada model:

   ```python
   from sqlalchemy import Text

   catatan: Mapped[str | None] = mapped_column(Text, nullable=True)
   ```

2. Buat revisi otomatis:

   ```bash
   docker compose exec api alembic revision \
     --autogenerate -m "tambah kolom catatan"
   ```

   Alembic membuat berkas dengan id acak. Ubah id revisi, nama berkas (misalnya menjadi `0001b_tambah_kolom_catatan.py`), dan `down_revision` agar sesuai modul:

   ```python
   """tambah kolom catatan"""
   from alembic import op
   import sqlalchemy as sa

   revision = "0001b"
   down_revision = "0001"


   def upgrade() -> None:
       op.add_column(
           "kegiatan",
           sa.Column("catatan", sa.Text(), nullable=True),
       )


   def downgrade() -> None:
       op.drop_column("kegiatan", "catatan")
   ```

3. Terapkan dan periksa:

   ```bash
   docker compose exec api alembic upgrade head
   docker compose exec api alembic current
   # 0001b (head)
   ```

4. Buka Adminer → tabel `kegiatan` → kolom `catatan` muncul dan boleh `NULL`.

5. Uji pembatalan:

   ```bash
   docker compose exec api alembic downgrade -1
   docker compose exec api alembic current
   # 0001
   ```

   Setelah halaman Adminer dimuat ulang, kolom `catatan` **hilang**. Ini membuktikan `downgrade()` bekerja.

6. Modul meminta revisi ini dihapus sebelum Pertemuan 10. Urutannya: jalankan `downgrade -1` **dulu** (agar database kembali ke `0001`), baru hapus berkas `0001b_*.py`. Bila berkas dihapus saat database masih di `0001b`, Alembic membalas `Can't locate revision identified by '0001b'`.

> Catatan: `--autogenerate` hanya mendeteksi perubahan bila `from app import models` ada di `alembic/env.py`. Hasil autogenerate wajib diperiksa; mengganti nama kolom bisa terbaca sebagai "hapus lalu tambah" dan berpotensi menghilangkan data.

### Latihan 4 — Mengirim `"tanggal": "06-10-2026"`

Format yang diwajibkan adalah **ISO 8601** `YYYY-MM-DD`. String `06-10-2026` tidak dapat diurai Pydantic sebagai `date`, sehingga FastAPI membalas **422 Unprocessable Entity**.

Bentuk respons (disederhanakan):

```json
{
  "detail": [
    {
      "type": "date_from_datetime_parsing",
      "loc": ["query", "tanggal"],
      "msg": "Input should be a valid date or datetime, invalid date separator, expected `-`",
      "input": "06-10-2026"
    }
  ]
}
```

Yang penting saat membaca galat:
1. `loc` menunjukkan lokasi parameter, misalnya `query.tanggal` atau `body.tanggal`.
2. `msg` menjelaskan format yang diharapkan.
3. `ApiException` mengubahnya menjadi pesan `tanggal: Input should be a valid date...`, lalu UI menambahkan penjelasan bahwa format yang benar adalah `YYYY-MM-DD` (contoh `2026-10-06`).

Tombol **Uji tanggal salah** pada `latihan.dart` sengaja mengirim `'06-10-2026'` dan menampilkan dialog berisi respons 422 tersebut.

---

## 7. Penyelesaian Tugas

### 7.1 Endpoint `GET /laporan/harian`

Membalas jumlah kegiatan, selesai, pemasukan, pengeluaran, tabungan, tanggal, dan `per_kategori` yang diurutkan dari terbesar. Perhitungan dilakukan di SQL memakai `COUNT`, `SUM(CASE WHEN ...)`, `COALESCE`, dan `GROUP BY` — bukan perulangan Python atas seluruh baris.

```python
_QUERY_HARIAN = text(
    """
    SELECT COUNT(*) AS jumlah,
           COALESCE(SUM(selesai), 0) AS selesai,
           COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0)
               AS pemasukan,
           COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0)
               AS pengeluaran
    FROM kegiatan
    WHERE tanggal = :tanggal
    """
)
```

`tabungan` dihitung dari hasil agregasi: `pemasukan - pengeluaran`. Kategori hanya mengambil baris `pengeluaran` dan diurutkan `total DESC`.

### 7.2 Endpoint `GET /laporan/rentang`

Satu query `GROUP BY tanggal`, lalu hari tanpa data diisi nol:

```python
WHERE tanggal BETWEEN :mulai AND :sampai
GROUP BY tanggal
ORDER BY tanggal
```

Validasi:
- `sampai < mulai` → **400** `rentang terbalik: sampai harus >= mulai`.
- Jumlah hari > 31 → **400** `rentang maksimal 31 hari`.

### 7.3 Skenario "Contoh Skenario Satu Hari" Pertemuan 7

Masukkan empat kegiatan berikut pada tanggal `2026-10-06` lewat tab **Kegiatan** atau Swagger UI:

| Judul | Tipe | Nominal | Kategori | Selesai |
| --- | --- | ---: | --- | :---: |
| Kerja freelance desain poster | pemasukan | 50.000 | - | tidak |
| Makan siang di kantin | pengeluaran | 15.000 | Makan | ya |
| Pulang naik angkot | pengeluaran | 10.000 | Transport | ya |
| Belajar Flutter di perpustakaan | tanpa | 0 | - | tidak |

Hasil `GET /laporan/harian?tanggal=2026-10-06`:

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

Angka tersebut **persis** seperti yang diminta modul: 4 kegiatan, 2 selesai, pemasukan 50.000, pengeluaran 25.000 (Makan 15.000 + Transport 10.000), tabungan 25.000.

### 7.4 Laporan rentang termasuk hari kosong

`GET /laporan/rentang?mulai=2026-10-05&sampai=2026-10-07`:

```json
{
  "mulai": "2026-10-05",
  "sampai": "2026-10-07",
  "jumlah_hari": 3,
  "hari": [
    {
      "tanggal": "2026-10-05",
      "jumlah_kegiatan": 0,
      "selesai": 0,
      "pemasukan": 0,
      "pengeluaran": 0,
      "tabungan": 0
    },
    {
      "tanggal": "2026-10-06",
      "jumlah_kegiatan": 4,
      "selesai": 2,
      "pemasukan": 50000,
      "pengeluaran": 25000,
      "tabungan": 25000
    },
    {
      "tanggal": "2026-10-07",
      "jumlah_kegiatan": 0,
      "selesai": 0,
      "pemasukan": 0,
      "pengeluaran": 0,
      "tabungan": 0
    }
  ]
}
```

### 7.5 Lapisan Flutter dan unit test

`Ringkasan.fromJson`, `LaporanHarian`, `LaporanRentang`, `LaporanApi.harian()`, dan `LaporanApi.rentang()` tersedia di `lib/pertemuan9`. Unit test memakai `MockClient`:

```dart
test('harian membaca angka contoh skenario modul 7', () async {
  final client = MockClient((req) async {
    expect(req.url.path, '/laporan/harian');
    expect(req.url.queryParameters['tanggal'], '2026-10-06');
    return http.Response(jsonEncode(_harian), 200);
  });
  final api = LaporanApi(client: client, alamat: 'http://contoh.test:8000');
  final laporan = await api.harian('2026-10-06');

  expect(laporan.ringkasan.jumlahKegiatan, 4);
  expect(laporan.ringkasan.selesai, 2);
  expect(laporan.ringkasan.pemasukan, 50000);
  expect(laporan.ringkasan.pengeluaran, 25000);
  expect(laporan.ringkasan.tabungan, 25000);
  expect(laporan.perKategori.first.kategori, 'Makan');
  expect(laporan.perKategori.first.total, 15000);
});
```

Tes rentang memeriksa hari kosong bernilai `0` dan hari dengan tabungan negatif. Tes galat memastikan respons **400** rentang terbalik menjadi `ApiException`.

### 7.6 Tampilan laporan di Flutter

`pages/laporan_page.dart` menampilkan:
- Tanggal laporan dan tombol ganti tanggal.
- Tabungan besar; berwarna merah bila negatif.
- Jumlah selesai/total kegiatan, pemasukan, dan pengeluaran.
- Bar per kategori pengeluaran (dinormalisasi terhadap kategori terbesar).
- Grafik tujuh hari terakhir dari `/laporan/rentang`; batang merah untuk tabungan negatif.
- Keterangan bahwa angka berasal dari query SQL, bukan penjumlahan di Dart.

---

## 8. Tabel Pengujian dan Checkpoint

Pengujian backend dilakukan dengan `TestClient` FastAPI + database SQLite (agar tidak membutuhkan Docker), sedangkan produksi memakai MySQL. Seluruh skenario berikut lulus.

| No | Permintaan | Hasil yang diharapkan | Hasil |
| --- | --- | --- | --- |
| 1 | `POST` pengeluaran Rp 15.000 kategori Makan | 201; respons berisi `id`, `created_at` | Lulus |
| 2 | `POST` pemasukan dengan kategori `"Makan"` | 201; kategori otomatis `"-"` | Lulus |
| 3 | `POST` dengan judul `" "` | 422 `judul wajib diisi` | Lulus |
| 4 | `POST` pengeluaran kategori `"Jajan"` | 422 berisi daftar kategori sah | Lulus |
| 5 | `PATCH /kegiatan/1 {"selesai": true}` | 200; `selesai` berubah | Lulus |
| 6 | `PATCH /kegiatan/1 {"nominal": 0}` | 422; data tidak berubah | Lulus |
| 7 | `GET /kegiatan?tanggal=2026-10-06&limit=1` | Satu data; `X-Total-Count` berisi jumlah seluruhnya | Lulus |
| 8 | `DELETE /kegiatan/2`, lalu `GET /kegiatan/2` | 204, lalu 404 | Lulus |
| 9 | `GET /laporan/harian?tanggal=2026-10-06` | 4/2, 50.000, 25.000, 25.000; kategori Makan 15.000 & Transport 10.000 | Lulus |
| 10 | `GET /laporan/rentang?mulai=2026-10-05&sampai=2026-10-07` | 3 hari; hari kosong bernilai 0 | Lulus |
| 11 | Rentang terbalik / lebih dari 31 hari | 400 dengan pesan yang jelas | Lulus |
| 12 | `alembic upgrade head` + `alembic current` | `0001 (head)` | Lulus |
| 13 | `alembic check` | `No new upgrade operations detected.` | Lulus |
| 14 | `flutter analyze` | Tidak ada masalah | Lulus |
| 15 | `flutter test` | Seluruh tes lulus (19 tes) | Lulus |

> Catatan: setiap baris diuji pada database uji yang dapat di-reset. Untuk baris 9–10, data skenario dimasukkan ulang agar jumlah selesai tetap 2 dan tidak terpengaruh PATCH pada baris 5. Pada database MySQL, angka dan urutan kategori sama; yang berbeda hanya tipe kolom internal.

Checkpoint Docker (dijalankan pada mesin dengan Docker Compose V2):

```bash
docker compose ps
# mysql healthy, api Up

docker compose exec api alembic current
# 0001 (head)

docker compose exec api alembic check
# No new upgrade operations detected.
```

Buka Adminer (`http://localhost:8081`): tabel `kegiatan` dan `alembic_version` terlihat, dan isinya sama dengan hasil `GET /kegiatan`.

> Catatan verifikasi: pada mesin pengembangan ini hanya tersedia `docker-compose` V1 tanpa plugin Compose V2, sehingga stack tidak dijalankan. Konfigurasi Compose tetap divalidasi dengan `docker-compose config` (services `mysql`, `api`, `adminer` terbaca). Logika backend diverifikasi memakai `TestClient` + SQLite, termasuk kondisi database mati (`/health` → 503). Pengujian UI manual tidak dilakukan karena tidak ada emulator/HP; verifikasi Flutter memakai `flutter analyze` dan unit test.

---

## 9. Jawaban Pertanyaan Refleksi Modul

### 1. Mengapa POST membalas 201 dan DELETE membalas 204, bukan 200?
**201 Created** menyatakan bahwa permintaan berhasil dan sebuah resource baru telah dibuat; responsnya membawa representasi resource tersebut (termasuk `id` dan `created_at`). **204 No Content** menyatakan permintaan berhasil tetapi tidak ada badan respons yang perlu dikirim, tepat untuk DELETE karena resource sudah tidak ada. Kode **200 OK** menyiratkan ada representasi yang dikembalikan; memakainya untuk DELETE akan membingungkan klien dan membuat kontrak API kurang tepat.

### 2. Apa yang dapat terjadi bila skema database diubah langsung lewat Adminer, bukan lewat revisi Alembic?
Perubahan tersebut tidak tercatat di `alembic_version` dan tidak ada di folder `alembic/versions`. Akibatnya:
- Laptop/ server lain yang menjalankan `alembic upgrade head` tidak mendapat perubahan itu, sehingga skema berbeda.
- `alembic check` melaporkan selisih, dan `--autogenerate` berikutnya dapat membuat revisi yang salah.
- Tidak ada `downgrade()` untuk membatalkan perubahan.
- Perubahan manual seperti `DROP COLUMN` dapat menghilangkan data tanpa riwayat.

Semua perubahan skema harus melalui revisi Alembic yang di-commit bersama kode.

### 3. Mengapa PATCH memvalidasi ulang data gabungan? Beri contoh data rusak yang dicegahnya.
PATCH hanya mengirim sebagian field, sehingga validasi terhadap payload mentah tidak cukup: aturan bisnis bergantung pada kombinasi field lama dan baru. Contoh:
- Kegiatan pengeluaran Rp 15.000 yang sudah ada, lalu `PATCH {"nominal": 0}`. Payload sendirian hanya berisi `nominal`, tetapi setelah digabung menjadi pengeluaran dengan nominal 0 — melanggar aturan `nominal > 0`.
- `PATCH {"tipe": "pengeluaran"}` pada kegiatan yang kategorinya masih `"-"`; hasil gabungan tidak memiliki kategori pengeluaran yang sah.
- `PATCH {"judul": "   "}` harus tetap ditolak walaupun field lain tidak berubah.

Dengan menggabungkan data lama + payload, lalu memvalidasi memakai `KegiatanInput`, semua aturan tetap berlaku dan respons galatnya konsisten 422.

### 4. Mengapa pagination penting untuk aplikasi mobile? Apa fungsi header `X-Total-Count`?
Tanpa pagination, satu permintaan dapat menarik ribuan baris sekaligus. Di mobile itu berarti:
- Respons dan waktu tunggu lebih besar, kuota data boros.
- Memori dan waktu parsing meningkat, daftar menjadi lambat.
- UI harus merender terlalu banyak item.

Pagination membatasi jumlah data per permintaan (`limit`) dan memungkinkan mengambil halaman berikutnya (`offset`). Header **`X-Total-Count`** berisi jumlah seluruh baris yang cocok **sebelum** `limit/offset`, sehingga aplikasi dapat menampilkan "menampilkan 1–20 dari 137" dan mengetahui kapan harus berhenti memuat.

### 5. Apa keuntungan `KegiatanApi` menerima `http.Client` lewat konstruktor?
- **Dapat diuji tanpa server**: unit test menyuntikkan `MockClient`, memeriksa URL, method, header, dan body, lalu mengembalikan respons palsu.
- **Kontrol siklus hidup**: pemanggil dapat memakai satu client bersama atau menutupnya sendiri.
- **Fleksibel**: client dapat diberi timeout, proxy, atau konfigurasi khusus tanpa mengubah kode kelas.
- **Tidak tightly coupled**: kelas tidak wajib membuat koneksi nyata, sehingga test cepat dan deterministik.

Pola yang sama dipakai `HealthService` Pertemuan 8 dan `LaporanApi`.

---

## 10. Panduan Menjalankan Hingga Berhasil

1. Pastikan Docker dan Compose V2 tersedia:
   ```bash
   docker version
   docker compose version
   ```
2. Siapkan dan jalankan backend:
   ```bash
   cd tabungku-cloud
   cp .env.example .env
   docker compose up -d --build
   docker compose ps
   ```
3. Periksa migrasi dan API:
   ```bash
   docker compose exec api alembic current
   docker compose exec api alembic check
   ```
   Buka `http://localhost:8000/docs`, `http://localhost:8000/health`, dan `http://localhost:8081`.
4. Jalankan aplikasi demo dari root proyek Flutter:
   ```bash
   flutter pub get
   flutter run -t lib/pertemuan9/pertemuan9.dart
   ```
5. Untuk HP fisik (satu Wi-Fi dengan laptop):
   ```bash
   flutter run -t lib/pertemuan9/pertemuan9.dart \
     --dart-define=API_URL=http://192.168.1.10:8000
   ```
   Alamat juga dapat diubah dari tab **Pengaturan** dan tersimpan di `shared_preferences`.
6. Coba CRUD:
   - Tambah kegiatan lewat tombol **Kegiatan**.
   - Centang kegiatan → PATCH `selesai`.
   - Menu ⋮ → **Ubah** (PUT) atau **Hapus** (DELETE).
   - Buka tab **Laporan** untuk melihat agregasi.
7. Jalankan latihan dan tugas:
   ```bash
   flutter run -t lib/pertemuan9/latihan.dart
   flutter run -t lib/pertemuan9/tugas.dart
   ```
8. Pemeriksaan akhir:
   ```bash
   flutter analyze
   flutter test
   ```

### Troubleshooting

| Masalah | Solusi |
| --- | --- |
| `Can't locate revision identified by '...'` | Database berisi revisi yang berkasnya sudah dihapus. Saat pengembangan: `docker compose down -v` lalu jalankan ulang. |
| `Table 'kegiatan' already exists` | Tabel dibuat manual di luar Alembic. Hapus tabel atau tandai revisi dengan `alembic stamp 0001`. |
| `ModuleNotFoundError: No module named 'app'` saat Alembic | Jalankan dari `/code` (bawaan container) dan pastikan `prepend_sys_path = .` ada di `alembic.ini`. |
| 422 padahal data terlihat benar | Baca `detail[].loc`; format tanggal harus `YYYY-MM-DD`, kategori harus dari daftar sah. |
| `Object of type date is not JSON serializable` (500) | Jangan mengirim objek Pydantic mentah ke `HTTPException`; gunakan `RequestValidationError` seperti pada PATCH. |
| Perubahan model tidak terdeteksi `--autogenerate` | Pastikan `from app import models` ada di `alembic/env.py`. |
| Flutter `type 'Null' is not a subtype of type 'int'` | Nama field JSON salah eja atau field opsional tidak ada. Bandingkan dengan respons Swagger. |
| Flutter `Connection refused` di emulator | Gunakan `http://10.0.2.2:8000`, bukan `localhost`. |
| HP fisik tidak tersambung | Satu Wi-Fi, izinkan port 8000 di firewall, buka `/health` dari browser HP. |
| `Cleartext HTTP traffic not permitted` | `android:usesCleartextTraffic="true"` sudah diatur; hanya untuk pengembangan. |
| `port is already allocated` | Hentikan MySQL/XAMPP lokal atau ubah port kiri pada `docker-compose.yml`. |
| Laporan selalu 0 | Pastikan `tanggal` yang diminta sama dengan tanggal data (zona waktu server `Asia/Jakarta`). |
| `updated_at` tidak berubah | Resolusi `DATETIME`/`CURRENT_TIMESTAMP` bisa satu detik; ulangi setelah jeda atau gunakan `DATETIME(6)`. |

---

## 11. Referensi
1. Modul Praktikum Flutter Lanjutan - Pertemuan 9: REST API CRUD dengan FastAPI, SQLAlchemy, dan Alembic.
2. FastAPI, SQL (Relational) Databases: https://fastapi.tiangolo.com/tutorial/sql-databases
3. SQLAlchemy 2.0 ORM Quick Start: https://docs.sqlalchemy.org/en/20/orm/quickstart.html
4. Alembic Tutorial: https://alembic.sqlalchemy.org/en/latest/tutorial.html
5. Pydantic Validators: https://docs.pydantic.dev/latest/concepts/validators
6. Kode status HTTP: https://developer.mozilla.org/docs/Web/HTTP/Status
7. Dokumentasi backend dan Docker: [`tabungku-cloud/README.md`](../../../tabungku-cloud/README.md)
8. Dokumentasi Pertemuan 8: [`lib/pertemuan8/docs/README.md`](../../pertemuan8/docs/README.md)
