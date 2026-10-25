FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /code

# Salin requirements lebih dulu agar layer pip install di-cache selama
# requirements.txt tidak berubah.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

# start.sh menjalankan migrasi Alembic lalu uvicorn.
CMD ["sh", "start.sh"]
