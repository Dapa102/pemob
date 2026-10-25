import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Informasi server dari endpoint GET /info (Latihan Mandiri Pertemuan 8).
class InfoServer {
  final String namaAplikasi;
  final String versi;
  final String zonaWaktu;
  final String waktuServer;
  final Duration latensi;

  const InfoServer({
    required this.namaAplikasi,
    required this.versi,
    required this.zonaWaktu,
    required this.waktuServer,
    required this.latensi,
  });
}

Future<InfoServer> ambilInfo({http.Client? client, String? alamat}) async {
  final c = client ?? http.Client();
  final dasar = (alamat ?? apiUrl.value).replaceAll(RegExp(r'/$'), '');
  final jam = Stopwatch()..start();
  try {
    final res = await c.get(Uri.parse('$dasar/info')).timeout(batasWaktu);
    jam.stop();
    if (res.statusCode != 200) {
      throw Exception('Server membalas kode ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return InfoServer(
      namaAplikasi: (data['nama_aplikasi'] as String?) ?? '-',
      versi: (data['versi'] as String?) ?? '-',
      zonaWaktu: (data['zona_waktu'] as String?) ?? '-',
      waktuServer: (data['waktu_server'] as String?) ?? '-',
      latensi: jam.elapsed,
    );
  } finally {
    if (client == null) c.close();
  }
}
