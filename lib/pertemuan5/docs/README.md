# Dokumentasi Praktikum Flutter - Pertemuan 5
Penyimpanan Lokal (SharedPreferences dan SQLite)

## Informasi Praktikum
- Topik Praktikum: Pemilihan jenis penyimpanan lokal (key-value, database, berkas), penyimpanan pengaturan sederhana dengan shared_preferences, perancangan tabel dan pembuatan basis data SQLite dengan sqflite, implementasi operasi CRUD yang terhubung dengan UI, serta pemastian data tetap tersimpan setelah aplikasi ditutup.
- Nama Mahasiswa: Dafa Rafi Nurwansyah
- NIM: 20240801157
- Program Studi: Teknik Informatika

---

## 1. Tujuan Pembelajaran
Sesuai dengan modul praktikum pertemuan 5, setelah menyelesaikan praktikum ini mahasiswa diharapkan mampu:
1. Memilih jenis penyimpanan lokal yang tepat: key-value, database, atau berkas.
2. Menyimpan dan membaca pengaturan sederhana dengan shared_preferences.
3. Merancang tabel dan membuat basis data SQLite dengan sqflite.
4. Mengimplementasikan operasi CRUD (Create, Read, Update, Delete) dan menghubungkannya dengan UI.
5. Memastikan data tetap ada setelah aplikasi ditutup dan dibuka kembali.

---

## 2. Alat dan Bahan
- Laptop dengan Flutter SDK versi stabil terbaru (versi 3.47.4) beserta Dart.
- Editor kode Visual Studio Code atau Android Studio.
- Emulator Android atau perangkat fisik Android (sqflite paling stabil di Android/iOS).
- Koneksi internet untuk mengunduh paket (setelah itu tidak diperlukan).
- Paket dependensi resmi: `shared_preferences`, `sqflite`, dan `path`.

---

## 3. Teori Singkat dan Konsep Dasar untuk Orang Awam

### Mengapa Perlu Penyimpanan Lokal?
Data yang hanya berada di memori (variabel atau State) akan hilang begitu aplikasi ditutup. Agar data bertahan, aplikasi perlu menyimpannya di penyimpanan perangkat (persistence).

| Pilihan | Cocok untuk | Paket |
| --- | --- | --- |
| Key-value | Pengaturan kecil: tema, nama, status login, angka terakhir | `shared_preferences` |
| Database SQLite | Data terstruktur dan banyak: catatan, transaksi, daftar produk | `sqflite`, `path` |
| Berkas | Dokumen, gambar, ekspor/impor data | `path_provider`, `dart:io` |

### CRUD dan SQL
Setiap operasi CRUD memiliki padanan perintah SQL dan method sqflite:

| CRUD | SQL | Method sqflite |
| --- | --- | --- |
| Create | INSERT | `db.insert()` |
| Read | SELECT | `db.query()` |
| Update | UPDATE | `db.update()` |
| Delete | DELETE | `db.delete()` |

### Aman dari SQL Injection
Jangan menyusun query dengan menyambung teks dari pengguna. Gunakan tanda tanya sebagai placeholder lewat `where: 'judul LIKE ?', whereArgs: ['%$kata%']` agar sqflite membersihkan nilai secara otomatis.

---

## 4. Struktur Berkas Pertemuan 5

Berikut adalah struktur berkas yang terdapat pada folder lib/pertemuan5:
```text
lib/pertemuan5/
├── pertemuan5.dart      # Bagian A (SharedPreferences: nama, mode gelap, jumlah pembukaan)
├── catatan.dart         # Bagian B–D (Model Catatan, DbHelper, dan UI CRUD dasar SQLite)
├── latihan.dart         # Latihan Mandiri 1–4 (konfirmasi hapus, pencarian, kolom dibuat, urutan)
├── pengeluaran_db.dart  # Model Pengeluaran dan akses data (DbPengeluaran) untuk tugas
├── tugas.dart           # Tugas Praktikum (Aplikasi Pencatat Pengeluaran) beserta UI-nya
├── modul/
│   └── modul-praktikum-flutter-pertemuan-5.pdf
└── docs/
    └── README.md        # Dokumen panduan dan laporan lengkap ini
```

Catatan: berkas `pengeluaran_db.dart` (model + akses data) sengaja dipisahkan dari `tugas.dart` (UI) agar rapi dan sesuai rubrik penilaian.

---

## 5. Dokumentasi Kode Lengkap dan Penjelasan

### A. Berkas pertemuan5.dart (Bagian A: SharedPreferences)
Berkas ini menyimpan nama, pilihan mode gelap, dan hitungan berapa kali aplikasi dibuka.

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Praktikum 5', home: const PengaturanPage());
  }
}

class _PengaturanPageState extends State<PengaturanPage> {
  final _controller = TextEditingController();
  bool _gelap = false;
  int _bukaKe = 0;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _controller.text = prefs.getString('nama') ?? '';
      _gelap = prefs.getBool('gelap') ?? false;
      _bukaKe = (prefs.getInt('bukaKe') ?? 0) + 1;
    });
    await prefs.setInt('bukaKe', _bukaKe);
  }

  Future<void> _simpanNama() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama', _controller.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Nama disimpan')));
  }

  Future<void> _ubahTema(bool nilai) async {
    setState(() => _gelap = nilai);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gelap', nilai);
  }
  // ... (build: TextField nama, tombol Simpan, SwitchListTile mode gelap)
}
```

#### Penjelasan Rinci Kode di Atas:
1. `SharedPreferences.getInstance()` mengambil objek penyimpanan key-value.
2. Nilai bawaan dipakai saat pembacaan awal, misalnya `prefs.getString('nama') ?? ''`, agar tidak bernilai null.
3. `if (!mounted) return;` dipakai setelah setiap `await` sebelum memakai `context` atau `setState` untuk mencegah peringatan `use_build_context_synchronously`.

---

### B. Berkas catatan.dart (Bagian B–D: Model, DbHelper, dan CRUD UI)
Berkas ini berisi model `Catatan`, kelas bantu `DbHelper`, halaman daftar (`CatatanPage`), dan halaman form (`FormCatatanPage`).

```dart
class Catatan {
  final int? id;
  final String judul;
  final String isi;

  const Catatan({this.id, required this.judul, required this.isi});

  Map<String, Object?> toMap() => {'id': id, 'judul': judul, 'isi': isi};

  factory Catatan.fromMap(Map<String, Object?> m) => Catatan(
    id: m['id'] as int,
    judul: m['judul'] as String,
    isi: m['isi'] as String,
  );
}

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'catatan.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE catatan('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'judul TEXT NOT NULL, '
          'isi TEXT NOT NULL)',
        );
      },
    );
    return _db!;
  }

  static Future<int> tambah(Catatan c) async {
    final db = await database;
    return db.insert('catatan', c.toMap());
  }

  static Future<List<Catatan>> semua() async {
    final db = await database;
    final rows = await db.query('catatan', orderBy: 'id DESC');
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
```

#### Penjelasan Rinci Kode di Atas:
1. `id` bernilai null saat catatan baru dibuat, lalu diisi otomatis oleh SQLite (AUTOINCREMENT).
2. `toMap()` dan `fromMap()` menjadi jembatan antara objek Dart dan baris tabel SQLite.
3. `where: 'id = ?', whereArgs: [id]` memakai placeholder agar aman dari SQL injection.
4. Halaman `CatatanPage` memakai `FutureBuilder` untuk membaca data dan memanggil `_muat()` setiap kembali dari form; `FormCatatanPage` dipakai untuk tambah (data kosong) sekaligus ubah (data terisi).

---

### C. Berkas latihan.dart (Latihan Mandiri 1–4)
Berkas ini mengembangkan aplikasi catatan dengan konfirmasi hapus, pencarian, kolom tanggal dibuat, dan pilihan urutan yang tersimpan.

```dart
class DbHelper {
  static const int _versi = 2; // naik dari versi 1 ke 2

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'catatan_latihan.db');
    _db = await openDatabase(
      path,
      version: _versi,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE catatan('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'judul TEXT NOT NULL, '
          'isi TEXT NOT NULL, '
          'dibuat TEXT NOT NULL)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE catatan ADD COLUMN dibuat TEXT');
        }
      },
    );
    return _db!;
  }

  // Latihan 2: pencarian memakai placeholder dan whereArgs
  static Future<List<Catatan>> cari(String kata, {String urutan = 'terbaru'}) async {
    final db = await database;
    final rows = await db.query(
      'catatan',
      where: 'judul LIKE ? OR isi LIKE ?',
      whereArgs: ['%$kata%', '%$kata%'],
      orderBy: urutan == 'terlama' ? 'id ASC' : 'id DESC',
    );
    return rows.map(Catatan.fromMap).toList();
  }
}
```

```dart
// Latihan 1: dialog konfirmasi sebelum menghapus
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
```

```dart
// Latihan 4: menyimpan pilihan urutan ke shared_preferences
Future<void> _muat() async {
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
```

#### Penjelasan Rinci Kode di Atas:
1. Menaikkan `version` menjadi 2 memicu `onUpgrade`, yang menjalankan `ALTER TABLE catatan ADD COLUMN dibuat TEXT`. Bila version tidak dinaikkan, sqflite tidak akan mengubah skema dan muncul galat "no such column".
2. Pencarian memakai `LIKE` dengan tanda `%` di kedua sisi untuk mencocokkan sebagian judul atau isi.

---

### D. Berkas pengeluaran_db.dart dan tugas.dart (Tugas: Pencatat Pengeluaran)
Model dan akses data dipisahkan pada `pengeluaran_db.dart`, sedangkan UI berada pada `tugas.dart`.

```dart
// pengeluaran_db.dart
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

class DbPengeluaran {
  static Future<int> tambah(Pengeluaran e) async { /* INSERT */ }
  static Future<List<Pengeluaran>> semua() async {
    final db = await database;
    final rows = await db.query('pengeluaran', orderBy: 'tanggal DESC, id DESC');
    return rows.map(Pengeluaran.fromMap).toList();
  }
  static Future<int> ubah(Pengeluaran e) async { /* UPDATE */ }
  static Future<int> hapus(int id) async { /* DELETE */ }

  // Menghitung total langsung di basis data (SELECT SUM)
  static Future<int> total() async {
    final db = await database;
    final hasil = await db.rawQuery('SELECT SUM(jumlah) AS total FROM pengeluaran');
    return (hasil.first['total'] as int?) ?? 0;
  }
}
```

```dart
// tugas.dart: total dihitung di Dart saat daftar dimuat
final total = data.fold<int>(0, (jumlah, e) => jumlah + e.jumlah);

// tugas.dart: menyimpan pengaturan mode gelap dengan shared_preferences
Future<void> _ubahGelap(bool nilai) async {
  setState(() => _gelap = nilai);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('gelap', nilai);
}
```

#### Penjelasan Rinci Kode di Atas:
1. Tabel `pengeluaran` memiliki kolom `id, nama, jumlah, kategori, tanggal` sesuai ketentuan tugas.
2. Validasi formulir memastikan nama wajib diisi, jumlah berupa angka lebih dari 0, dan kategori dipilih dari dropdown.
3. Total pengeluaran ditampilkan pada halaman utama; nilai dapat dihitung di Dart maupun memakai `SELECT SUM(jumlah)`.
4. Data tetap ada setelah aplikasi ditutup karena tersimpan di SQLite.

---

## 6. Penyelesaian Latihan Mandiri
Berikut rincian solusi setiap butir latihan pada modul pertemuan 5:
1. Menampilkan `AlertDialog` konfirmasi "Hapus catatan ini?" sebelum data dihapus (fungsi `_konfirmasiHapus`).
2. Menambahkan kolom pencarian yang memfilter daftar memakai `where: 'judul LIKE ?'` dengan `whereArgs: ['%$kata%']`.
3. Menambahkan kolom `dibuat` (tanggal dibuat), menaikkan `version` menjadi 2, dan menambahkan `onUpgrade` berisi `ALTER TABLE catatan ADD COLUMN dibuat TEXT`. Bila version tidak dinaikkan, skema lama tetap dipakai sehingga muncul galat "no such column: dibuat".
4. Menyimpan pilihan urutan (terbaru/terlama) dengan shared_preferences dan menerapkannya pada `orderBy`.

---

## 7. Penyelesaian Tugas Praktikum
Aplikasi Pencatat Pengeluaran telah diimplementasikan penuh pada berkas `pengeluaran_db.dart` dan `tugas.dart`. Seluruh kriteria tugas terpenuhi:
- Tabel pengeluaran dengan kolom id, nama, jumlah (integer), kategori, dan tanggal.
- CRUD lengkap (daftar, tambah, ubah, hapus) dengan formulir bervalidasi.
- Total pengeluaran ditampilkan di halaman utama.
- Satu pengaturan (mode gelap) disimpan dengan shared_preferences.
- Data tetap ada setelah aplikasi ditutup dan dibuka kembali.

---

## 8. Jawaban Pertanyaan Refleksi Modul

### Pertanyaan 1: Mengapa shared_preferences kurang cocok untuk menyimpan ratusan catatan? Apa pilihan yang lebih baik?
Jawaban:
`shared_preferences` dirancang untuk data key-value yang kecil dan sederhana (misalnya pengaturan). Menyimpan ratusan catatan berarti membungkus seluruh daftar menjadi satu teks panjang, sehingga setiap perubahan kecil memaksa penulisan ulang seluruh data, tidak ada pencarian, pengurutan, atau penghitungan yang efisien, dan sulit menangani relasi antar data. Pilihan yang lebih baik adalah basis data SQLite (sqflite) yang mendukung tabel, query, indeks, dan operasi CRUD yang efisien.

### Pertanyaan 2: Mengapa query memakai placeholder ? dan whereArgs, bukan menyambung teks langsung?
Jawaban:
Menyambung teks pengguna langsung ke dalam query membuka celah SQL injection, yaitu pengguna dapat menuliskan perintah SQL berbahaya yang ikut dijalankan. Dengan placeholder `?` dan `whereArgs`, sqflite mengirim nilai sebagai parameter terpisah yang dibersihkan (escaped) otomatis sehingga aman dari manipulasi query.

### Pertanyaan 3: Mengapa setelah kembali dari halaman form, daftar perlu dimuat ulang? Bagaimana caranya pada kode ini?
Jawaban:
Halaman daftar membaca data dari basis data pada saat halaman itu dibangun. Ketika pengguna menambah atau mengubah data pada halaman form, halaman daftar yang ada di belakang tidak otomatis mengetahui perubahan tersebut. Karena itu, setelah `Navigator.push` selesai dan kembali, daftar dimuat ulang dengan memanggil `_muat()` yang mengatur ulang `_future` di dalam `setState` sehingga `FutureBuilder` membaca data terbaru.

### Pertanyaan 4: Apa fungsi onCreate dan onUpgrade, dan kapan masing-masing dijalankan?
Jawaban:
- `onCreate` dijalankan satu kali ketika basis data pertama kali dibuat. Fungsinya membuat tabel dan struktur awal (menjalankan perintah `CREATE TABLE`).
- `onUpgrade` dijalankan ketika basis data yang sudah ada dibuka dengan `version` yang lebih tinggi dari versi tersimpan. Fungsinya menyesuaikan skema lama ke skema baru (misalnya `ALTER TABLE`, `DROP`, atau `CREATE` tabel baru).

---

## 9. Panduan Menjalankan Program Hingga Berhasil

Langkah-langkah menjalankan kode program melalui terminal:

1. Pastikan paket dependensi sudah terpasang:
   ```bash
   flutter pub get
   ```
2. Jalankan aplikasi Bagian A (SharedPreferences):
   ```bash
   flutter run -t lib/pertemuan5/pertemuan5.dart
   ```
   Verifikasi: isi nama, aktifkan mode gelap, hentikan aplikasi sepenuhnya (Stop, bukan hot reload) lalu jalankan lagi. Nama dan mode gelap harus tetap ada, dan hitungan bertambah setiap kali dibuka.
3. Jalankan aplikasi catatan CRUD dasar (Bagian B–D):
   ```bash
   flutter run -t lib/pertemuan5/catatan.dart
   ```
   Verifikasi: menambah catatan memunculkannya di daftar; mengetuk catatan membuka form terisi dan menyimpannya memperbarui data; ikon sampah menghapus; tutup aplikasi sepenuhnya dan buka lagi: semua catatan masih ada.
4. Jalankan aplikasi catatan versi latihan mandiri:
   ```bash
   flutter run -t lib/pertemuan5/latihan.dart
   ```
   Verifikasi: pencarian menyaring daftar, tombol urut di AppBar mengganti urutan (tersimpan), dan menghapus catatan menampilkan dialog konfirmasi.
5. Jalankan aplikasi tugas Pencatat Pengeluaran:
   ```bash
   flutter run -t lib/pertemuan5/tugas.dart
   ```
   Verifikasi: tambah pengeluaran lewat tombol tambah, isi nama/jumlah/kategori/tanggal, lalu simpan. Total pengeluaran pada kartu atas akan terbarui. Matikan dan jalankan ulang aplikasi: data dan pilihan mode gelap tetap tersimpan.

### Panduan Mengatasi Kendala Umum (Troubleshooting)
- `MissingPluginException`: hentikan aplikasi sepenuhnya lalu jalankan ulang (`flutter run`); hot reload/restart tidak memuat plugin baru.
- Data baru tidak muncul di daftar: pastikan `_muat()` dipanggil setelah tambah/ubah/hapus.
- Galat `no such table` / `no such column`: skema diubah tanpa menaikkan `version`. Saat pengembangan, hapus data aplikasi (uninstall atau Clear data) lalu jalankan ulang.
- Bernilai null pada pembacaan awal: gunakan nilai bawaan seperti `prefs.getString('x') ?? ''`.
- sqflite tidak jalan di web/Windows/Linux: gunakan emulator Android, atau paket `sqflite_common_ffi` untuk desktop.

---

## 10. Referensi dan Sumber Belajar
1. Modul Praktikum Flutter Fundamental - Pertemuan 5: Penyimpanan Lokal (SharedPreferences dan SQLite). Program Studi Teknik Informatika.
2. Menyimpan data key-value: https://docs.flutter.dev/cookbook/persistence/key-value
3. Membaca dan menulis SQLite: https://docs.flutter.dev/cookbook/persistence/sqlite
4. Paket shared_preferences (pub.dev): https://pub.dev/packages/shared_preferences
5. Paket sqflite (pub.dev): https://pub.dev/packages/sqflite
