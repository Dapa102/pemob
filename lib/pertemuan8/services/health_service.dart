import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Hasil pemeriksaan endpoint GET /health.
///
/// Kode 503 bukan galat jaringan: API hidup tetapi database mati. Karena itu
/// 503 tetap dikembalikan sebagai [StatusServer], bukan dilempar sebagai
/// exception.
class StatusServer {
  final int kode;
  final String status;
  final String? database;
  final String? mysqlVersion;
  final String waktuServer;
  final Duration latensi;
  final String? pesan;

  const StatusServer({
    required this.kode,
    required this.status,
    required this.database,
    required this.waktuServer,
    required this.latensi,
    this.mysqlVersion,
    this.pesan,
  });

  bool get apiHidup => kode == 200 || kode == 503;
  bool get databaseHidup => database == 'ok';
}

/// Galat ketika server membalas kode di luar 200/503 atau jaringan gagal.
class HealthException implements Exception {
  final int? kode;
  final String pesan;

  const HealthException(this.pesan, {this.kode});

  @override
  String toString() => pesan;
}

/// Memanggil GET /health dan mengukur lama responsnya.
Future<StatusServer> cekServer({http.Client? client, String? alamat}) async {
  final c = client ?? http.Client();
  final dasar = (alamat ?? apiUrl.value).replaceAll(RegExp(r'/$'), '');
  final jam = Stopwatch()..start();
  try {
    final res = await c.get(Uri.parse('$dasar/health')).timeout(batasWaktu);
    jam.stop();

    if (res.statusCode != 200 && res.statusCode != 503) {
      throw HealthException(
        'Server membalas kode ${res.statusCode}',
        kode: res.statusCode,
      );
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw HealthException(
        'Respons server bukan JSON yang sah',
        kode: res.statusCode,
      );
    }

    return StatusServer(
      kode: res.statusCode,
      status: (data['status'] as String?) ?? 'unknown',
      database: data['database'] as String?,
      mysqlVersion: data['mysql_version'] as String?,
      waktuServer: (data['waktu_server'] as String?) ?? '-',
      pesan: data['detail'] as String?,
      latensi: jam.elapsed,
    );
  } on HealthException {
    rethrow;
  } catch (e) {
    throw HealthException('Tidak dapat menghubungi server: $e');
  } finally {
    if (client == null) c.close();
  }
}
