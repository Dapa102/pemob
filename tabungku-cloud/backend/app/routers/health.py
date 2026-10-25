from datetime import datetime
from time import tzname

from fastapi import APIRouter, Depends, Response
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from ..config import settings
from ..database import get_db

router = APIRouter(tags=["health"])


@router.get("/health")
def health(response: Response, db: Session = Depends(get_db)):
    """Dipakai Flutter untuk memastikan API dan database dapat dihubungi.

    Bila database mati, API tetap hidup dan membalas 503 dengan
    database="error". Kode 503 dibaca Flutter sebagai "API hidup,
    database mati", bukan galat jaringan.
    """
    waktu = datetime.now().isoformat(timespec="seconds")
    try:
        # SELECT VERSION() adalah cara MySQL. Fallback SQLite dipakai agar
        # logika health tetap dapat diuji tanpa MySQL.
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


@router.get("/info")
def info():
    """Latihan Mandiri Pertemuan 8: informasi aplikasi dan zona waktu server."""
    return {
        "nama_aplikasi": settings.nama_aplikasi,
        "versi": settings.versi,
        "zona_waktu": tzname[0],
        "waktu_server": datetime.now().isoformat(timespec="seconds"),
    }
