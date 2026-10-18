import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

// Latihan Mandiri Pertemuan 5 (aplikasi Catatan Saya versi lanjutan):
// 1. Dialog konfirmasi sebelum menghapus catatan.
// 2. Kolom pencarian dengan query "judul LIKE ?".
// 3. Kolom "dibuat" (tanggal) memakai version 2 dan onUpgrade.
// 4. Pilihan urutan (terbaru/terlama) disimpan dengan shared_preferences.

// ---------- MODEL ----------
class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String dibuat;

  const Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.dibuat,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'judul': judul,
    'isi': isi,
    'dibuat': dibuat,
  };

  factory Catatan.fromMap(Map<String, Object?> m) => Catatan(
    id: m['id'] as int,
    judul: m['judul'] as String,
    isi: m['isi'] as String,
    dibuat: (m['dibuat'] as String?) ?? '-',
  );
}

// Membuat catatan baru dengan tanggal dibuat saat ini
Catatan catatanBaru({required String judul, required String isi}) {
  return Catatan(
    judul: judul,
    isi: isi,
    dibuat: DateTime.now().toIso8601String(),
  );
}

// ---------- AKSES DATA ----------
class DbHelper {
  static Database? _db;

  // Versi 2: menambahkan kolom "dibuat" pada tabel catatan.
  static const int _versi = 2;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'catatan_latihan.db');
    _db = await openDatabase(
      path,
      version: _versi,
      onCreate: (db, version) {
        // Pemasangan baru langsung memakai skema versi terbaru.
        return db.execute(
          'CREATE TABLE catatan('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'judul TEXT NOT NULL, '
          'isi TEXT NOT NULL, '
          'dibuat TEXT NOT NULL)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Dijalankan hanya bila basis data versi lama dibuka oleh versi baru.
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE catatan ADD COLUMN dibuat TEXT');
        }
      },
    );
    return _db!;
  }

  static Future<int> tambah(Catatan c) async {
    final db = await database;
    return db.insert('catatan', c.toMap());
  }

  static Future<List<Catatan>> semua({String urutan = 'terbaru'}) async {
    final db = await database;
    final rows = await db.query(
      'catatan',
      orderBy: urutan == 'terlama' ? 'id ASC' : 'id DESC',
    );
    return rows.map(Catatan.fromMap).toList();
  }

  // Latihan 2: pencarian memakai placeholder ? dan whereArgs (aman dari SQL injection)
  static Future<List<Catatan>> cari(
    String kata, {
    String urutan = 'terbaru',
  }) async {
    final db = await database;
    final rows = await db.query(
      'catatan',
      where: 'judul LIKE ? OR isi LIKE ?',
      whereArgs: ['%$kata%', '%$kata%'],
      orderBy: urutan == 'terlama' ? 'id ASC' : 'id DESC',
    );
    return rows.map(Catatan.fromMap).toList();
  }

  static Future<int> ubah(Catatan c) async {
    final db = await database;
    return db.update('catatan', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  static Future<int> hapus(int id) async {
    final db = await database;
    return db.delete('catatan', where: 'id = ?', whereArgs: [id]);
  }
}

// ---------- TAMPILAN (UI) ----------
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catatan Saya (Latihan)',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const CatatanLatihanPage(),
    );
  }
}

class CatatanLatihanPage extends StatefulWidget {
  const CatatanLatihanPage({super.key});
  @override
  State<CatatanLatihanPage> createState() => _CatatanLatihanPageState();
}

class _CatatanLatihanPageState extends State<CatatanLatihanPage> {
  final _cari = TextEditingController();
  late Future<List<Catatan>> _future;
  String _urutan = 'terbaru';

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    // Latihan 4: memuat pilihan urutan yang tersimpan pada penyimpanan lokal
    final prefs = await SharedPreferences.getInstance();
    _urutan = prefs.getString('urutan') ?? 'terbaru';
    if (!mounted) return;
    setState(() {
      final kata = _cari.text.trim();
      _future = kata.isEmpty
          ? DbHelper.semua(urutan: _urutan)
          : DbHelper.cari(kata, urutan: _urutan);
    });
  }

  Future<void> _ubahUrutan() async {
    final baru = _urutan == 'terbaru' ? 'terlama' : 'terbaru';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('urutan', baru);
    if (!mounted) return;
    setState(() => _urutan = baru);
    _muat();
  }

  Future<void> _buka([Catatan? catatan]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormCatatanPage(catatan: catatan)),
    );
    if (!mounted) return;
    _muat();
  }

  // Latihan 1: dialog konfirmasi sebelum menghapus data
  Future<void> _konfirmasiHapus(Catatan c) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus catatan ini?'),
        content: Text('"${c.judul}" akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    await DbHelper.hapus(c.id!);
    if (!mounted) return;
    _muat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        actions: [
          IconButton(
            tooltip: _urutan == 'terbaru'
                ? 'Urutkan: Terbaru'
                : 'Urutkan: Terlama',
            icon: Icon(
              _urutan == 'terbaru' ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            onPressed: _ubahUrutan,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _cari,
              decoration: InputDecoration(
                labelText: 'Cari catatan',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _cari.clear();
                    _muat();
                  },
                ),
              ),
              onChanged: (_) => _muat(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Catatan>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Galat: ${snapshot.error}'));
                }
                final data = snapshot.data!;
                if (data.isEmpty) {
                  return const Center(child: Text('Catatan tidak ditemukan'));
                }
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final c = data[i];
                    return ListTile(
                      title: Text(c.judul),
                      subtitle: Text(
                        '${c.dibuat.replaceFirst('T', ' ').split('.').first}\n${c.isi}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      onTap: () => _buka(c),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _konfirmasiHapus(c),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormCatatanPage extends StatefulWidget {
  final Catatan? catatan;
  const FormCatatanPage({super.key, this.catatan});

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judul;
  late final TextEditingController _isi;

  @override
  void initState() {
    super.initState();
    _judul = TextEditingController(text: widget.catatan?.judul ?? '');
    _isi = TextEditingController(text: widget.catatan?.isi ?? '');
  }

  @override
  void dispose() {
    _judul.dispose();
    _isi.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.catatan == null) {
      await DbHelper.tambah(
        catatanBaru(judul: _judul.text.trim(), isi: _isi.text.trim()),
      );
    } else {
      await DbHelper.ubah(
        Catatan(
          id: widget.catatan!.id,
          judul: _judul.text.trim(),
          isi: _isi.text.trim(),
          dibuat: widget.catatan!.dibuat,
        ),
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.catatan == null;
    return Scaffold(
      appBar: AppBar(title: Text(baru ? 'Catatan Baru' : 'Ubah Catatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judul,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _isi,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Isi catatan',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
