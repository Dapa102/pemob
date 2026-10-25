import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:praktikum/pertemuan8/config/api_config.dart';
import 'package:praktikum/pertemuan8/services/health_service.dart';

void main() {
  group('cekServer', () {
    test('kasus sehat: API dan database hidup', () async {
      final client = MockClient((req) async {
        expect(req.url.toString(), 'http://contoh.test:8000/health');
        return http.Response(
          jsonEncode({
            'status': 'ok',
            'waktu_server': '2026-10-26T08:00:00',
            'database': 'ok',
            'mysql_version': '8.4.0',
          }),
          200,
        );
      });

      final status = await cekServer(
        client: client,
        alamat: 'http://contoh.test:8000',
      );

      expect(status.kode, 200);
      expect(status.apiHidup, isTrue);
      expect(status.databaseHidup, isTrue);
      expect(status.mysqlVersion, '8.4.0');
      expect(status.waktuServer, '2026-10-26T08:00:00');
    });

    test('kasus 503: API hidup, database mati', () async {
      final client = MockClient((req) async {
        return http.Response(
          jsonEncode({
            'status': 'error',
            'waktu_server': '2026-10-26T08:00:00',
            'database': 'error',
            'mysql_version': null,
            'detail': "Can't connect to MySQL server on 'mysql'",
          }),
          503,
        );
      });

      final status = await cekServer(
        client: client,
        alamat: 'http://contoh.test:8000',
      );

      // 503 bukan exception: API tetap dianggap hidup.
      expect(status.kode, 503);
      expect(status.apiHidup, isTrue);
      expect(status.databaseHidup, isFalse);
      expect(status.pesan, contains('MySQL'));
    });

    test('kasus kode lain: dilempar sebagai HealthException', () async {
      final client = MockClient((req) async {
        return http.Response('galat', 500);
      });

      expect(
        () => cekServer(client: client, alamat: 'http://contoh.test:8000'),
        throwsA(isA<HealthException>().having((e) => e.kode, 'kode', 500)),
      );
    });

    test('validasi alamat API', () {
      expect(validasiUrl('http://10.0.2.2:8000'), isNull);
      expect(validasiUrl('https://api.contoh.id'), isNull);
      expect(validasiUrl(''), isNotNull);
      expect(validasiUrl('10.0.2.2:8000'), isNotNull);
      expect(validasiUrl('ftp://contoh.id'), isNotNull);
      expect(validasiUrl('http://'), isNotNull);
    });
  });
}
