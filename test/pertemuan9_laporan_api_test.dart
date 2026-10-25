import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:praktikum/pertemuan9/services/api_exception.dart';
import 'package:praktikum/pertemuan9/services/laporan_api.dart';

const _harian = {
  'tanggal': '2026-10-06',
  'jumlah_kegiatan': 4,
  'selesai': 2,
  'pemasukan': 50000,
  'pengeluaran': 25000,
  'tabungan': 25000,
  'per_kategori': [
    {'kategori': 'Makan', 'total': 15000},
    {'kategori': 'Transport', 'total': 10000},
  ],
};

void main() {
  group('LaporanApi', () {
    test('harian membaca angka contoh skenario modul 7', () async {
      final client = MockClient((req) async {
        expect(req.url.path, '/laporan/harian');
        expect(req.url.queryParameters['tanggal'], '2026-10-06');
        return http.Response(jsonEncode(_harian), 200);
      });
      final api = LaporanApi(client: client, alamat: 'http://contoh.test:8000');
      final laporan = await api.harian('2026-10-06');

      expect(laporan.ringkasan.jumlahKegiatan, 4);
      expect(laporan.ringkasan.selesai, 2);
      expect(laporan.ringkasan.pemasukan, 50000);
      expect(laporan.ringkasan.pengeluaran, 25000);
      expect(laporan.ringkasan.tabungan, 25000);
      expect(laporan.perKategori, hasLength(2));
      expect(laporan.perKategori.first.kategori, 'Makan');
      expect(laporan.perKategori.first.total, 15000);
    });

    test('rentang membaca hari kosong bernilai 0', () async {
      final client = MockClient((req) async {
        expect(req.url.path, '/laporan/rentang');
        expect(req.url.queryParameters['mulai'], '2026-10-05');
        expect(req.url.queryParameters['sampai'], '2026-10-07');
        return http.Response(
          jsonEncode({
            'mulai': '2026-10-05',
            'sampai': '2026-10-07',
            'jumlah_hari': 3,
            'hari': [
              {
                'tanggal': '2026-10-05',
                'jumlah_kegiatan': 0,
                'selesai': 0,
                'pemasukan': 0,
                'pengeluaran': 0,
                'tabungan': 0,
              },
              {
                'tanggal': '2026-10-06',
                'jumlah_kegiatan': 4,
                'selesai': 2,
                'pemasukan': 50000,
                'pengeluaran': 25000,
                'tabungan': 25000,
              },
              {
                'tanggal': '2026-10-07',
                'jumlah_kegiatan': 1,
                'selesai': 1,
                'pemasukan': 0,
                'pengeluaran': 10000,
                'tabungan': -10000,
              },
            ],
          }),
          200,
        );
      });
      final api = LaporanApi(client: client, alamat: 'http://contoh.test:8000');
      final laporan = await api.rentang('2026-10-05', '2026-10-07');

      expect(laporan.jumlahHari, 3);
      expect(laporan.hari, hasLength(3));
      expect(laporan.hari.first.ringkasan.jumlahKegiatan, 0);
      expect(laporan.hari.last.ringkasan.tabungan, -10000);
    });

    test('rentang terbalik 400 menjadi ApiException', () async {
      final client = MockClient((req) async {
        return http.Response(
          jsonEncode({'detail': 'rentang terbalik: sampai harus >= mulai'}),
          400,
        );
      });
      final api = LaporanApi(client: client, alamat: 'http://contoh.test:8000');
      expect(
        () => api.rentang('2026-10-07', '2026-10-01'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.kode, 'kode', 400)
              .having((e) => e.pesan, 'pesan', contains('terbalik')),
        ),
      );
    });
  });
}
