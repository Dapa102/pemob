import 'pertemuan8.dart';

// Latihan Mandiri Pertemuan 8:
// 1. Endpoint GET /info dan halaman Info Server (tab Info).
// 2. Port API diubah menjadi 9000 (lihat docs/README.md bagian latihan).
// 3. Ketahanan volume MySQL saat down/up dan down -v (lihat docs).
// 4. Perbandingan ukuran image python:3.12-slim dan python:3.12 (docs).
//
// Aplikasi ini langsung membuka tab Info Server.

Future<void> main() =>
    jalankanAplikasi(judul: 'TabungKu Cloud - Latihan', tabAwal: 1);
