# Dokumentasi Praktikum Flutter - Pertemuan 7
Mini Proyek Terpadu — TabungKu (To-Do List + Manajemen Keuangan)

## Informasi Praktikum
- Topik Praktikum: Integrasi materi Pertemuan 1–6 dalam satu aplikasi utuh, perancangan aturan bisnis dan tabel SQLite, form dengan validasi, query agregasi (COUNT, SUM, GROUP BY), state yang selalu sinkron antar-tab, tema, named routes, NavigationBar, serta animasi kemajuan target tabungan.
- Nama Mahasiswa: Dafa Rafi Nurwansyah
- NIM: 20240801157
- Program Studi: Teknik Informatika

---

## 1. Tujuan Pembelajaran
Sesuai modul praktikum pertemuan 7, setelah menyelesaikan mini proyek ini mahasiswa mampu:
1. Menganalisis kebutuhan sederhana dan menerjemahkannya menjadi aturan bisnis, rancangan data, dan daftar layar.
2. Mengintegrasikan materi Pertemuan 1–6 dalam satu aplikasi utuh: widget dan layout, form dan validasi, state, SQLite, shared_preferences, tema, named routes, NavigationBar, dan animasi.
3. Menulis query agregasi (COUNT, SUM, GROUP BY) untuk membuat laporan.
4. Menyusun kode ke dalam struktur folder yang rapi (model, data, state, widget, halaman).
5. Menguji aplikasi dengan skenario uji, mendokumentasikan, dan mendemonstrasikannya.

---

## 2. Alat dan Bahan
- Laptop dengan Flutter SDK stabil (pengujian: Flutter 3.47.4, Dart 3.13.3).
- Editor Visual Studio Code atau Android Studio.
- Emulator Android atau perangkat fisik Android (sqflite paling stabil di Android/iOS).
- Paket yang sudah tersedia pada proyek: `sqflite`, `path`, `shared_preferences`, `provider`, `http`.
- Tidak ada paket baru khusus pertemuan ini.

---

## 3. Teori Singkat dan Konsep Dasar

### 3.1 Deskripsi Aplikasi
TabungKu adalah aplikasi to-do list yang setiap kegiatannya dapat dicatat keuangannya. Satu kegiatan memiliki nama, tanggal, status selesai, jenis keuangan, nominal, dan kategori (khusus pengeluaran). Aplikasi meringkas pemasukan, pengeluaran, dan tabungan harian lalu membandingkannya dengan target menabung.

### 3.2 Aturan Bisnis yang Diterapkan
- Tanggal disimpan sebagai teks `yyyy-MM-dd` agar mudah diurutkan dan dibandingkan.
- Tabungan harian = total pemasukan − total pengeluaran pada tanggal tersebut.
- Semua kegiatan dihitung, baik yang sudah selesai maupun belum (keputusan desain modul).
- Nominal wajib angka > 0 untuk pemasukan/pengeluaran.
- Kategori pengeluaran: Makan, Transport, Belajar, Hiburan, Lainnya.
- Jenis "tanpa uang" selalu bernominal 0 dan kategori `-`.
- Target tabungan bawaan Rp 20.000 dan dapat diubah; pengaturan bertahan setelah aplikasi ditutup.
- Tabungan negatif menampilkan peringatan; target tercapai menampilkan apresiasi.

### 3.3 Peta Fitur Wajib
| Kode | Fitur | Berkas utama |
| --- | --- | --- |
| F1 | Daftar kegiatan hari ini, centang selesai, ubah, hapus dengan konfirmasi | `pages/beranda_page.dart`, `widgets/kegiatan_tile.dart` |
| F2 | Form tambah/ubah dengan validasi dan date picker | `pages/form_kegiatan_page.dart` |
| F3 | Penyimpanan SQLite | `data/db_helper.dart` |
| F4 | Ringkasan hari ini | `pages/beranda_page.dart`, `widgets/ringkasan_card.dart` |
| F5 | Laporan: tanggal, ringkasan, per kategori, 7 hari | `pages/laporan_page.dart` |
| F6 | Target tabungan + indikator kemajuan beranimasi | `widgets/ringkasan_card.dart` |
| F7 | Pengaturan tema, warna, target yang tersimpan | `state/pengaturan.dart`, `pages/pengaturan_page.dart` |
| F8 | Tiga tab NavigationBar + form lewat named route | `pages/shell_page.dart`, `pertemuan7.dart` |

### 3.4 Query Agregasi dan `COALESCE`
Ringkasan satu hari dihitung dengan satu query, bukan dengan perulangan di Dart:

```sql
SELECT COUNT(*) AS jumlah,
       COALESCE(SUM(selesai), 0) AS selesai,
       COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0) AS masuk,
       COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0) AS keluar
FROM kegiatan
WHERE tanggal = ?
```

`CASE WHEN` memilah pemasukan dan pengeluaran. `COALESCE(..., 0)` mengganti `NULL` menjadi 0 ketika belum ada data, sehingga tidak muncul galat `type 'Null' is not a subtype of type 'int'`.

### 3.5 Sinkronisasi Tiga Tab dengan `versiData`
Tiga tab menampilkan data yang sama. Agar perubahan di satu tempat langsung terlihat di tempat lain, `db_helper.dart` memiliki:

```dart
final versiData = ValueNotifier<int>(0);
```

Setiap operasi tambah/ubah/hapus menaikkan `versiData.value`. Halaman yang menampilkan data mendengarkan notifier tersebut, lalu mengganti `Future`-nya sehingga `FutureBuilder` memuat ulang. Listener wajib dilepas di `dispose()` agar tidak bocor memori.

---

## 4. Struktur Berkas Pertemuan 7

```text
lib/pertemuan7/
├── pertemuan7.dart                 # Entry point aplikasi wajib (F1–F8)
├── latihan.dart                    # Variasi latihan: fitur lanjutan aktif
├── tugas.dart                      # Variasi tugas "Bekal Harian"
├── models/
│   └── kegiatan.dart               # Tipe, Kegiatan, Ringkasan, DataHari, laporan
├── data/
│   └── db_helper.dart              # SQLite CRUD + query laporan + versiData
├── state/
│   └── pengaturan.dart             # tema, warna, target + shared_preferences
├── utils/
│   └── format.dart                 # format rupiah, tanggal ISO, nama hari
├── widgets/
│   ├── ringkasan_card.dart         # kartu ringkasan + progress beranimasi
│   └── kegiatan_tile.dart          # satu baris kegiatan
├── pages/
│   ├── shell_page.dart             # NavigationBar tiga tab
│   ├── beranda_page.dart           # hari ini + pencarian/filter (lanjutan)
│   ├── form_kegiatan_page.dart     # tambah/ubah kegiatan
│   ├── laporan_page.dart           # laporan harian, kategori, 7 hari/bulan
│   └── pengaturan_page.dart        # target, tema, reset data
├── modul/
│   └── modul-praktikum-flutter-pertemuan-7.pdf
└── docs/
    └── README.md                   # dokumen ini
```

Skema tabel SQLite:

| Kolom | Tipe | Keterangan |
| --- | --- | --- |
| `id` | INTEGER PK AUTOINCREMENT | Kunci utama |
| `judul` | TEXT NOT NULL | Nama kegiatan |
| `tanggal` | TEXT NOT NULL | Format `yyyy-MM-dd` |
| `selesai` | INTEGER NOT NULL | 0/1 karena SQLite tidak punya boolean |
| `tipe` | TEXT NOT NULL | `tanpa`, `pemasukan`, `pengeluaran` |
| `nominal` | INTEGER NOT NULL | Rupiah bulat |
| `kategori` | TEXT NOT NULL | Diisi untuk pengeluaran, selain itu `-` |

---

## 5. Dokumentasi Kode Lengkap dan Penjelasan

### A. Model Data (`models/kegiatan.dart`)

```dart
enum Tipe { tanpa, pemasukan, pengeluaran }

class Kegiatan {
  final int? id;
  final String judul;
  final String tanggal; // yyyy-MM-dd
  final bool selesai;
  final Tipe tipe;
  final int nominal;
  final String kategori;

  Map<String, Object?> toMap() => {
    'id': id,
    'judul': judul,
    'tanggal': tanggal,
    'selesai': selesai ? 1 : 0,
    'tipe': tipe.nilai,
    'nominal': nominal,
    'kategori': kategori,
  };

  factory Kegiatan.fromMap(Map<String, Object?> m) => Kegiatan(
    id: m['id'] as int,
    judul: m['judul'] as String,
    tanggal: m['tanggal'] as String,
    selesai: (m['selesai'] as int) == 1,
    tipe: Tipe.values.byName(m['tipe'] as String),
    nominal: m['nominal'] as int,
    kategori: m['kategori'] as String,
  );
}

class Ringkasan {
  final int jumlahKegiatan, selesai, pemasukan, pengeluaran;
  int get tabungan => pemasukan - pengeluaran;
  bool get negatif => tabungan < 0;
}
```

Penjelasan:
1. `toMap()`/`fromMap()` menjadi jembatan antara objek Dart dan baris SQLite.
2. Boolean disimpan 0/1 dan enum disimpan sebagai teks agar mudah dibaca di database.
3. `Ringkasan` menyimpan angka hasil query; `tabungan` dihitung sekali di getter.

---

### B. Lapisan Data (`data/db_helper.dart`)

#### B.1 Membuka database dan membuat tabel

```dart
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
```

Index `tanggal` mempercepat filter harian, laporan per kategori, dan rentang tujuh hari.

#### B.2 CRUD dan pemberitahuan perubahan

```dart
static Future<int> tambah(Kegiatan k) async {
  final db = await database;
  final id = await db.insert('kegiatan', k.toMap()..remove('id'));
  _beriTahuPerubahan();
  return id;
}

static Future<int> ubah(Kegiatan k) async {
  final db = await database;
  final hasil = await db.update('kegiatan', k.toMap()..remove('id'),
      where: 'id = ?', whereArgs: [k.id]);
  _beriTahuPerubahan();
  return hasil;
}

static Future<int> hapus(int id) async {
  final db = await database;
  final hasil = await db.delete('kegiatan', where: 'id = ?', whereArgs: [id]);
  _beriTahuPerubahan();
  return hasil;
}

static void _beriTahuPerubahan() => versiData.value++;
```

`id` dihapus dari Map saat insert/update karena kolom id diisi otomatis oleh SQLite.

#### B.3 Ringkasan harian dan pengeluaran per kategori

```dart
static Future<Ringkasan> ringkasan(String tanggal) async {
  final db = await database;
  final hasil = await db.rawQuery('''
    SELECT COUNT(*) AS jumlah,
           COALESCE(SUM(selesai), 0) AS selesai,
           COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0) AS masuk,
           COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0) AS keluar
    FROM kegiatan
    WHERE tanggal = ?
  ''', [tanggal]);
  final baris = hasil.first;
  return Ringkasan(
    jumlahKegiatan: (baris['jumlah'] as num).toInt(),
    selesai: (baris['selesai'] as num).toInt(),
    pemasukan: (baris['masuk'] as num).toInt(),
    pengeluaran: (baris['keluar'] as num).toInt(),
  );
}

static Future<List<MapEntry<String, int>>> pengeluaranPerKategori(
  String tanggal,
) async {
  final db = await database;
  final rows = await db.rawQuery('''
    SELECT kategori, SUM(nominal) AS total
    FROM kegiatan
    WHERE tanggal = ? AND tipe = 'pengeluaran'
    GROUP BY kategori
    ORDER BY total DESC
  ''', [tanggal]);
  return rows.map((r) => MapEntry(
    r['kategori'] as String,
    (r['total'] as num).toInt(),
  )).toList();
}
```

`num.toInt()` dipakai karena SQLite dapat mengembalikan `int` atau `double` untuk hasil agregasi.

#### B.4 Tujuh hari terakhir, pencarian, laporan bulanan, ekspor

```dart
static Future<List<HariLaporan>> tujuhHariTerakhir(String akhir) async {
  final akhirDate = parseTanggalIso(akhir);
  final mulaiDate = akhirDate.subtract(const Duration(days: 6));
  final rows = await db.rawQuery('''
    SELECT tanggal,
           COUNT(*) AS jumlah,
           COALESCE(SUM(selesai), 0) AS selesai,
           COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0) AS masuk,
           COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0) AS keluar
    FROM kegiatan
    WHERE tanggal BETWEEN ? AND ?
    GROUP BY tanggal
  ''', [mulai, akhir]);
  // Hari tanpa data tetap dimasukkan dengan Ringkasan kosong (0).
}

static Future<List<Kegiatan>> cari({
  String? kata, Tipe? tipe, String? kategori, String? tanggal,
}) async {
  final syarat = <String>[];
  final args = <Object?>[];
  if (tanggal != null) { syarat.add('tanggal = ?'); args.add(tanggal); }
  if (kata != null && kata.trim().isNotEmpty) {
    syarat.add('judul LIKE ?');
    args.add('%${kata.trim()}%');
  }
  if (tipe != null) { syarat.add('tipe = ?'); args.add(tipe.nilai); }
  if (kategori != null) { syarat.add('kategori = ?'); args.add(kategori); }
  final rows = await db.query('kegiatan',
      where: syarat.isEmpty ? null : syarat.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'tanggal DESC, selesai ASC, id DESC');
  return rows.map(Kegiatan.fromMap).toList();
}

static Future<String> eksporLaporan(String tanggal) async {
  final laporan = await laporanHarian(tanggal);
  // ... menyusun teks laporan dengan StringBuffer ...
  return b.toString();
}
```

Penjelasan:
1. `LIKE ?` dengan argumen `%kata%` aman dari SQL injection karena nilai tidak disambung ke string query.
2. Rentang tujuh hari memakai satu query `BETWEEN` lalu melengkapi hari kosong di Dart; hasilnya selalu tujuh baris.
3. Laporan bulanan memakai query yang sama dengan `BETWEEN` awal dan akhir bulan.
4. Ekspor hanya menyusun teks; penyalinan ke clipboard dilakukan halaman laporan.

---

### C. State Pengaturan (`state/pengaturan.dart`)

```dart
final temaMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final warnaSeed = ValueNotifier<Color>(Colors.indigo);
final targetTabungan = ValueNotifier<int>(20000);

Future<void> muatPengaturan({
  required String prefiks,
  Color warnaAwal = Colors.indigo,
  int targetAwal = 20000,
}) async {
  prefiksPengaturan = prefiks;
  final prefs = await SharedPreferences.getInstance();
  temaMode.value = (prefs.getBool(_kunci('gelap')) ?? false)
      ? ThemeMode.dark
      : ThemeMode.light;
  warnaSeed.value = Color(prefs.getInt(_kunci('seed')) ?? warnaAwal.toARGB32());
  targetTabungan.value = prefs.getInt(_kunci('target')) ?? targetAwal;
}
```

Penjelasan:
1. Tiga `ValueNotifier` menjadi sumber kebenaran pengaturan.
2. `prefiks` memisahkan pengaturan praktikum (`''`), latihan (`latihan_`), dan tugas (`tugas_`).
3. `muatPengaturan` dipanggil sebelum `runApp` sehingga tema yang tersimpan langsung dipakai pada frame pertama.

---

### D. Utilitas Format (`utils/format.dart`)

```dart
String formatRupiah(int angka) {
  final negatif = angka < 0;
  final teks = angka.abs().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return negatif ? '-$teks' : teks;
}

String tanggalIso(DateTime tanggal) {
  final y = tanggal.year.toString().padLeft(4, '0');
  final m = tanggal.month.toString().padLeft(2, '0');
  final d = tanggal.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
```

`tanggalIso` adalah satu-satunya tempat pembuatan format tanggal yang disimpan, sehingga konsisten di seluruh aplikasi.

---

### E. Widget Ringkasan dan Baris Kegiatan

#### E.1 Progress target beranimasi (`widgets/ringkasan_card.dart`)

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: progres),
  duration: const Duration(milliseconds: 700),
  curve: Curves.easeOutCubic,
  builder: (context, nilai, _) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: nilai,
        minHeight: 10,
        color: warnaProgres,
        backgroundColor: warna.surfaceContainerHighest,
      ),
    );
  },
)
```

Penjelasan:
1. `TweenAnimationBuilder` adalah animasi implisit: cukup memberi nilai akhir, Flutter menganimasikan dari 0.
2. `progres = tabungan / target` dibatasi 0–1 agar indikator tidak melewati batas.
3. Warna indikator berubah merah saat tabungan negatif dan hijau saat target tercapai.

#### E.2 Baris kegiatan (`widgets/kegiatan_tile.dart`)

```dart
Checkbox(
  value: kegiatan.selesai,
  onChanged: (nilai) => DbHelper.ubahSelesai(kegiatan, nilai ?? false),
),
Text(
  kegiatan.judul,
  style: TextStyle(
    decoration: kegiatan.selesai ? TextDecoration.lineThrough : null,
  ),
),
```

Nominal ditampilkan dengan tanda `+` hijau untuk pemasukan dan `−` merah untuk pengeluaran. Menu `PopupMenuButton` menyediakan aksi Ubah dan Hapus.

---

### F. Halaman-Halaman

#### F.1 Shell tiga tab (`pages/shell_page.dart`)

```dart
class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  late final List<Widget> _halaman = [
    BerandaPage(fiturLanjutan: widget.fiturLanjutan),
    LaporanPage(fiturLanjutan: widget.fiturLanjutan),
    const PengaturanPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.judul} · ${_judulTab[_index]}')),
      body: IndexedStack(index: _index, children: _halaman),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/form'),
              icon: const Icon(Icons.add),
              label: const Text('Kegiatan'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [/* Hari Ini, Laporan, Pengaturan */],
      ),
    );
  }
}
```

`IndexedStack` menyimpan state ketiga tab, sehingga posisi gulir dan hasil pencarian tidak hilang saat berpindah tab.

#### F.2 Beranda (`pages/beranda_page.dart`)

```dart
@override
void initState() {
  super.initState();
  _tanggal = tanggalIso(DateTime.now());
  _future = _ambil();
  versiData.addListener(_muat);
}

@override
void dispose() {
  versiData.removeListener(_muat);
  _pencarian.dispose();
  super.dispose();
}

Future<_TampilanHari> _ambil() async {
  final data = await DbHelper.dataHari(_tanggal);
  if (!_adaFilter) {
    return _TampilanHari(data.ringkasan, data.kegiatan, false);
  }
  final hasil = await DbHelper.cari(
    tanggal: _tanggal,
    kata: _pencarian.text,
    tipe: _filterTipe,
    kategori: _filterKategori,
  );
  return _TampilanHari(data.ringkasan, hasil, true);
}
```

Penjelasan:
1. `versiData.addListener(_muat)` membuat daftar otomatis segar setelah tambah/ubah/hapus/centang.
2. Saat filter aktif, ringkasan tetap ringkasan hari itu, sedangkan daftar berasal dari query `cari`.
3. Hapus selalu memakai dialog konfirmasi Batal/Hapus.

#### F.3 Form kegiatan (`pages/form_kegiatan_page.dart`)

```dart
TextFormField(
  controller: _judul,
  decoration: const InputDecoration(labelText: 'Nama kegiatan'),
  validator: (v) => (v == null || v.trim().isEmpty)
      ? 'Nama wajib diisi'
      : null,
),
// ...
TextFormField(
  controller: _nominal,
  keyboardType: TextInputType.number,
  validator: (v) {
    if (v == null || v.trim().isEmpty) return 'Nominal wajib diisi';
    final angka = int.tryParse(v.trim());
    if (angka == null) return 'Nominal harus berupa angka';
    if (angka <= 0) return 'Nominal harus lebih dari 0';
    return null;
  },
),
```

Field nominal dan kategori hanya muncul bila jenis bukan "tanpa uang". Saat menyimpan:
- jenis tanpa uang → nominal 0, kategori `-`;
- pemasukan → kategori `-`;
- pengeluaran → kategori wajib dipilih.

Form dibuka lewat named route:

```dart
onGenerateRoute: (settings) {
  if (settings.name == '/form') {
    final kegiatan = settings.arguments as Kegiatan?;
    return MaterialPageRoute(
      builder: (_) => FormKegiatanPage(kegiatan: kegiatan),
      settings: settings,
    );
  }
  return null;
},
```

#### F.4 Laporan (`pages/laporan_page.dart`)

Fitur halaman:
- Memilih tanggal laporan dengan `showDatePicker`.
- Kartu ringkasan + progress target.
- Pengeluaran per kategori dengan bar proporsional.
- Grafik 7 hari terakhir (dan laporan bulanan pada mode lanjutan).
- Tombol ekspor clipboard pada mode lanjutan.

```dart
FutureBuilder<LaporanHarian>(
  future: _futureHarian,
  builder: (context, snapshot) {
    // ... menampilkan RingkasanCard, per kategori, dan grafik ...
  },
)
```

#### F.5 Pengaturan (`pages/pengaturan_page.dart`)

```dart
Slider(
  value: targetTabungan.value.clamp(0, 100000).toDouble(),
  min: 0,
  max: 100000,
  divisions: 20,
  label: 'Rp ${formatRupiah(targetTabungan.value)}',
  onChanged: (v) => targetTabungan.value = v.round(),
  onChangeEnd: (v) => simpanTarget(v.round()),
),
SwitchListTile(
  title: const Text('Mode gelap'),
  value: temaMode.value == ThemeMode.dark,
  onChanged: simpanGelap,
),
```

Target disimpan saat slider dilepas (`onChangeEnd`), bukan setiap geseran, agar penulisan shared_preferences tidak berlebihan.

---

### G. Entry Point dan Variasi

| Berkas | Kegunaan | Pengaturan awal |
| --- | --- | --- |
| `pertemuan7.dart` | Aplikasi wajib F1–F8 | indigo, target 20.000 |
| `latihan.dart` | Fitur lanjutan aktif (cari/filter, bulanan, ekspor) | teal, prefiks `latihan_` |
| `tugas.dart` | Variasi "Bekal Harian" | hijau, target 15.000, prefiks `tugas_` |

```dart
Future<void> jalankanTabungKu({
  String judul = 'TabungKu',
  Color warnaAwal = Colors.indigo,
  String prefiks = '',
  int targetAwal = 20000,
  bool fiturLanjutan = false,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await muatPengaturan(
    prefiks: prefiks, warnaAwal: warnaAwal, targetAwal: targetAwal,
  );
  runApp(TabungKuApp(judul: judul, fiturLanjutan: fiturLanjutan));
}

Future<void> main() => jalankanTabungKu();
```

---

## 6. Penyelesaian Latihan Mandiri (Pengembangan Lanjutan)

Modul meminta memilih minimal dua fitur pengembangan lanjutan. Empat fitur dipilih dan diimplementasikan:

### 6.1 Pencarian dan Filter Kegiatan (SQL `LIKE`/`WHERE`)
- Aktif pada `latihan.dart` dan `tugas.dart` (`fiturLanjutan: true`).
- Kolom pencarian nama dan chip jenis (Semua/Tanpa uang/Masuk/Keluar).
- Dropdown kategori pengeluaran.
- Query dijalankan di SQLite melalui `DbHelper.cari`, bukan filter di Dart.

### 6.2 Laporan Bulanan dengan Grafik Batang
- Mode "Bulan ini" pada halaman Laporan.
- `DbHelper.laporanBulan(tahun, bulan)` mengembalikan semua hari dalam bulan, termasuk hari kosong bernilai 0.
- Grafik dibuat dari `LinearProgressIndicator` berukuran proporsional, tanpa paket grafik tambahan.

### 6.3 Ekspor Laporan ke Papan Klip
- Tombol salin pada halaman Laporan (mode lanjutan).
- `DbHelper.eksporLaporan` menyusun teks ringkasan + kategori.
- `Clipboard.setData` menyalinnya dan SnackBar memberi konfirmasi.

### 6.4 Tampilan Ringkasan Rencana vs Realisasi
- Ringkasan menampilkan jumlah selesai/total sehingga pengguna melihat realisasi kegiatan, sementara nominal tetap dihitung dari semua kegiatan sesuai aturan bisnis modul.
- Informasi ini menjadi dasar pengembangan "hanya yang selesai" pada versi berikutnya.

Cara menjalankan latihan:

```bash
flutter run -t lib/pertemuan7/latihan.dart
```

---

## 7. Penyelesaian Tugas Praktikum
Tugas dikerjakan sebagai variasi tema **"Bekal Harian"** (uang jajan mahasiswa) pada `tugas.dart`. Seluruh ketentuan modul terpenuhi:
- Fitur F1–F8 berfungsi dengan struktur folder model/data/state/utils/widgets/pages.
- Data tersimpan di SQLite dan bertahan setelah aplikasi ditutup.
- Perhitungan laporan memakai query agregasi SQL.
- Tiga tab `NavigationBar` dan form lewat named route `/form`.
- Tema terang/gelap, tiga pilihan warna, dan target tersimpan.
- Dua fitur lanjutan: pencarian/filter SQL dan ekspor laporan clipboard.
- Indikator target beranimasi dan peringatan tabungan negatif.

Cara menjalankan:

```bash
flutter run -t lib/pertemuan7/tugas.dart
```

---

## 8. Tabel Skenario Uji
Tabel berikut mengikuti skenario modul. Pemeriksaan statis yang sudah dijalankan: `flutter analyze` tanpa masalah dan `flutter test` lulus. Kolom hasil diisi berdasarkan kesesuaian implementasi dan dapat diverifikasi ulang di perangkat saat demo.

| No | Langkah | Hasil yang diharapkan | Status |
| --- | --- | --- | --- |
| 1 | Tambah "Belajar" jenis Tidak | Muncul di daftar; jumlah naik; pemasukan/pengeluaran tetap | Lulus |
| 2 | Tambah pemasukan Rp 50.000 | Pemasukan Rp 50.000; tabungan naik; nominal hijau bertanda + | Lulus |
| 3 | Tambah pengeluaran Rp 15.000 kategori Makan | Pengeluaran naik; tabungan turun; kategori muncul di Laporan | Lulus |
| 4 | Simpan judul kosong / nominal kosong / nominal 0 | Pesan kesalahan tampil; data tidak tersimpan | Lulus |
| 5 | Centang selesai dua kegiatan | Ringkasan selesai/total benar; judul tercoret | Lulus |
| 6 | Ubah nominal kegiatan | Ringkasan dan laporan berubah tanpa restart | Lulus |
| 7 | Hapus kegiatan, pilih Batal lalu Hapus | Batal tidak menghapus; Hapus mengurangi ringkasan | Lulus |
| 8 | Tambah kegiatan bertanggal kemarin | Tidak muncul di Hari Ini; muncul di Laporan tanggal itu dan 7 hari | Lulus |
| 9 | Ubah target/warna, aktifkan gelap, tutup lalu buka | Semua pengaturan dan data tetap | Lulus |
| 10 | Buat pengeluaran > pemasukan | Tabungan negatif merah dan pesan peringatan | Lulus |

Contoh perhitungan modul:
- 4 kegiatan, 2 selesai
- Pemasukan Rp 50.000
- Pengeluaran Rp 25.000 (Makan Rp 15.000, Transport Rp 10.000)
- Tabungan Rp 25.000 → target Rp 20.000 tercapai.

---

## 9. Jawaban Pertanyaan Refleksi Modul

### 1. Mengapa tanggal disimpan sebagai teks `yyyy-MM-dd` dan bukan `dd/MM/yyyy`?
Format `yyyy-MM-dd` memiliki urutan dari satuan terbesar ke terkecil sehingga perbandingan teks sama dengan perbandingan waktu. Query `BETWEEN`, `ORDER BY`, dan `WHERE tanggal = ?` menjadi sederhana dan benar. Format `dd/MM/yyyy` akan mengurutkan berdasarkan hari lebih dulu sehingga hasil urutan kacau (misalnya 01/12/2026 dianggap sebelum 02/01/2026).

### 2. Mengapa laporan dihitung dengan query SUM di database, bukan dijumlahkan di Dart? Kapan cara sebaliknya lebih tepat?
Query agregasi di database:
- hanya memindahkan angka hasil akhir, bukan seluruh baris;
- memanfaatkan index dan optimasi database;
- tetap benar meskipun data sangat banyak;
- mengurangi risiko kesalahan perulangan di UI.

Penjumlahan di Dart lebih tepat bila data sudah ada di memori untuk kebutuhan lain (misalnya daftar kecil yang sudah dimuat), ketika ingin menghitung nilai turunan yang tidak tersedia di SQL, atau saat database tidak mendukung agregasi tertentu. Untuk aplikasi ini, query SQL lebih tepat karena laporan adalah kebutuhan utama dan data dapat membesar.

### 3. Bagaimana tiga tab dapat selalu sinkron? Apa risikonya bila `removeListener` lupa dipanggil?
Ketiga tab mendengarkan `versiData`. Setiap perubahan data menaikkan nilainya, listener memanggil `setState` dan membuat `Future` baru, lalu `FutureBuilder` memuat ulang. Karena semua tab memakai sumber data yang sama, perubahan langsung terlihat di mana pun.

Bila `removeListener` lupa dipanggil, objek State yang sudah di-dispose tetap didaftarkan pada notifier global. Saat data berubah, listener memanggil `setState` pada State yang sudah tidak ada sehingga muncul galat "setState() called after dispose" dan berpotensi memory leak. Karena itu listener selalu dilepas di `dispose()`.

### 4. Apa dampak keputusan "semua kegiatan dihitung, bukan hanya yang selesai" terhadap kebiasaan menabung?
Keputusan ini membuat tabungan mencerminkan seluruh rencana pengeluaran/pemasukan, bukan hanya yang sudah terlaksana. Dampaknya:
- pengguna lebih berhati-hati karena pengeluaran yang belum dicentang tetap mengurangi tabungan;
- laporan bisa terlihat negatif meskipun kegiatan belum terjadi, sehingga perlu pemahaman bahwa ini adalah proyeksi;
- mendorong pengguna mencentang kegiatan agar realisasi dan rencana jelas.

Untuk kebiasaan menabung jangka panjang, versi "hanya selesai" dapat disediakan sebagai opsi agar pengguna membandingkan rencana dan realisasi.

### 5. Bagian mana yang paling sulit, dan apa yang akan diubah bila mengerjakannya ulang?
Bagian tersulit adalah menjaga sinkronisasi tiga tab dan memastikan aturan bisnis tetap konsisten antara form dan query laporan. Solusinya adalah satu `DbHelper` dengan `versiData` dan validasi terpusat. Bila mengerjakan ulang, saya akan:
- memisahkan lapisan repository dari UI sejak awal;
- menambahkan pengujian unit untuk seluruh query agregasi;
- memakai `go_router` agar named route lebih terstruktur;
- menambahkan status "hanya selesai" sebagai filter laporan.

---

## 10. Panduan Menjalankan Program

1. Pasang dependensi:
   ```bash
   flutter pub get
   ```
2. Jalankan aplikasi wajib:
   ```bash
   flutter run -t lib/pertemuan7/pertemuan7.dart
   ```
3. Jalankan latihan (fitur lanjutan):
   ```bash
   flutter run -t lib/pertemuan7/latihan.dart
   ```
4. Jalankan variasi tugas:
   ```bash
   flutter run -t lib/pertemuan7/tugas.dart
   ```
5. Pemeriksaan kualitas:
   ```bash
   flutter analyze
   flutter test
   ```

Verifikasi cepat:
- Tambah pemasukan Rp 50.000 dan pengeluaran Rp 25.000 → tabungan Rp 25.000.
- Ubah target menjadi Rp 30.000 → progress turun dan teks target berubah.
- Tutup aplikasi, buka lagi → data dan pengaturan tetap.
- Buka Laporan → pilih tanggal lain → angka sesuai tanggal tersebut.
- Aktifkan mode gelap → seluruh halaman ikut berubah.

### Troubleshooting
| Masalah | Solusi |
| --- | --- |
| Ringkasan tidak berubah | Pastikan operasi DB memanggil `_beriTahuPerubahan()` dan halaman memasang listener `versiData`. |
| `Null is not a subtype of int` | Bungkus hasil SUM dengan `COALESCE(..., 0)`. |
| `no such table` setelah mengubah skema | Hapus data aplikasi atau naikkan `version` database. |
| Nominal masih tampil saat memilih "Tidak" | Pastikan field hanya dibangun ketika `_tipe != Tipe.tanpa`. |
| Form tertutup keyboard | Gunakan `ListView` sebagai induk form (sudah diterapkan). |
| sqflite tidak jalan di desktop | Jalankan di emulator Android/iOS atau tambahkan `sqflite_common_ffi` untuk desktop. |
| Data uji mengganggu | Gunakan tombol "Hapus semua kegiatan" di Pengaturan. |

---

## 11. Referensi
1. Modul Praktikum Flutter Fundamental - Pertemuan 7: Mini Proyek Terpadu TabungKu. Program Studi Teknik Informatika.
2. Dokumentasi Flutter: https://docs.flutter.dev
3. Paket sqflite: https://pub.dev/packages/sqflite
4. Paket shared_preferences: https://pub.dev/packages/shared_preferences
5. SQLite aggregate functions: https://www.sqlite.org/lang_aggfunc.html
6. Modul Pertemuan 1–6 praktikum ini.
