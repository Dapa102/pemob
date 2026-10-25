# Konfigurasi backend TabungKu.
# Nilai dibaca dari environment variable; docker-compose mengisi DATABASE_URL.
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Konfigurasi aplikasi dari environment variable."""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = (
        "mysql+pymysql://tabungku:rahasia_tabungku@localhost:3307/tabungku"
    )
    nama_aplikasi: str = "TabungKu API"
    versi: str = "0.2.0"
    zona_waktu: str = "Asia/Jakarta"


settings = Settings()
