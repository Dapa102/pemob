from datetime import date, timedelta

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import text
from sqlalchemy.orm import Session

from ..database import get_db

router = APIRouter(prefix="/laporan", tags=["laporan"])

# Query agregasi satu hari. CASE WHEN memilah pemasukan/pengeluaran,
# COALESCE mengganti NULL (saat tidak ada baris) dengan 0.
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


def _angka(baris, kunci: str) -> int:
    return int(baris[kunci] or 0)


def _tanggal_iso(nilai) -> str:
    """MySQL mengembalikan date; SQLite (untuk pengujian) mengembalikan str."""
    if hasattr(nilai, "isoformat"):
        return nilai.isoformat()  # type: ignore[no-any-return]
    return str(nilai)


def _ringkasan(baris) -> dict:
    pemasukan = _angka(baris, "pemasukan")
    pengeluaran = _angka(baris, "pengeluaran")
    return {
        "jumlah_kegiatan": _angka(baris, "jumlah"),
        "selesai": _angka(baris, "selesai"),
        "pemasukan": pemasukan,
        "pengeluaran": pengeluaran,
        "tabungan": pemasukan - pengeluaran,
    }


@router.get("/harian")
def laporan_harian(
    tanggal: date = Query(..., examples=["2026-10-06"]),
    db: Session = Depends(get_db),
):
    baris = db.execute(_QUERY_HARIAN, {"tanggal": tanggal}).mappings().one()
    kategori = db.execute(
        _QUERY_KATEGORI, {"tanggal": tanggal}
    ).mappings().all()
    hasil = {"tanggal": tanggal.isoformat(), **_ringkasan(baris)}
    hasil["per_kategori"] = [
        {"kategori": r["kategori"], "total": int(r["total"] or 0)}
        for r in kategori
    ]
    return hasil


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
        _QUERY_RENTANG,
        {"mulai": mulai, "sampai": sampai},
    ).mappings().all()
    per_tanggal = {_tanggal_iso(r["tanggal"]): r for r in baris}

    hari = []
    for i in range(jumlah_hari):
        t = mulai + timedelta(days=i)
        kunci = t.isoformat()
        if kunci in per_tanggal:
            hari.append({"tanggal": kunci, **_ringkasan(per_tanggal[kunci])})
        else:
            hari.append(
                {
                    "tanggal": kunci,
                    "jumlah_kegiatan": 0,
                    "selesai": 0,
                    "pemasukan": 0,
                    "pengeluaran": 0,
                    "tabungan": 0,
                }
            )

    return {
        "mulai": mulai.isoformat(),
        "sampai": sampai.isoformat(),
        "jumlah_hari": jumlah_hari,
        "hari": hari,
    }
