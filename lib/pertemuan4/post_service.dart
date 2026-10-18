// Lapisan layanan (service): seluruh permintaan HTTP dan penguraian JSON
// dipisahkan dari kode tampilan (UI) pada berkas tugas.dart.

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'post.dart';

const String _baseUrl = 'https://jsonplaceholder.typicode.com';

// Mengambil daftar postingan dari endpoint /posts
Future<List<Postingan>> ambilPostingan() async {
  final uri = Uri.parse('$_baseUrl/posts');
  final response = await http.get(uri).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Gagal memuat postingan (kode ${response.statusCode})');
  }

  final List<dynamic> data = jsonDecode(response.body);
  return data
      .map((e) => Postingan.fromJson(e as Map<String, dynamic>))
      .toList();
}

// Mengambil komentar untuk satu postingan dari endpoint /posts/{id}/comments
Future<List<Komentar>> ambilKomentar(int postId) async {
  final uri = Uri.parse('$_baseUrl/posts/$postId/comments');
  final response = await http.get(uri).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Gagal memuat komentar (kode ${response.statusCode})');
  }

  final List<dynamic> data = jsonDecode(response.body);
  return data.map((e) => Komentar.fromJson(e as Map<String, dynamic>)).toList();
}
