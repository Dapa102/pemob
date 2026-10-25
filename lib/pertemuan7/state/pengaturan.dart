import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State global pengaturan TabungKu.
// Nilai disimpan dengan shared_preferences agar bertahan setelah aplikasi ditutup.

final temaMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final warnaSeed = ValueNotifier<Color>(Colors.indigo);
final targetTabungan = ValueNotifier<int>(20000);

const pilihanWarna = [
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.green,
];

/// Awalan kunci prefs dipakai agar variasi latihan/tugas tidak saling menimpa.
String prefiksPengaturan = '';

String _kunci(String nama) => '$prefiksPengaturan$nama';

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    cardTheme: const CardThemeData(margin: EdgeInsets.symmetric(vertical: 6)),
  );
}

/// Memuat seluruh pengaturan dari penyimpanan lokal.
Future<void> muatPengaturan({
  required String prefiks,
  Color warnaAwal = Colors.indigo,
  int targetAwal = 20000,
}) async {
  prefiksPengaturan = prefiks;
  final prefs = await SharedPreferences.getInstance();
  temaMode.value = (prefs.getBool(_kunci('gelap')) ?? false)
      ? ThemeMode.dark
      : ThemeMode.light;
  warnaSeed.value = Color(prefs.getInt(_kunci('seed')) ?? warnaAwal.toARGB32());
  targetTabungan.value = prefs.getInt(_kunci('target')) ?? targetAwal;
}

Future<void> simpanGelap(bool gelap) async {
  temaMode.value = gelap ? ThemeMode.dark : ThemeMode.light;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kunci('gelap'), gelap);
}

Future<void> simpanWarna(Color warna) async {
  warnaSeed.value = warna;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_kunci('seed'), warna.toARGB32());
}

Future<void> simpanTarget(int target) async {
  targetTabungan.value = target;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_kunci('target'), target);
}
