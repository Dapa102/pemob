import 'dart:convert';

import 'package:http/http.dart' as http;

/// Galat API yang sudah diterjemahkan menjadi pesan siap tampil.
class ApiException implements Exception {
  final int? kode;
  final String pesan;

  const ApiException(this.pesan, {this.kode});

  /// Membaca field `detail` dari respons FastAPI:
  /// - HTTPException -> {"detail": "Kegiatan tidak ditemukan"}
  /// - validasi (422) -> {"detail": [{"loc": [...], "msg": "..."}]}
  factory ApiException.dariRespons(http.Response res) {
    var pesan = 'Server membalas kode ${res.statusCode}';
    try {
      final detail = (jsonDecode(res.body) as Map<String, dynamic>)['detail'];
      if (detail is String) {
        pesan = detail;
      } else if (detail is List) {
        pesan = detail
            .map((e) {
              final item = e as Map<String, dynamic>;
              final msg = (item['msg'] as String? ?? 'Data tidak valid')
                  .replaceFirst('Value error, ', '');
              final loc = item['loc'];
              if (loc is List && loc.isNotEmpty) {
                return '${loc.last}: $msg';
              }
              return msg;
            })
            .join('\n');
      }
    } catch (_) {
      // Badan respons bukan JSON (misalnya halaman galat 502 dari proxy).
    }
    return ApiException(pesan, kode: res.statusCode);
  }

  @override
  String toString() => pesan;
}
