# Dokumentasi Praktikum Flutter - Pertemuan 4
Mengambil Data dari REST API (HTTP, Async, dan FutureBuilder)

## Informasi Praktikum
- Topik Praktikum: Pemrograman Asinkron Dart (Future, async, await), Pengambilan Data dari REST API dengan paket http, Penguraian JSON, Pembuatan class model dengan fromJson, serta Penampilan data memakai FutureBuilder lengkap dengan status loading, error, dan tombol coba lagi.
- Nama Mahasiswa: Dafa Rafi Nurwansyah
- NIM: 20240801157
- Program Studi: Teknik Informatika

---

## 1. Tujuan Pembelajaran
Sesuai dengan modul praktikum pertemuan 4, setelah menyelesaikan praktikum ini mahasiswa diharapkan mampu:
1. Menjelaskan pemrograman asinkron di Dart: Future, async, dan await.
2. Mengambil data dari REST API memakai paket http dan menguraikan JSON.
3. Membuat class model dengan konstruktor fromJson.
4. Menampilkan data asinkron dengan FutureBuilder lengkap dengan status loading, error, dan data.
5. Menangani kegagalan jaringan dan menyediakan tombol coba lagi.

---

## 2. Alat dan Bahan
- Laptop dengan Flutter SDK versi stabil terbaru (versi 3.47.4) beserta Dart.
- Editor kode Visual Studio Code atau Android Studio.
- Emulator Android atau perangkat fisik Android yang terhubung.
- Koneksi internet (wajib) karena API yang dipakai adalah JSONPlaceholder (jsonplaceholder.typicode.com).
- Paket dependensi resmi http yang terpasang pada berkas pubspec.yaml.

---

## 3. Teori Singkat dan Konsep Dasar untuk Orang Awam

### Pemrograman Asinkron dan Future
Mengambil data dari internet membutuhkan waktu, sehingga tidak boleh mengunci tampilan layar (UI). Dart menyediakan objek Future, yaitu wadah hasil yang akan tersedia di masa depan. Kata kunci await dipakai untuk menunggu hasil tersebut tanpa membekukan tampilan, dan hanya boleh ditulis di dalam fungsi bertanda async.

### REST API, JSON, dan Status Kode
Aplikasi mengirim permintaan HTTP (misalnya GET) ke sebuah URL lalu menerima respons berformat JSON. Kode status 200 berarti sukses; 404 berarti data tidak ditemukan; 500 berarti kesalahan server.

| Konsep | Fungsi |
| --- | --- |
| `http.get(uri)` | Mengirim permintaan GET, mengembalikan `Future<Response>` |
| `jsonDecode(body)` | Mengubah teks JSON menjadi `Map` / `List` Dart |
| `fromJson` | Konstruktor factory yang mengubah `Map` menjadi objek model |
| `FutureBuilder` | Widget yang membangun UI berdasarkan status sebuah Future |
| `snapshot` | Berisi status (`connectionState`), data (`data`), dan galat (`error`) |

### Mengapa Future Dibuat di initState, Bukan di build?
Metode `build()` dipanggil berulang kali setiap kali tampilan digambar ulang. Bila Future dibuat di dalam `build()`, permintaan HTTP akan terkirim ulang terus-menerus setiap kali layar berubah. Karena itu Future dibuat sekali di `initState()`, lalu disimpan pada variabel state.

---

## 4. Struktur Berkas Pertemuan 4

Berikut adalah struktur berkas yang terdapat pada folder lib/pertemuan4:
```text
lib/pertemuan4/
├── pertemuan4.dart      # Bagian A–E (Future, FutureBuilder, model Pengguna, daftar & detail)
├── latihan.dart         # Latihan Mandiri 1–4 (username, kota, RefreshIndicator, empty state, jumlah)
├── post.dart            # Model Postingan dan Komentar (konstruktor fromJson)
├── post_service.dart    # Lapisan layanan (service) berisi permintaan HTTP dan penguraian JSON
├── tugas.dart           # Tugas Praktikum (Aplikasi Daftar Postingan dan Komentar)
├── modul/
│   └── modul-praktikum-flutter-pertemuan-4.pdf
└── docs/
    └── README.md        # Dokumen panduan dan laporan lengkap ini
```

Catatan: `post.dart` (model), `post_service.dart` (akses data), dan `tugas.dart` (UI) sengaja dipisahkan agar rapi dan sesuai rubrik penilaian.

---

## 5. Dokumentasi Kode Lengkap dan Penjelasan

### A. Berkas pertemuan4.dart (Bagian A–E: Future, FutureBuilder, dan HTTP)
Berkas ini berisi seluruh langkah praktikum dari Bagian A sampai E: simulasi Future tanpa internet, model data Pengguna, fungsi pengambil data dari REST API, halaman daftar memakai FutureBuilder, dan halaman detail.

```dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 4',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const PenggunaPage(),
    );
  }
}

// Bagian A: simulasi data yang butuh 2 detik
Future<String> ambilSalam() async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Halo dari masa depan!';
}

// Model data Pengguna dengan konstruktor fromJson
class Pengguna {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String website;

  const Pengguna({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.website,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String,
    );
  }
}

// Bagian C: fungsi pengambil data dari REST API
Future<List<Pengguna>> ambilPengguna() async {
  final uri = Uri.parse('https://jsonplaceholder.typicode.com/users');
  final response = await http.get(uri).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Gagal memuat data (kode ${response.statusCode})');
  }

  final List<dynamic> data = jsonDecode(response.body);
  return data.map((e) => Pengguna.fromJson(e as Map<String, dynamic>)).toList();
}

// Bagian D: halaman daftar memakai FutureBuilder (loading, error, data)
class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});
  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  late Future<List<Pengguna>> _future;

  @override
  void initState() {
    super.initState();
    _future = ambilPengguna(); // dibuat sekali di initState
  }

  void _muatUlang() {
    setState(() {
      _future = ambilPengguna();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _muatUlang),
        ],
      ),
      body: FutureBuilder<List<Pengguna>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  Text('Terjadi kesalahan:\n${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _muatUlang,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final p = data[i];
              return ListTile(
                leading: CircleAvatar(child: Text(p.name[0])),
                title: Text(p.name),
                subtitle: Text(p.email),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPenggunaPage(pengguna: p),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Bagian E: halaman detail pengguna
class DetailPenggunaPage extends StatelessWidget {
  final Pengguna pengguna;
  const DetailPenggunaPage({super.key, required this.pengguna});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pengguna.name)),
      body: ListView(
        children: [
          ListTile(leading: const Icon(Icons.email), title: Text(pengguna.email)),
          ListTile(leading: const Icon(Icons.phone), title: Text(pengguna.phone)),
          ListTile(leading: const Icon(Icons.language), title: Text(pengguna.website)),
        ],
      ),
    );
  }
}
```

#### Penjelasan Rinci Kode di Atas:
1. `Future<List<Pengguna>> ambilPengguna()`: fungsi asinkron yang mengirim permintaan GET, mengecek kode status, lalu mengubah teks JSON menjadi daftar objek `Pengguna`.
2. `http.get(uri).timeout(...)`: membatasi waktu tunggu 10 detik agar aplikasi tidak menunggu selamanya saat jaringan bermasalah.
3. `throw Exception(...)`: galat dilempar bila status bukan 200, dan galat itu akan ditangkap oleh `snapshot.error` pada `FutureBuilder`.
4. `late Future<List<Pengguna>> _future;` diisi pada `initState()` supaya permintaan hanya terjadi satu kali per pemuatan.
5. `snapshot.connectionState == ConnectionState.waiting`: menampilkan indikator berputar selama data dimuat.
6. `snapshot.hasError`: menampilkan pesan galat beserta tombol "Coba lagi" yang memanggil `_muatUlang()`.

---

### B. Berkas latihan.dart (Latihan Mandiri 1–4)
Berkas ini menambahkan kolom `username` dan kota, menarik-ke-bawah untuk memuat ulang, keadaan kosong, serta jumlah pengguna pada AppBar.

```dart
// Model dengan data bersarang address.city
class Pengguna {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String kota;

  const Pengguna({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.kota,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String,
      kota: (json['address'] as Map<String, dynamic>)['city'] as String,
    );
  }
}

// Di dalam AppBar: menampilkan jumlah pengguna setelah data berhasil dimuat
actions: [
  FutureBuilder<List<Pengguna>>(
    future: _future,
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox.shrink();
      return Center(child: Text('${snapshot.data!.length} pengguna'));
    },
  ),
  IconButton(icon: const Icon(Icons.refresh), onPressed: _muatUlang),
],

// Di dalam body: keadaan kosong dan RefreshIndicator
if (data.isEmpty) return const Center(child: Text('Tidak ada data'));

return RefreshIndicator(
  onRefresh: () async => _muatUlang(),
  child: ListView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    itemCount: data.length,
    itemBuilder: (context, i) {
      final p = data[i];
      return ListTile(
        leading: CircleAvatar(child: Text(p.name[0])),
        title: Text(p.name),
        subtitle: Text('@${p.username} • ${p.kota}'),
      );
    },
  ),
);
```

#### Penjelasan Rinci Kode di Atas:
1. Data bersarang dibaca dengan `(json['address'] as Map<String, dynamic>)['city']`.
2. `RefreshIndicator` membutuhkan `ListView` yang selalu dapat digulir (`AlwaysScrollableScrollPhysics`) agar tarikan tetap terdeteksi saat daftar pendek.
3. Penghitung pada AppBar memakai `FutureBuilder` dengan `_future` yang sama, sehingga tidak perlu permintaan HTTP tambahan.

---

### C. Berkas post.dart dan post_service.dart (Pemisahan Model dan Layanan)
Berkas `post.dart` hanya berisi model, sedangkan `post_service.dart` menangani seluruh permintaan HTTP dan penguraian JSON.

```dart
// post.dart
class Postingan {
  final int userId;
  final int id;
  final String judul;
  final String isi;

  const Postingan({
    required this.userId,
    required this.id,
    required this.judul,
    required this.isi,
  });

  factory Postingan.fromJson(Map<String, dynamic> json) => Postingan(
    userId: json['userId'] as int,
    id: json['id'] as int,
    judul: json['title'] as String,
    isi: json['body'] as String,
  );
}

class Komentar {
  final int postId;
  final int id;
  final String nama;
  final String email;
  final String isi;

  const Komentar({
    required this.postId,
    required this.id,
    required this.nama,
    required this.email,
    required this.isi,
  });

  factory Komentar.fromJson(Map<String, dynamic> json) => Komentar(
    postId: json['postId'] as int,
    id: json['id'] as int,
    nama: json['name'] as String,
    email: json['email'] as String,
    isi: json['body'] as String,
  );
}
```

```dart
// post_service.dart (lapisan layanan)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'post.dart';

const String _baseUrl = 'https://jsonplaceholder.typicode.com';

Future<List<Postingan>> ambilPostingan() async {
  final uri = Uri.parse('$_baseUrl/posts');
  final response = await http.get(uri).timeout(const Duration(seconds: 10));
  if (response.statusCode != 200) {
    throw Exception('Gagal memuat postingan (kode ${response.statusCode})');
  }
  final List<dynamic> data = jsonDecode(response.body);
  return data.map((e) => Postingan.fromJson(e as Map<String, dynamic>)).toList();
}

Future<List<Komentar>> ambilKomentar(int postId) async {
  final uri = Uri.parse('$_baseUrl/posts/$postId/comments');
  final response = await http.get(uri).timeout(const Duration(seconds: 10));
  if (response.statusCode != 200) {
    throw Exception('Gagal memuat komentar (kode ${response.statusCode})');
  }
  final List<dynamic> data = jsonDecode(response.body);
  return data.map((e) => Komentar.fromJson(e as Map<String, dynamic>)).toList();
}
```

#### Penjelasan Rinci Kode di Atas:
1. Pemisahan model, layanan, dan UI memudahkan perawatan kode dan pengujian.
2. `ambilKomentar(int postId)` mengambil komentar berdasarkan ID postingan melalui endpoint `/posts/{id}/comments`.

---

### D. Berkas tugas.dart (Tugas: Aplikasi Daftar Postingan)
Halaman utama menampilkan daftar postingan, sedangkan halaman detail menampilkan isi lengkap beserta daftar komentar dari Future kedua.

```dart
// Halaman detail memakai Future kedua untuk komentar
class _DetailPostinganPageState extends State<DetailPostinganPage> {
  late Future<List<Komentar>> _future;

  @override
  void initState() {
    super.initState();
    _future = ambilKomentar(widget.postingan.id);
  }

  void _muatUlang() {
    setState(() {
      _future = ambilKomentar(widget.postingan.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.postingan;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Postingan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(p.judul, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text('Ditulis oleh pengguna #${p.userId}'),
          const Divider(height: 32),
          Text(p.isi, style: const TextStyle(fontSize: 16, height: 1.5)),
          const Divider(height: 32),
          const Text('Komentar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          FutureBuilder<List<Komentar>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return _TampilanGalat(onCobaLagi: _muatUlang);
              }
              final komentar = snapshot.data!;
              if (komentar.isEmpty) return const Text('Belum ada komentar');
              return Column(
                children: [
                  for (final k in komentar)
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(k.nama[0])),
                        title: Text(k.nama),
                        subtitle: Text('${k.email}\n${k.isi}'),
                        isThreeLine: true,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
```

#### Penjelasan Rinci Kode di Atas:
1. Halaman detail memakai Future terpisah (`ambilKomentar`) sehingga daftar komentar dimuat setelah halaman terbuka.
2. Widget bantu `_TampilanGalat` dipakai ulang di halaman utama maupun detail agar tampilan galat konsisten dan memiliki tombol "Coba lagi".

---

## 6. Penyelesaian Latihan Mandiri
Berikut rincian solusi setiap butir latihan pada modul pertemuan 4:
1. Menambahkan kolom `username` dan `kota` (data bersarang `json['address']['city']`) pada model lalu menampilkannya di halaman detail. Diterapkan pada berkas `latihan.dart`.
2. Membungkus `ListView` dengan `RefreshIndicator` agar daftar dapat ditarik ke bawah untuk memuat ulang. Diterapkan pada `latihan.dart` dan `tugas.dart`.
3. Bila daftar kosong, ditampilkan teks "Tidak ada data" (pada tugas juga "Belum ada komentar").
4. Menambahkan `Text` pada AppBar untuk menampilkan jumlah pengguna setelah data berhasil dimuat.

---

## 7. Penyelesaian Tugas Praktikum
Aplikasi Daftar Postingan telah diimplementasikan penuh pada berkas `tugas.dart`, `post.dart`, dan `post_service.dart`:
- Halaman utama menampilkan daftar postingan (judul dan potongan isi) memakai `FutureBuilder`.
- Mengetuk postingan membuka halaman detail yang menampilkan isi lengkap dan daftar komentar dari endpoint `/posts/{id}/comments` (Future kedua).
- Model `Postingan` dan `Komentar` memiliki konstruktor `fromJson`; kode pengambil data dipisah dari kode UI.
- Status loading dan galat ditangani pada kedua halaman, termasuk tombol "Coba lagi".

---

## 8. Jawaban Pertanyaan Refleksi Modul

### Pertanyaan 1: Apa yang terjadi bila Future dibuat di dalam build() dan bukan di initState()? Mengapa?
Jawaban:
Bila Future dibuat di dalam `build()`, maka setiap kali layar digambar ulang (misalnya karena `setState`, perubahan tema, atau rotasi layar), Future baru akan dibuat dan permintaan HTTP terkirim ulang. Akibatnya jaringan dibebani permintaan berulang, indikator loading muncul terus, dan data bisa berkedip atau bahkan tidak stabil. Karena itu Future dibuat sekali di `initState()` lalu disimpan pada variabel state.

### Pertanyaan 2: Apa perbedaan snapshot.hasError dengan memeriksa response.statusCode? Mengapa keduanya diperlukan?
Jawaban:
- `response.statusCode` memeriksa kode status HTTP dari server (misalnya 404 atau 500). Ini hanya menangani respons yang benar-benar diterima.
- `snapshot.hasError` menangkap seluruh galat pada Future, termasuk galat jaringan seperti `SocketException`, koneksi terputus, timeout, maupun galat penguraian JSON — keadaan di mana server tidak pernah mengirim respons.
Keduanya diperlukan karena statusCode hanya mencakup kegagalan tingkat server, sedangkan hasError mencakup kegagalan tingkat jaringan dan pemrograman.

### Pertanyaan 3: Mengapa data JSON sebaiknya diubah menjadi class model, bukan dipakai langsung sebagai Map?
Jawaban:
Mengubah JSON menjadi class model memberi keamanan tipe (type safety) sehingga salah ketik nama kunci langsung terdeteksi saat kompilasi, memudahkan pelengkapan otomatis (autocomplete) di editor, membuat kode lebih mudah dibaca, serta memusatkan logika penguraian (termasuk data bersarang) di satu tempat sehingga lebih mudah dirawat dan diuji.

### Pertanyaan 4: Mengapa UI wajib menyediakan status loading dan error, bukan hanya status data?
Jawaban:
Karena pengambilan data melalui internet membutuhkan waktu dan bisa gagal. Tanpa status loading, layar akan tampak membeku atau kosong sehingga pengguna mengira aplikasi rusak. Tanpa status error, pengguna tidak tahu apa yang salah dan tidak punya cara memperbaiki (misalnya mencoba lagi). Dengan ketiga status (loading, error, data), aplikasi menjadi jelas, informatif, dan ramah pengguna.

---

## 9. Panduan Menjalankan Program Hingga Berhasil

Langkah-langkah menjalankan kode program melalui terminal:

1. Pastikan paket dependensi http sudah terpasang:
   ```bash
   flutter pub get
   ```
2. Pastikan izin internet sudah ada pada `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```
3. Jalankan aplikasi praktikum utama (Bagian A–E):
   ```bash
   flutter run -t lib/pertemuan4/pertemuan4.dart
   ```
   Verifikasi: indikator loading singkat lalu muncul daftar 10 pengguna; mengetuk pengguna membuka halaman detail.
4. Jalankan aplikasi latihan mandiri:
   ```bash
   flutter run -t lib/pertemuan4/latihan.dart
   ```
   Verifikasi: daftar menampilkan `@username • kota`, jumlah pengguna di AppBar, dapat ditarik ke bawah untuk memuat ulang.
5. Jalankan aplikasi tugas Daftar Postingan:
   ```bash
   flutter run -t lib/pertemuan4/tugas.dart
   ```
   Verifikasi: daftar postingan muncul; mengetuk postingan membuka detail berisi isi lengkap dan komentar.

### Percobaan Penanganan Galat (Bagian F)
- Ubah URL menjadi `/userz` pada `post_service.dart`/`pertemuan4.dart`: akan muncul pesan galat kode 404. Kembalikan URL yang benar lalu tekan "Coba lagi".
- Matikan koneksi internet lalu tekan refresh: muncul galat jaringan. Nyalakan internet kembali dan tekan "Coba lagi".

### Panduan Mengatasi Kendala Umum (Troubleshooting)
- Muncul `SocketException` / `Failed host lookup`: periksa koneksi internet emulator; untuk build release pastikan izin INTERNET sudah ada.
- Paket http tidak ditemukan: jalankan `flutter pub get` lalu restart aplikasi (bukan hot reload).
- Data dimuat ulang setiap layar berubah: pindahkan pembuatan Future ke `initState()`.
- Galat `type 'Null' is not a subtype`: nama kunci JSON tidak cocok atau bernilai null; periksa respons asli di browser.

---

## 10. Referensi dan Sumber Belajar
1. Modul Praktikum Flutter Fundamental - Pertemuan 4: Mengambil Data dari REST API (HTTP, Async, dan FutureBuilder). Program Studi Teknik Informatika.
2. Mengambil data dari internet: https://docs.flutter.dev/cookbook/networking/fetch-data
3. Async dan await di Dart: https://dart.dev/codelabs/async-await
4. Paket http (pub.dev): https://pub.dev/packages/http
5. JSONPlaceholder: https://jsonplaceholder.typicode.com
