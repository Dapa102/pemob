import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Konfigurasi alamat API TabungKu Cloud.
//
// Bawaan 10.0.2.2 adalah alamat khusus emulator Android untuk menuju
// localhost laptop. Alamat dapat diganti lewat --dart-define atau halaman
// Pengaturan (disimpan dengan shared_preferences).

const apiUrlBawaan = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

/// Batas waktu setiap permintaan ke server.
const batasWaktu = Duration(seconds: 10);

/// Alamat API yang sedang dipakai aplikasi.
final apiUrl = ValueNotifier<String>(apiUrlBawaan);

const _kunciApiUrl = 'api_url';

/// Memuat alamat tersimpan saat aplikasi dimulai.
Future<void> muatApiUrl() async {
  final prefs = await SharedPreferences.getInstance();
  apiUrl.value = prefs.getString(_kunciApiUrl) ?? apiUrlBawaan;
}

/// Menyimpan alamat API setelah divalidasi.
Future<void> simpanApiUrl(String alamat) async {
  final bersih = alamat.trim();
  apiUrl.value = bersih;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kunciApiUrl, bersih);
}

/// Mengembalikan pesan galat, atau null bila format URL sah.
String? validasiUrl(String? teks) {
  final nilai = (teks ?? '').trim();
  if (nilai.isEmpty) return 'Alamat API wajib diisi';
  final uri = Uri.tryParse(nilai);
  if (uri == null) return 'Format URL tidak sah';
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return 'Gunakan http:// atau https://';
  }
  if (uri.host.isEmpty) return 'Host tidak boleh kosong';
  if (nilai.contains(' ')) return 'URL tidak boleh mengandung spasi';
  return null;
}
