import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'pages/shell_page.dart';
import 'pages/status_server_page.dart';

// Pertemuan 8: Docker Compose + kerangka backend TabungKu Cloud.
//
// Bagian F praktikum: halaman Status Server memanggil GET /health.
// Tugas: status API dan database terpisah, alamat API dapat diubah dan
// tersimpan, serta unit test MockClient (lihat test/pertemuan8_*).
//
// Jalankan backend lebih dulu:
//   cd tabungku-cloud && cp .env.example .env && docker compose up -d --build
//
// Lalu Flutter:
//   flutter run -t lib/pertemuan8/pertemuan8.dart

Future<void> jalankanAplikasi({
  String judul = 'TabungKu Cloud',
  int tabAwal = 0,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await muatApiUrl();
  runApp(AplikasiCloud(judul: judul, tabAwal: tabAwal));
}

Future<void> main() => jalankanAplikasi();

class AplikasiCloud extends StatelessWidget {
  final String judul;
  final int tabAwal;

  const AplikasiCloud({
    super.key,
    this.judul = 'TabungKu Cloud',
    this.tabAwal = 0,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: judul,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => ShellPage(tabAwal: tabAwal),
        '/status': (_) => const StatusServerPage(),
      },
    );
  }
}
