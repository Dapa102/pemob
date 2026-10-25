import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum/pertemuan7/models/kegiatan.dart';
import 'package:praktikum/pertemuan7/utils/format.dart';

void main() {
  group('format TabungKu', () {
    test('formatRupiah memberi pemisah ribuan dan tanda minus', () {
      expect(formatRupiah(0), '0');
      expect(formatRupiah(15000), '15.000');
      expect(formatRupiah(1250000), '1.250.000');
      expect(formatRupiah(-25000), '-25.000');
    });

    test('tanggal ISO dan tampilan panjang', () {
      final t = DateTime(2026, 10, 6);
      expect(tanggalIso(t), '2026-10-06');
      expect(parseTanggalIso('2026-10-06'), t);
      expect(formatTanggalPanjang('2026-10-06'), '06 Oktober 2026');
      expect(namaHari('2026-10-06'), 'Selasa');
    });
  });

  group('model Kegiatan', () {
    test('toMap menyimpan selesai 0/1 dan fromMap membacanya', () {
      const k = Kegiatan(
        id: 1,
        judul: 'Makan siang',
        tanggal: '2026-10-06',
        selesai: true,
        tipe: Tipe.pengeluaran,
        nominal: 15000,
        kategori: 'Makan',
      );
      final map = k.toMap();
      expect(map['selesai'], 1);
      expect(map['tipe'], 'pengeluaran');

      final hasil = Kegiatan.fromMap(map);
      expect(hasil.id, 1);
      expect(hasil.selesai, isTrue);
      expect(hasil.tipe, Tipe.pengeluaran);
      expect(hasil.kategori, 'Makan');
    });

    test('tabungan = pemasukan - pengeluaran', () {
      const r = Ringkasan(
        jumlahKegiatan: 4,
        selesai: 2,
        pemasukan: 50000,
        pengeluaran: 25000,
      );
      expect(r.tabungan, 25000);
      expect(r.negatif, isFalse);
      const minus = Ringkasan(pemasukan: 10000, pengeluaran: 25000);
      expect(minus.tabungan, -15000);
      expect(minus.negatif, isTrue);
    });
  });
}
