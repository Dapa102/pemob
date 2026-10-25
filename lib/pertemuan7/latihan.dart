import 'package:flutter/material.dart';

import 'pertemuan7.dart';

// Latihan Mandiri Pertemuan 7 - Pengembangan Lanjutan (minimal 2):
// 1. Pencarian dan filter kegiatan berdasarkan nama, jenis, dan kategori
//    (query LIKE/WHERE di SQLite).
// 2. Laporan bulanan dengan grafik batang sederhana.
// 3. Ekspor laporan harian ke papan klip (Clipboard).
//
// Seluruh fitur dijalankan dengan engine yang sama dengan pertemuan7.dart,
// tetapi memakai awalan prefs "latihan_" agar pengaturan tidak bertabrakan.

Future<void> main() => jalankanTabungKu(
  judul: 'TabungKu Latihan',
  warnaAwal: Colors.teal,
  prefiks: 'latihan_',
  fiturLanjutan: true,
);
