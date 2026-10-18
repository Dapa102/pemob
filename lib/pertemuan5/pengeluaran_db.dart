import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// Model dan lapisan akses data untuk tugas Pertemuan 5
// (Aplikasi Pencatat Pengeluaran). Dipisahkan dari kode UI pada tugas.dart.

// ---------- MODEL ----------
class Pengeluaran {
  final int? id;
  final String nama;
  final int jumlah;
  final String kategori;
  final String tanggal;

  const Pengeluaran({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'nama': nama,
    'jumlah': jumlah,
    'kategori': kategori,
    'tanggal': tanggal,
  };

  factory Pengeluaran.fromMap(Map<String, Object?> m) => Pengeluaran(
    id: m['id'] as int,
    nama: m['nama'] as String,
    jumlah: m['jumlah'] as int,
    kategori: m['kategori'] as String,
    tanggal: m['tanggal'] as String,
  );
}

// ---------- AKSES DATA ----------
class DbPengeluaran {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'pengeluaran.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE pengeluaran('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'nama TEXT NOT NULL, '
          'jumlah INTEGER NOT NULL, '
          'kategori TEXT NOT NULL, '
          'tanggal TEXT NOT NULL)',
        );
      },
    );
    return _db!;
  }

  static Future<int> tambah(Pengeluaran e) async {
    final db = await database;
    return db.insert('pengeluaran', e.toMap());
  }

  static Future<List<Pengeluaran>> semua() async {
    final db = await database;
    final rows = await db.query(
      'pengeluaran',
      orderBy: 'tanggal DESC, id DESC',
    );
    return rows.map(Pengeluaran.fromMap).toList();
  }

  static Future<int> ubah(Pengeluaran e) async {
    final db = await database;
    return db.update(
      'pengeluaran',
      e.toMap(),
      where: 'id = ?',
      whereArgs: [e.id],
    );
  }

  static Future<int> hapus(int id) async {
    final db = await database;
    return db.delete('pengeluaran', where: 'id = ?', whereArgs: [id]);
  }

  // Menghitung total pengeluaran langsung di sisi basis data (SELECT SUM)
  static Future<int> total() async {
    final db = await database;
    final hasil = await db.rawQuery(
      'SELECT SUM(jumlah) AS total FROM pengeluaran',
    );
    return (hasil.first['total'] as int?) ?? 0;
  }
}
