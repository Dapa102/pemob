import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/kegiatan.dart';
import '../utils/format.dart';

// Lapisan akses data SQLite TabungKu.
//
// versiData adalah ValueNotifier global yang dinaikkan setiap kali data berubah.
// Halaman yang menampilkan data mendengarkan notifier ini lalu memuat ulang
// Future-nya, sehingga tiga tab selalu sinkron tanpa restart.

final versiData = ValueNotifier<int>(0);

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'tabungku.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kegiatan(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            tanggal TEXT NOT NULL,
            selesai INTEGER NOT NULL DEFAULT 0,
            tipe TEXT NOT NULL DEFAULT 'tanpa',
            nominal INTEGER NOT NULL DEFAULT 0,
            kategori TEXT NOT NULL DEFAULT '-'
          )
        ''');
        await db.execute(
          'CREATE INDEX ix_kegiatan_tanggal ON kegiatan(tanggal)',
        );
      },
    );
    return _db!;
  }

  static void _beriTahuPerubahan() {
    versiData.value++;
  }

  // ---------- CRUD ----------
  static Future<int> tambah(Kegiatan k) async {
    final db = await database;
    final id = await db.insert('kegiatan', k.toMap()..remove('id'));
    _beriTahuPerubahan();
    return id;
  }

  static Future<int> ubah(Kegiatan k) async {
    final db = await database;
    final hasil = await db.update(
      'kegiatan',
      k.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [k.id],
    );
    _beriTahuPerubahan();
    return hasil;
  }

  static Future<int> hapus(int id) async {
    final db = await database;
    final hasil = await db.delete('kegiatan', where: 'id = ?', whereArgs: [id]);
    _beriTahuPerubahan();
    return hasil;
  }

  static Future<void> ubahSelesai(Kegiatan k, bool selesai) async {
    final db = await database;
    await db.update(
      'kegiatan',
      {'selesai': selesai ? 1 : 0},
      where: 'id = ?',
      whereArgs: [k.id],
    );
    _beriTahuPerubahan();
  }

  // ---------- QUERY BACA ----------
  static Future<List<Kegiatan>> pada(String tanggal) async {
    final db = await database;
    final rows = await db.query(
      'kegiatan',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
      orderBy: 'selesai ASC, id DESC',
    );
    return rows.map(Kegiatan.fromMap).toList();
  }

  /// Satu query agregasi menghasilkan seluruh angka ringkasan.
  /// COALESCE mencegah galat "Null is not a subtype of int" ketika kosong.
  static Future<Ringkasan> ringkasan(String tanggal) async {
    final db = await database;
    final hasil = await db.rawQuery(
      '''
      SELECT COUNT(*) AS jumlah,
             COALESCE(SUM(selesai), 0) AS selesai,
             COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0) AS masuk,
             COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0) AS keluar
      FROM kegiatan
      WHERE tanggal = ?
      ''',
      [tanggal],
    );
    final baris = hasil.first;
    return Ringkasan(
      jumlahKegiatan: (baris['jumlah'] as num).toInt(),
      selesai: (baris['selesai'] as num).toInt(),
      pemasukan: (baris['masuk'] as num).toInt(),
      pengeluaran: (baris['keluar'] as num).toInt(),
    );
  }

  /// Pengeluaran per kategori diurutkan dari terbesar.
  static Future<List<MapEntry<String, int>>> pengeluaranPerKategori(
    String tanggal,
  ) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT kategori, SUM(nominal) AS total
      FROM kegiatan
      WHERE tanggal = ? AND tipe = 'pengeluaran'
      GROUP BY kategori
      ORDER BY total DESC
      ''',
      [tanggal],
    );
    return rows
        .map(
          (r) => MapEntry(r['kategori'] as String, (r['total'] as num).toInt()),
        )
        .toList();
  }

  static Future<DataHari> dataHari(String tanggal) async {
    final hasil = await Future.wait([ringkasan(tanggal), pada(tanggal)]);
    return DataHari(
      ringkasan: hasil[0] as Ringkasan,
      kegiatan: hasil[1] as List<Kegiatan>,
    );
  }

  static Future<LaporanHarian> laporanHarian(String tanggal) async {
    final hasil = await Future.wait([
      ringkasan(tanggal),
      pengeluaranPerKategori(tanggal),
    ]);
    return LaporanHarian(
      tanggal: tanggal,
      ringkasan: hasil[0] as Ringkasan,
      perKategori: hasil[1] as List<MapEntry<String, int>>,
    );
  }

  /// Tujuh hari terakhir (termasuk [akhir]), hari kosong tetap ditampilkan 0.
  static Future<List<HariLaporan>> tujuhHariTerakhir(String akhir) async {
    final db = await database;
    final akhirDate = parseTanggalIso(akhir);
    final mulaiDate = akhirDate.subtract(const Duration(days: 6));
    final mulai = tanggalIso(mulaiDate);

    final rows = await db.rawQuery(
      '''
      SELECT tanggal,
             COUNT(*) AS jumlah,
             COALESCE(SUM(selesai), 0) AS selesai,
             COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0) AS masuk,
             COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0) AS keluar
      FROM kegiatan
      WHERE tanggal BETWEEN ? AND ?
      GROUP BY tanggal
      ''',
      [mulai, akhir],
    );

    final perTanggal = <String, Ringkasan>{
      for (final r in rows)
        r['tanggal'] as String: Ringkasan(
          jumlahKegiatan: (r['jumlah'] as num).toInt(),
          selesai: (r['selesai'] as num).toInt(),
          pemasukan: (r['masuk'] as num).toInt(),
          pengeluaran: (r['keluar'] as num).toInt(),
        ),
    };

    return [
      for (var i = 0; i < 7; i++)
        () {
          final t = tanggalIso(mulaiDate.add(Duration(days: i)));
          return HariLaporan(t, perTanggal[t] ?? const Ringkasan());
        }(),
    ];
  }

  // ---------- FITUR LANJUTAN (latihan) ----------
  /// Pencarian judul + filter jenis. Parameter null berarti tanpa filter.
  static Future<List<Kegiatan>> cari({
    String? kata,
    Tipe? tipe,
    String? kategori,
    String? tanggal,
  }) async {
    final db = await database;
    final syarat = <String>[];
    final args = <Object?>[];
    if (tanggal != null) {
      syarat.add('tanggal = ?');
      args.add(tanggal);
    }
    if (kata != null && kata.trim().isNotEmpty) {
      syarat.add('judul LIKE ?');
      args.add('%${kata.trim()}%');
    }
    if (tipe != null) {
      syarat.add('tipe = ?');
      args.add(tipe.nilai);
    }
    if (kategori != null) {
      syarat.add('kategori = ?');
      args.add(kategori);
    }
    final rows = await db.query(
      'kegiatan',
      where: syarat.isEmpty ? null : syarat.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'tanggal DESC, selesai ASC, id DESC',
    );
    return rows.map(Kegiatan.fromMap).toList();
  }

  /// Ringkasan satu bulan, dikelompokkan per tanggal (fitur laporan bulanan).
  static Future<List<HariLaporan>> laporanBulan(int tahun, int bulan) async {
    final db = await database;
    final awal = DateTime(tahun, bulan, 1);
    final akhir = DateTime(tahun, bulan + 1, 0);
    final awalIso = tanggalIso(awal);
    final akhirIso = tanggalIso(akhir);

    final rows = await db.rawQuery(
      '''
      SELECT tanggal,
             COUNT(*) AS jumlah,
             COALESCE(SUM(selesai), 0) AS selesai,
             COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0) AS masuk,
             COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0) AS keluar
      FROM kegiatan
      WHERE tanggal BETWEEN ? AND ?
      GROUP BY tanggal
      ORDER BY tanggal
      ''',
      [awalIso, akhirIso],
    );

    final perTanggal = <String, Ringkasan>{
      for (final r in rows)
        r['tanggal'] as String: Ringkasan(
          jumlahKegiatan: (r['jumlah'] as num).toInt(),
          selesai: (r['selesai'] as num).toInt(),
          pemasukan: (r['masuk'] as num).toInt(),
          pengeluaran: (r['keluar'] as num).toInt(),
        ),
    };

    return [
      for (var d = 1; d <= akhir.day; d++)
        () {
          final t = tanggalIso(DateTime(tahun, bulan, d));
          return HariLaporan(t, perTanggal[t] ?? const Ringkasan());
        }(),
    ];
  }

  /// Menyusun laporan teks siap disalin ke papan klip.
  static Future<String> eksporLaporan(String tanggal) async {
    final laporan = await laporanHarian(tanggal);
    final r = laporan.ringkasan;
    final b = StringBuffer()
      ..writeln('TabungKu - Laporan ${formatTanggalPanjang(tanggal)}')
      ..writeln('Jumlah kegiatan: ${r.selesai}/${r.jumlahKegiatan} selesai')
      ..writeln('Pemasukan: Rp ${formatRupiah(r.pemasukan)}')
      ..writeln('Pengeluaran: Rp ${formatRupiah(r.pengeluaran)}')
      ..writeln('Tabungan: Rp ${formatRupiah(r.tabungan)}');
    if (laporan.perKategori.isNotEmpty) {
      b.writeln('Pengeluaran per kategori:');
      for (final e in laporan.perKategori) {
        b.writeln('- ${e.key}: Rp ${formatRupiah(e.value)}');
      }
    }
    return b.toString();
  }

  /// Menghapus seluruh data (dipakai tombol reset pada Pengaturan).
  static Future<void> hapusSemua() async {
    final db = await database;
    await db.delete('kegiatan');
    _beriTahuPerubahan();
  }
}
