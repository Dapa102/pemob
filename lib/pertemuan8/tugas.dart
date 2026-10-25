import 'pertemuan8.dart';

// Tugas Pertemuan 8:
// - Adminer di port 8081 (docker-compose.yml).
// - GET /health memeriksa database dan membalas 503 saat database mati.
// - Halaman Status Server memisahkan status API dan Database.
// - Alamat API dapat diubah dari Pengaturan dan tersimpan.
// - Unit test MockClient tiga kasus: sehat, 503, kode lain.
//
// Variasi tugas ini memakai judul "TabungKu Cloud - Tugas" dan membuka
// halaman Status Server.

Future<void> main() =>
    jalankanAplikasi(judul: 'TabungKu Cloud - Tugas', tabAwal: 0);
