import 'package:flutter/material.dart';

import '../pertemuan8/config/api_config.dart';
import 'pages/shell_page.dart';

// Pertemuan 9: REST API CRUD FastAPI + SQLAlchemy + Alembic.
//
// Bagian G modul membuat lapisan layanan API di Flutter:
// - models/kegiatan.dart      : toJson/fromJson, Ringkasan, LaporanHarian
// - services/api_exception.dart
// - services/kegiatan_api.dart: daftar, tambah, ubah, setSelesai, hapus
// - services/laporan_api.dart : harian, rentang (tugas)
//
// Aplikasi demo ini memakai layanan tersebut agar endpoint dapat dicoba
// langsung dari HP. Integrasi penuh ke UI TabungKu dilakukan pada Pertemuan 11.
//
// Jalankan backend:
//   cd tabungku-cloud && docker compose up -d --build
// Lalu:
//   flutter run -t lib/pertemuan9/pertemuan9.dart

Future<void> jalankanApiApp({
  String judul = 'TabungKu API',
  int tabAwal = 0,
  bool modeLatihan = false,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await muatApiUrl();
  runApp(ApiApp(judul: judul, tabAwal: tabAwal, modeLatihan: modeLatihan));
}

Future<void> main() => jalankanApiApp();

class ApiApp extends StatelessWidget {
  final String judul;
  final int tabAwal;
  final bool modeLatihan;

  const ApiApp({
    super.key,
    this.judul = 'TabungKu API',
    this.tabAwal = 0,
    this.modeLatihan = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: judul,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: ShellPage(tabAwal: tabAwal, modeLatihan: modeLatihan),
    );
  }
}
