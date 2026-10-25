import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../pertemuan8/config/api_config.dart';
import '../models/kegiatan.dart';
import 'api_exception.dart';

/// Pembungkus endpoint laporan (tugas Pertemuan 9).
class LaporanApi {
  final http.Client _client;
  final String _alamat;

  LaporanApi({http.Client? client, String? alamat})
    : _client = client ?? http.Client(),
      _alamat = (alamat ?? apiUrl.value).replaceAll(RegExp(r'/$'), '');

  Uri _uri(String path, Map<String, String> query) {
    return Uri.parse('$_alamat$path').replace(queryParameters: query);
  }

  http.Response _cek(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException.dariRespons(res);
    }
    return res;
  }

  Future<LaporanHarian> harian(String tanggal) async {
    final res = _cek(
      await _client
          .get(_uri('/laporan/harian', {'tanggal': tanggal}))
          .timeout(batasWaktu),
    );
    return LaporanHarian.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<LaporanRentang> rentang(String mulai, String sampai) async {
    final res = _cek(
      await _client
          .get(_uri('/laporan/rentang', {'mulai': mulai, 'sampai': sampai}))
          .timeout(batasWaktu),
    );
    return LaporanRentang.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  void tutup() => _client.close();
}
