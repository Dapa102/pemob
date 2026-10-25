import 'package:flutter/material.dart';

import 'models/kegiatan.dart';
import 'pages/form_kegiatan_page.dart';
import 'pages/shell_page.dart';
import 'state/pengaturan.dart';

// Mini Proyek Pertemuan 7: TabungKu
// To-do list + manajemen keuangan + laporan harian.
//
// Jalankan dengan:
//   flutter run -t lib/pertemuan7/pertemuan7.dart

/// Menjalankan aplikasi. Parameter dipakai oleh variasi latihan/tugas.
Future<void> jalankanTabungKu({
  String judul = 'TabungKu',
  Color warnaAwal = Colors.indigo,
  String prefiks = '',
  int targetAwal = 20000,
  bool fiturLanjutan = false,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await muatPengaturan(
    prefiks: prefiks,
    warnaAwal: warnaAwal,
    targetAwal: targetAwal,
  );
  runApp(TabungKuApp(judul: judul, fiturLanjutan: fiturLanjutan));
}

Future<void> main() => jalankanTabungKu();

class TabungKuApp extends StatelessWidget {
  final String judul;
  final bool fiturLanjutan;

  const TabungKuApp({
    super.key,
    this.judul = 'TabungKu',
    this.fiturLanjutan = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([temaMode, warnaSeed]),
      builder: (context, _) {
        return MaterialApp(
          title: judul,
          debugShowCheckedModeBanner: false,
          theme: buatTema(warnaSeed.value, Brightness.light),
          darkTheme: buatTema(warnaSeed.value, Brightness.dark),
          themeMode: temaMode.value,
          initialRoute: '/',
          routes: {
            '/': (_) => ShellPage(judul: judul, fiturLanjutan: fiturLanjutan),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/form') {
              final kegiatan = settings.arguments as Kegiatan?;
              return MaterialPageRoute(
                builder: (_) => FormKegiatanPage(kegiatan: kegiatan),
                settings: settings,
              );
            }
            return null;
          },
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('404')),
              body: Center(
                child: Text('Rute "${settings.name}" tidak ditemukan.'),
              ),
            ),
          ),
        );
      },
    );
  }
}
