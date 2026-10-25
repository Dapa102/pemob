import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../pertemuan8/config/api_config.dart';
import '../models/kegiatan.dart';
import 'api_exception.dart';

/// Lapisan layanan API kegiatan. UI tidak memanggil http secara langsung.
class KegiatanApi {
  final http.Client _client;
  final String _alamat;

  KegiatanApi({http.Client? client, String? alamat})
    : _client = client ?? http.Client(),
      _alamat = (alamat ?? apiUrl.value).replaceAll(RegExp(r'/$'), '');

  static const _json = {'Content-Type': 'application/json'};

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$_alamat$path');
    return query == null || query.isEmpty
        ? uri
        : uri.replace(queryParameters: query);
  }

  http.Response _cek(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException.dariRespons(res);
    }
    return res;
  }

  Future<List<Kegiatan>> daftar({
    String? tanggal,
    Tipe? tipe,
    bool? selesai,
    String? q,
    String urut = 'terbaru',
    int? limit,
    int? offset,
  }) async {
    final query = <String, String>{
      'tanggal': ?tanggal,
      if (tipe != null) 'tipe': tipe.name,
      if (selesai != null) 'selesai': selesai.toString(),
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      'urut': urut,
      if (limit != null) 'limit': limit.toString(),
      if (offset != null) 'offset': offset.toString(),
    };
    final res = _cek(
      await _client.get(_uri('/kegiatan', query)).timeout(batasWaktu),
    );
    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => Kegiatan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Kegiatan> detail(int id) async {
    final res = _cek(
      await _client.get(_uri('/kegiatan/$id')).timeout(batasWaktu),
    );
    return Kegiatan.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Kegiatan> tambah(Kegiatan k) async {
    final res = _cek(
      await _client
          .post(_uri('/kegiatan'), headers: _json, body: jsonEncode(k.toJson()))
          .timeout(batasWaktu),
    );
    return Kegiatan.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Kegiatan> ubah(int id, Kegiatan k) async {
    final res = _cek(
      await _client
          .put(
            _uri('/kegiatan/$id'),
            headers: _json,
            body: jsonEncode(k.toJson()),
          )
          .timeout(batasWaktu),
    );
    return Kegiatan.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// PATCH hanya mengirim field selesai.
  Future<Kegiatan> setSelesai(int id, bool selesai) async {
    final res = _cek(
      await _client
          .patch(
            _uri('/kegiatan/$id'),
            headers: _json,
            body: jsonEncode({'selesai': selesai}),
          )
          .timeout(batasWaktu),
    );
    return Kegiatan.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> hapus(int id) async {
    _cek(await _client.delete(_uri('/kegiatan/$id')).timeout(batasWaktu));
  }

  void tutup() => _client.close();
}
