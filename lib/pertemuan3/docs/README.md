# Dokumentasi Praktikum Flutter - Pertemuan 3
Formulir, Validasi Masukan, dan Manajemen State Menggunakan Provider

## Informasi Praktikum
- Topik Praktikum: Pembuatan Formulir (Form), Validasi Isian Pengguna, Siklus Hidup TextEditingController, dan Manajemen Status Aplikasi Terpusat Menggunakan Paket Provider.
- Nama Mahasiswa: Dafa Rafi Nurwansyah
- NIM: 20240801157
- Program Studi: Teknik Informatika

---

## 1. Tujuan Pembelajaran
Sesuai dengan modul praktikum pertemuan 3, setelah menyelesaikan praktikum ini mahasiswa diharapkan mampu:
1. Memahami siklus hidup formulir Flutter menggunakan komponen Form dan GlobalKey.
2. Membuat komponen masukan teks (TextFormField), menu pilihan (DropdownButtonFormField), dan kotak centang (CheckboxListTile) disertai aturan pemeriksaan kebenaran data (custom validator).
3. Mengelola siklus hidup pengendali teks (TextEditingController) serta mencegah terjadinya kebocoran memori (memory leak) melalui fungsi dispose().
4. Memahami batasan pengelolaan state lokal (setState) dan pentingnya pengelolaan state global (shared state) untuk berbagi data antar halaman yang berbeda.
5. Menerapkan pustaka Provider dengan pola arsitektur ChangeNotifier dan ChangeNotifierProvider.
6. Menguasai perbedaan pemakaian context.watch() untuk merender tampilan antarmuka yang reaktif dan context.read() untuk mengeksekusi aksi pada penanganan event atau tombol.

---

## 2. Alat dan Bahan
- Laptop dengan sistem operasi Linux, Windows, atau macOS.
- Flutter SDK versi stabil terbaru beserta Dart.
- Editor kode Visual Studio Code atau Android Studio.
- Emulator Android atau perangkat fisik Android yang terhubung.
- Paket dependensi resmi provider yang terpasang pada berkas pubspec.yaml.

---

## 3. Teori Singkat dan Konsep Dasar untuk Orang Awam

### Konsep Formulir dan Validasi Masukan
Formulir adalah media yang memungkinkan pengguna memasukkan data ke dalam aplikasi, seperti mengetik nama atau memilih opsi.
Agar data yang dimasukkan tidak salah atau kosong, sistem membutuhkan validasi (aturan pemeriksaan):
- Form dan GlobalKey: Kunci unik yang memberikan akses kepada program untuk memerintahkan semua kotak isian di dalam formulir agar memeriksa datanya masing-masing secara bersamaan melalui perintah formKey.currentState.validate().
- Validator: Fungsi pemeriksa nilai yang diketikkan pengguna. Jika nilai tidak memenuhi syarat (misalnya nama kosong atau email tidak memiliki simbol @), validator mengembalikan pesan teks kesalahan berwarna merah di bawah kotak isian. Jika isian sudah benar, validator mengembalikan nilai null yang berarti valid.
- TextEditingController: Pengendali teks yang bertugas membaca teks yang sedang diketikkan pengguna secara langsung.

### Kapan Menggunakan setState dan Kapan Menggunakan Provider?
- Local State (Ephemeral State): Data yang hanya dibutuhkan oleh satu komponen tampilan tertentu saja dan tidak berpengaruh pada halaman lain. Contohnya: status animasi tombol, teks sementara saat mengetik, atau status kotak centang persetujuan syarat. Untuk kondisi ini, cukup menggunakan setState().
- App State (Global / Shared State): Data yang harus dibagikan dan diperbarui oleh berbagai halaman yang terpisah. Contohnya: daftar keranjang belanja, status login pengguna, atau daftar kontak. Jika hanya mengandalkan setState, data akan sulit dipindahkan antar halaman. Untuk kondisi ini, wajib menggunakan pustaka manajemen state seperti Provider.

### Arsitektur Provider (ChangeNotifier, context.watch, dan context.read)
Provider dapat diibaratkan seperti stasiun pemancar siaran berita:
1. Model (ChangeNotifier): Pusat penyimpanan data. Setiap kali ada perubahan data (seperti menambah atau menghapus barang), model memanggil fungsi notifyListeners() yang bertindak sebagai pengumuman bahwa data telah berubah.
2. ChangeNotifierProvider: Pemancar utama yang membungkus aplikasi agar seluruh halaman dapat mendengar siaran data tersebut.
3. context.watch: Digunakan di dalam pembuatan tampilan layar (metode build) agar widget terus mendengarkan siaran. Begitu data berubah, widget otomatis memperbarui tampilannya.
4. context.read: Digunakan di dalam aksi tombol (seperti onPressed). Tujuannya hanya untuk mengirim perintah (misalnya menambah barang) satu kali saja tanpa perlu mendengarkan siaran pembaruan secara terus-menerus.

---

## 4. Struktur Berkas Pertemuan 3

Berikut adalah struktur berkas yang terdapat pada folder lib/pertemuan3 serta berkas utama aplikasi:
```text
lib/
├── main.dart             # Berkas utama aplikasi yang menjalankan modul Daftar Belanja
└── pertemuan3/
    ├── pertemuan3.dart   # Kode Bagian B (Formulir Pendaftaran Mahasiswa Lengkap dengan Validasi)
    ├── daftartugas.dart  # Kode Bagian D (Dasar Aplikasi Catatan Tugas dengan Provider)
    ├── latihan.dart      # Kode Latihan Mandiri 1 sampai 4 (Catatan Tugas Lanjutan)
    ├── tugas.dart        # Kode Tugas Mandiri (Aplikasi Daftar Belanja Lengkap)
    ├── modul/
    │   └── modul-praktikum-flutter-pertemuan-3.pdf
    └── docs/
        └── README.md     # Dokumen panduan dan laporan lengkap ini
```

---

## 5. Dokumentasi Kode Lengkap dan Penjelasan

### A. Berkas pertemuan3.dart (Formulir Pendaftaran Mahasiswa dengan Validasi)
Berkas ini mengimplementasikan formulir pendaftaran mahasiswa baru dengan validasi nama, email, dropdown jurusan, checkbox ketentuan, dan notifikasi SnackBar.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 3',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const FormPage(),
    );
  }
}

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  // Key unik untuk memvalidasi seluruh field di dalam Form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk membaca nilai input teks
  final _nama = TextEditingController();
  final _email = TextEditingController();

  String? _jurusan;
  bool _setuju = false;

  @override
  void dispose() {
    // Wajib melepas controller saat widget dihapus dari memori
    _nama.dispose();
    _email.dispose();
    super.dispose();
  }

  void _kirim() {
    // Mengecek apakah seluruh isian form telah valid
    if (_formKey.currentState!.validate()) {
      final jurusan = _jurusan ?? '-';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terdaftar: ${_nama.text} ($jurusan)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Pendaftaran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Kolom Input Nama Lengkap
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(
                  labelText: 'Nama lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              // Kolom Input Email dengan validasi simbol @
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || !v.contains('@')) return 'Email tidak valid';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Pilihan Dropdown Jurusan
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Jurusan',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'TI', child: Text('Teknik Informatika')),
                  DropdownMenuItem(value: 'SI', child: Text('Sistem Informasi')),
                  DropdownMenuItem(value: 'TE', child: Text('Teknik Elektro')),
                ],
                onChanged: (v) => setState(() => _jurusan = v),
                validator: (v) => v == null ? 'Pilih jurusan' : null,
              ),

              // Kotak Centang Persetujuan Ketentuan
              CheckboxListTile(
                title: const Text('Saya menyetujui ketentuan'),
                value: _setuju,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) => setState(() => _setuju = v ?? false),
              ),

              // Tombol Daftar (hanya aktif jika _setuju bernilai true)
              ElevatedButton(
                onPressed: _setuju ? _kirim : null,
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Penjelasan Rinci Kode di Atas:
1. `final _formKey = GlobalKey<FormState>()`: Kunci penanda yang menghubungkan widget Form dengan status internalnya sehingga metode `_formKey.currentState!.validate()` dapat memanggil seluruh fungsi validator.
2. `validator: (v) => ...`: Mengembalikan string pesan kesalahan jika data tidak sesuai aturan, atau `null` jika valid.
3. `dispose()`: Membersihkan alokasi memori objek controller saat halaman formulir ditutup agar terhindar dari kebocoran memori (*memory leak*).
4. `onPressed: _setuju ? _kirim : null`: Pengondisian tombol; jika `_setuju` masih bernilai false, nilai properti `onPressed` diisi `null` sehingga tombol otomatis dinonaktifkan (berwarna abu-abu).

---

### B. Berkas daftartugas.dart dan latihan.dart (Catatan Tugas dengan Provider)
Berkas ini mengimplementasikan To-do List dengan state terpusat, fitur hapus tugas selesai massal, dan validasi tambah tugas minimal 3 karakter.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Model entitas Tugas
class Tugas {
  String judul;
  bool selesai;

  Tugas(this.judul, {this.selesai = false});
}

// Model State yang memancarkan notifikasi perubahan data
class TugasModel extends ChangeNotifier {
  final List<Tugas> _items = [];

  List<Tugas> get items => List.unmodifiable(_items);

  // Menghitung jumlah tugas yang selesai
  int get jumlahSelesai => _items.where((t) => t.selesai).length;

  void tambah(String judul) {
    _items.add(Tugas(judul));
    notifyListeners(); // Memberi tahu UI agar menggambar ulang
  }

  void toggle(int index) {
    _items[index].selesai = !_items[index].selesai;
    notifyListeners();
  }

  void hapus(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  // Menyelesaikan Latihan 2: Menghapus semua tugas yang sudah selesai
  void hapusSelesai() {
    _items.removeWhere((tugas) => tugas.selesai);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TugasModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Tugas',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const TugasPage(),
    );
  }
}

// Halaman Daftar Tugas
class TugasPage extends StatelessWidget {
  const TugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch membuat halaman ini otomatis merender ulang saat data berubah
    final model = context.watch<TugasModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tugas (${model.jumlahSelesai}/${model.items.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus Selesai',
            onPressed: model.jumlahSelesai == 0
                ? null
                : () => context.read<TugasModel>().hapusSelesai(),
          ),
        ],
      ),
      body: model.items.isEmpty
          ? const Center(
              child: Text(
                'Belum ada tugas',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: model.items.length,
              itemBuilder: (context, i) {
                final t = model.items[i];
                return ListTile(
                  leading: Checkbox(
                    value: t.selesai,
                    onChanged: (_) => context.read<TugasModel>().toggle(i),
                  ),
                  title: Text(
                    t.judul,
                    style: TextStyle(
                      decoration: t.selesai ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => context.read<TugasModel>().hapus(i),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Halaman Tambah Tugas dengan Validasi (Latihan 1)
class TambahPage extends StatefulWidget {
  const TambahPage({super.key});

  @override
  State<TambahPage> createState() => _TambahPageState();
}

class _TambahPageState extends State<TambahPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      final judul = _controller.text.trim();
      context.read<TugasModel>().tambah(judul);
      Navigator.pop(context);

      // Menampilkan SnackBar (Latihan 3)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas ditambahkan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Judul tugas',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Judul tugas wajib diisi';
                  }
                  if (v.trim().length < 3) {
                    return 'Judul minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _simpan,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Penjelasan Rinci Kode di Atas:
1. `ChangeNotifierProvider`: Ditempatkan pada fungsi `main()` untuk membungkus `MyApp`, sehingga state `TugasModel` dapat diakses dari mana saja.
2. `notifyListeners()`: Dipanggil di akhir setiap operasi penambahan, pengubahan status (toggle), atau penghapusan tugas agar UI yang sedang mengamati segera ter-refresh.
3. `context.watch<TugasModel>()`: Dipasang di metode `build()` pada `TugasPage` untuk mendengarkan perubahan secara terus-menerus.
4. `context.read<TugasModel>()`: Dipanggil di dalam tombol untuk mengeksekusi metode mutasi data tanpa memicu render ulang yang tidak perlu pada tombol tersebut.

---

### C. Berkas tugas.dart dan main.dart (Aplikasi Daftar Belanja Kebutuhan)
Berkas ini merupakan tugas mandiri pertemuan 3 yang memodelkan aplikasi daftar belanja lengkap dengan validasi form angka > 0, dropdown kategori, status belanja, dan arsitektur Provider.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Model entitas Barang Belanjaan
class Barang {
  final String nama;
  final int jumlah;
  final String kategori;
  bool sudahDibeli;

  Barang({
    required this.nama,
    required this.jumlah,
    required this.kategori,
    this.sudahDibeli = false,
  });
}

// Model State Belanja
class BelanjaModel extends ChangeNotifier {
  final List<Barang> _items = [];

  List<Barang> get items => List.unmodifiable(_items);

  // Menghitung barang yang belum dibeli untuk judul AppBar
  int get jumlahBelumDibeli {
    return _items.where((barang) => !barang.sudahDibeli).length;
  }

  void tambahBarang({
    required String nama,
    required int jumlah,
    required String kategori,
  }) {
    _items.add(
      Barang(nama: nama, jumlah: jumlah, kategori: kategori),
    );
    notifyListeners();
  }

  void toggleDibeli(int index) {
    _items[index].sudahDibeli = !_items[index].sudahDibeli;
    notifyListeners();
  }

  void hapusBarang(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BelanjaModel(),
      child: const BelanjaApp(),
    ),
  );
}

class BelanjaApp extends StatelessWidget {
  const BelanjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Belanja',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const DaftarPage(),
    );
  }
}

// Halaman Utama Daftar Belanja
class DaftarPage extends StatelessWidget {
  const DaftarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BelanjaModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Belanja (${model.jumlahBelumDibeli})'),
      ),
      body: model.items.isEmpty
          ? const Center(
              child: Text(
                'Belum ada barang belanjaan',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: model.items.length,
              itemBuilder: (context, index) {
                final barang = model.items[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Checkbox(
                      value: barang.sudahDibeli,
                      onChanged: (_) => context.read<BelanjaModel>().toggleDibeli(index),
                    ),
                    title: Text(
                      barang.nama,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: barang.sudahDibeli
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text('Jumlah: ${barang.jumlah} • Kategori: ${barang.kategori}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => context.read<BelanjaModel>().hapusBarang(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahBarangPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Halaman Form Tambah Barang dengan Validasi Lengkap
class TambahBarangPage extends StatefulWidget {
  const TambahBarangPage({super.key});

  @override
  State<TambahBarangPage> createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  String? _kategori;

  final List<String> _daftarKategori = [
    'Makanan',
    'Minuman',
    'Kebutuhan Rumah',
    'Elektronik',
    'Lainnya',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text.trim();
      final jumlah = int.parse(_jumlahController.text.trim());
      final kategori = _kategori!;

      context.read<BelanjaModel>().tambahBarang(
            nama: nama,
            jumlah: jumlah,
            kategori: kategori,
          );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barang "$nama" berhasil ditambahkan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang Belanja')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama barang wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jumlah wajib diisi';
                  }
                  final jumlah = int.tryParse(value.trim());
                  if (jumlah == null) {
                    return 'Jumlah harus berupa angka';
                  }
                  if (jumlah <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _daftarKategori.map((k) {
                  return DropdownMenuItem(value: k, child: Text(k));
                }).toList(),
                onChanged: (val) => setState(() => _kategori = val),
                validator: (val) => val == null ? 'Pilih kategori barang' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simpan,
                child: const Text('Simpan Barang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 6. Penyelesaian Latihan Mandiri
Berikut adalah rincian solusi untuk setiap butir latihan pada modul pertemuan 3:
1. Validasi TambahPage minimal 3 karakter: Diterapkan TextFormField di dalam Form dengan validator yang memeriksa panjang karakter teks masukan.
2. Penambahan method hapusSelesai() dan tombol AppBar: Ditambahkan fungsi penghapus tugas selesai pada class TugasModel serta tombol aksi Icons.delete_sweep pada bilah AppBar yang otomatis nonaktif saat belum ada tugas yang selesai.
3. Notifikasi SnackBar: Ditambahkan pemanggilan ScaffoldMessenger untuk memunculkan pesan konfirmasi setelah tugas berhasil disimpan ke dalam daftar.
4. Tampilan Empty State: Ditambahkan pengondisian pada tampilan body, jika daftar kosong maka ditampilkan teks "Belum ada tugas" di posisi tengah layar.

---

## 7. Penyelesaian Tugas Praktikum
Aplikasi Daftar Belanja telah berhasil diimplementasikan secara penuh pada berkas tugas.dart dan lib/main.dart. Seluruh kriteria tugas praktikum telah terpenuhi: arsitektur state management menggunakan Provider, sinkronisasi antar halaman, validasi berlapis pada formulir tambah barang, fitur coret teks saat barang dibeli, dan penghitung otomatis barang yang belum dibeli pada bilah judul.

---

## 8. Jawaban Pertanyaan Refleksi Modul

### Pertanyaan 1: Mengapa TextEditingController harus di-dispose()?
Jawaban:
Objek TextEditingController mendaftarkan pemantau (listener) tingkat rendah ke dalam sistem Flutter untuk membaca pengetikan keyboard dan posisi kursor. Jika pengendali teks ini tidak dilepas melalui fungsi dispose() saat halaman ditutup atau widget dihapus dari layar, alokasi memori untuk pengendali dan pemantau tersebut akan tetap tertahan dan tidak dapat dibersihkan oleh sistem. Dalam jangka panjang, hal ini menyebabkan kebocoran memori (memory leak) yang membuat aplikasi menjadi lambat dan berpotensi memicu galat saat aplikasi berjalan.

### Pertanyaan 2: Kapan cukup memakai setState, dan kapan sebaiknya beralih ke Provider?
Jawaban:
- Cukup memakai setState: Ketika mengelola data lokal yang ruang lingkupnya hanya berada di dalam satu halaman atau satu komponen tampilan saja (misalnya status animasi, teks pada formulir saat sedang diketik, atau status centang persetujuan syarat dan ketentuan).
- Beralih ke Provider: Ketika mengelola data bersama yang dibutuhkan atau dimodifikasi oleh berbagai halaman yang terpisah dalam aplikasi (misalnya keranjang belanja, data autentikasi akun pengguna, preferensi tema aplikasi, atau sinkronisasi data antara halaman daftar dengan formulir penambahan data).

### Pertanyaan 3: Apa yang terjadi bila notifyListeners() lupa dipanggil? Mengapa?
Jawaban:
Jika fungsi notifyListeners() lupa dipanggil setelah kita mengubah data pada model, data di dalam memori komputer sebenarnya sudah berubah, namun sistem Flutter tidak mendapatkan pemberitahuan bahwa perubahan data telah terjadi. Akibatnya, widget di layar yang mengamati data tersebut tidak akan menjalankan ulang metode build, sehingga antarmuka layar pengguna (UI) akan tampak membeku (freeze) dan tetap menampilkan data yang lama.

### Pertanyaan 4: Mengapa di dalam onPressed kita memakai context.read, bukan context.watch?
Jawaban:
- context.watch berfungsi untuk mendaftarkan suatu widget sebagai pendengar aktif terhadap perubahan model. Pemanggilan context.watch hanya diizinkan di dalam metode build. Jika dipanggil di dalam fungsi tombol seperti onPressed, sistem Flutter akan memicu pengecualian (exception) karena pendaftaran pendengar tidak boleh dilakukan di luar siklus perenderan tampilan.
- context.read hanya mengambil referensi objek model satu kali pada saat tombol ditekan untuk menjalankan fungsi mutasi data (seperti menambah atau menghapus data) tanpa mendaftarkan tombol tersebut sebagai pendengar perubahan. Ini memastikan operasi berjalan secara efisien dan mencegah perenderan ulang yang tidak perlu pada tombol itu sendiri.

---

## 9. Panduan Menjalankan Program Hingga Berhasil

Langkah-langkah menjalankan kode program di komputer lokal melalui terminal:

1. Pastikan paket dependensi provider sudah terpasang dengan menjalankan perintah:
   ```bash
   flutter pub get
   ```

2. Jalankan aplikasi formulir pendaftaran mahasiswa:
   ```bash
   flutter run -t lib/pertemuan3/pertemuan3.dart
   ```
   Verifikasi pengujian formulir:
   - Coba tekan tombol "Daftar" saat kotak persetujuan belum dicentang: Tombol tidak dapat ditekan (nonaktif).
   - Centang kotak persetujuan, lalu langsung tekan tombol "Daftar" saat kolom nama dan email masih kosong: Muncul teks pesan peringatan merah "Nama wajib diisi" dan "Email tidak valid".
   - Isi nama lengkap, masukkan email yang memuat tanda @, dan pilih jurusan studi: Tekan tombol "Daftar", pesan SnackBar hijau/hitam akan muncul di bagian bawah layar mengonfirmasi keberhasilan pendaftaran.

3. Jalankan aplikasi catatan tugas harian dengan Provider:
   ```bash
   flutter run -t lib/pertemuan3/latihan.dart
   ```
   Verifikasi pengujian tugas:
   - Tekan tombol tambah di kanan bawah untuk membuka halaman penambahan tugas.
   - Ketik tugas baru minimal 3 huruf lalu simpan: Tugas akan langsung muncul pada daftar di halaman utama.
   - Centang kotak tugas: Teks tugas akan tercoret dan angka rasio di bilah atas akan otomatis bertambah (contoh: Tugas 1/1).

4. Jalankan aplikasi daftar belanja lengkap:
   ```bash
   flutter run -t lib/pertemuan3/tugas.dart
   ```
   (Atau cukup jalankan aplikasi utama proyek via `flutter run -t lib/main.dart`).
   Verifikasi pengujian daftar belanja:
   - Perhatikan bilah judul "Daftar Belanja (0)".
   - Tekan tombol tambah di kanan bawah untuk membuka formulir belanja.
   - Masukkan nama barang, isi jumlah angka yang lebih dari 0, dan pilih kategori dari menu pilihan.
   - Tekan simpan: Barang akan otomatis masuk ke daftar belanja dan angka di bilah judul akan terbarui.
   - Centang barang yang telah dibeli: Teks nama barang akan dicoret dan angka penghitung barang yang belum dibeli pada bilah judul akan berkurang secara otomatis.

### Panduan Mengatasi Kendala Umum (Troubleshooting)
- Jika muncul galat "Could not find the correct Provider": Pastikan komponen ChangeNotifierProvider diletakkan di posisi paling atas pohon widget sebelum MaterialApp (di dalam fungsi runApp pada berkas program utama).
- Jika tampilan layar tertutup oleh papan ketik (Keyboard Overflow): Bungkus susunan Column pada formulir dengan komponen SingleChildScrollView agar layar dapat digulir ke atas saat papan ketik muncul.
- Jika setelah menambah data layar tidak berubah: Periksa apakah fungsi notifyListeners() sudah dipanggil di akhir fungsi mutasi data pada class model, dan pastikan halaman daftar menggunakan context.watch.

---

## 10. Referensi dan Sumber Belajar
1. Modul Praktikum Flutter Fundamental - Pertemuan 3: Form, Validasi, dan State Management (Provider). Program Studi Teknik Informatika.
2. Panduan Pembuatan Formulir dan Validasi Flutter: https://docs.flutter.dev/cookbook/forms/validation
3. Panduan Resmi Manajemen State Flutter: https://docs.flutter.dev/data-and-backend/state-mgmt/intro
4. Dokumentasi Paket Resmi Provider (pub.dev): https://pub.dev/packages/provider
5. Panduan Pengelolaan Siklus Hidup TextEditingController: https://api.flutter.dev/flutter/widgets/TextEditingController-class.html
