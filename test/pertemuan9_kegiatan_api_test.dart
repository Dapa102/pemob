import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:praktikum/pertemuan9/models/kegiatan.dart';
import 'package:praktikum/pertemuan9/services/api_exception.dart';
import 'package:praktikum/pertemuan9/services/kegiatan_api.dart';

const contohJson = {
  'id': 1,
  'judul': 'Makan siang',
  'tanggal': '2026-10-06',
  'selesai': false,
  'tipe': 'pengeluaran',
  'nominal': 15000,
  'kategori': 'Makan',
  'created_at': '2026-10-06T10:00:00',
  'updated_at': '2026-10-06T10:00:00',
};

void main() {
  group('model Kegiatan', () {
    test('fromJson membaca field dan toJson tidak mengirim id', () {
      final k = Kegiatan.fromJson(Map<String, dynamic>.from(contohJson));
      expect(k.id, 1);
      expect(k.tipe, Tipe.pengeluaran);
      expect(k.selesai, isFalse);
      expect(k.toJson().containsKey('id'), isFalse);
      expect(k.toJson()['selesai'], isFalse);
      expect(k.toJson()['tanggal'], '2026-10-06');
    });
  });

  group('KegiatanApi', () {
    test('daftar mengirim filter tanggal, tipe, selesai, dan urut', () async {
      final client = MockClient((req) async {
        expect(req.method, 'GET');
        expect(req.url.path, '/kegiatan');
        expect(req.url.queryParameters['tanggal'], '2026-10-06');
        expect(req.url.queryParameters['tipe'], 'pengeluaran');
        expect(req.url.queryParameters['selesai'], 'true');
        expect(req.url.queryParameters['urut'], 'terlama');
        return http.Response(jsonEncode([contohJson]), 200);
      });
      final api = KegiatanApi(
        client: client,
        alamat: 'http://contoh.test:8000',
      );
      final data = await api.daftar(
        tanggal: '2026-10-06',
        tipe: Tipe.pengeluaran,
        selesai: true,
        urut: 'terlama',
      );
      expect(data, hasLength(1));
      expect(data.first.judul, 'Makan siang');
    });

    test('POST mengirim JSON tanpa id dan membaca 201', () async {
      final client = MockClient((req) async {
        expect(req.method, 'POST');
        expect(req.headers['content-type'], contains('application/json'));
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body.containsKey('id'), isFalse);
        expect(body['judul'], 'Kerja freelance');
        expect(body['tipe'], 'pemasukan');
        expect(body['nominal'], 50000);
        return http.Response(
          jsonEncode({
            ...contohJson,
            'id': 2,
            'judul': 'Kerja freelance',
            'tipe': 'pemasukan',
            'nominal': 50000,
            'kategori': '-',
          }),
          201,
        );
      });
      final api = KegiatanApi(
        client: client,
        alamat: 'http://contoh.test:8000',
      );
      final hasil = await api.tambah(
        const Kegiatan(
          judul: 'Kerja freelance',
          tanggal: '2026-10-06',
          tipe: Tipe.pemasukan,
          nominal: 50000,
        ),
      );
      expect(hasil.id, 2);
      expect(hasil.nominal, 50000);
    });

    test('PATCH hanya mengirim field selesai', () async {
      final client = MockClient((req) async {
        expect(req.method, 'PATCH');
        expect(req.url.path, '/kegiatan/1');
        expect(jsonDecode(req.body), {'selesai': true});
        return http.Response(jsonEncode({...contohJson, 'selesai': true}), 200);
      });
      final api = KegiatanApi(
        client: client,
        alamat: 'http://contoh.test:8000',
      );
      final hasil = await api.setSelesai(1, true);
      expect(hasil.selesai, isTrue);
    });

    test('DELETE 204 tidak melempar galat', () async {
      final client = MockClient((req) async {
        expect(req.method, 'DELETE');
        return http.Response('', 204);
      });
      final api = KegiatanApi(
        client: client,
        alamat: 'http://contoh.test:8000',
      );
      await api.hapus(1);
    });

    test('detail 404 menjadi ApiException', () async {
      final client = MockClient((req) async {
        return http.Response(
          jsonEncode({'detail': 'Kegiatan tidak ditemukan'}),
          404,
        );
      });
      final api = KegiatanApi(
        client: client,
        alamat: 'http://contoh.test:8000',
      );
      expect(
        () => api.detail(99),
        throwsA(
          isA<ApiException>()
              .having((e) => e.kode, 'kode', 404)
              .having((e) => e.pesan, 'pesan', contains('tidak ditemukan')),
        ),
      );
    });

    test('pesan validasi 422 dibaca dari detail[].msg', () {
      final res = http.Response(
        jsonEncode({
          'detail': [
            {
              'loc': ['body', 'nominal'],
              'msg': 'Value error, nominal wajib lebih dari 0',
            },
          ],
        }),
        422,
      );
      final e = ApiException.dariRespons(res);
      expect(e.kode, 422);
      expect(e.pesan, contains('nominal'));
      expect(e.pesan, isNot(contains('Value error,')));
    });
  });
}
