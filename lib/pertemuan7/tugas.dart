import 'package:flutter/material.dart';

import 'pertemuan7.dart';

// Tugas Pertemuan 7 - Variasi tema: "Bekal Harian" (uang jajan mahasiswa).
//
// Fitur wajib F1-F8 tetap sama, ditambah dua fitur pengembangan lanjutan:
// pencarian/filter SQL dan ekspor laporan ke papan klip. Tema awal hijau,
// pengaturan disimpan dengan awalan "tugas_" agar terpisah dari praktikum.

Future<void> main() => jalankanTabungKu(
  judul: 'Bekal Harian',
  warnaAwal: Colors.green,
  prefiks: 'tugas_',
  targetAwal: 15000,
  fiturLanjutan: true,
);
