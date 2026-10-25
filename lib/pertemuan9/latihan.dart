import 'pertemuan9.dart';

// Latihan Mandiri Pertemuan 9:
// 1. Filter selesai (boolean) pada GET /kegiatan -> chip Semua/Selesai/Belum.
// 2. Parameter urut terbaru/terlama -> dropdown Urutan.
// 3. Revisi Alembic 0001b menambah kolom catatan -> langkahnya ada di docs.
// 4. Mengirim tanggal "06-10-2026" -> tombol "Uji tanggal salah" menampilkan
//    pesan 422 dari FastAPI beserta penjelasan format YYYY-MM-DD.
//
// Aplikasi ini membuka tab Kegiatan dengan panel latihan aktif.

Future<void> main() => jalankanApiApp(
  judul: 'TabungKu API - Latihan',
  tabAwal: 0,
  modeLatihan: true,
);
