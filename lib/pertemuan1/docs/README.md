# Dokumentasi Praktikum Flutter - Pertemuan 1
Pengenalan Flutter, Instalasi, dan Pembuatan Aplikasi Pertama

## Informasi Praktikum
- Topik Praktikum: Pengenalan Flutter SDK, Widget Dasar, StatelessWidget, StatefulWidget, dan Interaktivitas Tombol.
- Nama Mahasiswa: Dafa Rafi Nurwansyah
- NIM: 20240801157
- Program Studi: Teknik Informatika

---

## 1. Tujuan Pembelajaran
Sesuai dengan modul praktikum pertemuan 1, setelah menyelesaikan praktikum ini mahasiswa diharapkan mampu:
1. Menjelaskan konsep dasar framework Flutter dan bahasa pemrograman Dart serta perbedaannya dengan pengembangan native.
2. Memasang dan mengonfigurasi Flutter SDK, editor kode, dan emulator atau perangkat fisik Android.
3. Membuat dan menjalankan proyek aplikasi Flutter untuk pertama kali hingga berhasil tampil di layar.
4. Memahami struktur folder proyek Flutter serta hierarki penyusunan tampilan antarmuka (widget tree).
5. Membedakan penggunaan StatelessWidget untuk tampilan statis dan StatefulWidget untuk tampilan interaktif dinamis.
6. Memanfaatkan fitur Hot Reload dan Hot Restart untuk efisiensi pengembangan aplikasi.

---

## 2. Alat dan Bahan
- Laptop dengan sistem operasi Linux, Windows, atau macOS (RAM minimal 8 GB dan ruang penyimpanan memadai).
- Flutter SDK versi stabil terbaru (versi 3.47.4).
- Editor kode Visual Studio Code atau Android Studio dengan ekstensi Flutter dan Dart.
- Perangkat pengujian: Emulator Android atau ponsel fisik Android dengan mode pengembang dan USB Debugging aktif.
- Koneksi internet untuk proses unduh paket dependensi.

---

## 3. Teori Singkat dan Konsep Dasar untuk Orang Awam

### Apa itu Flutter dan Dart?
Flutter adalah peralatan pembuat aplikasi buatan Google. Keunggulan utamanya adalah kemampuan multiplatform, artinya kita cukup menulis kode program satu kali dan hasilnya dapat dijalankan di berbagai sistem operasi seperti Android, iOS, web, dan komputer desktop tanpa harus membuat ulang dari nol.

Dart adalah bahasa pemrograman yang digunakan untuk menulis perintah di dalam Flutter. Dart dirancang agar mudah dibaca, berorientasi objek, dan memiliki sistem keamanan data yang baik sehingga meminimalkan terjadinya eror saat aplikasi berjalan.

### Konsep Widget dan Pohon Tampilan (Widget Tree)
Pada Flutter, semua elemen yang terlihat di layar disebut sebagai Widget. Tombol, teks, gambar, baris judul, hingga susunan tata letak seluruhnya adalah widget. Widget disusun secara bertingkat menyerupai struktur pohon:
- Induk utama aplikasi (MaterialApp) mengatur tema dan dasar navigasi.
- Kerangka halaman (Scaffold) menyediakan area bilah judul atas (AppBar) dan badan halaman (body).
- Di dalam badan halaman, kita dapat meletakkan penyusun posisi seperti Center (penengah) dan Column (penyusun baris dari atas ke bawah).
- Di dalam Column, diletakkan elemen konkret seperti Icon (gambar lambang) dan Text (tulisan).

### Perbedaan Layar Statis (StatelessWidget) dan Layar Dinamis (StatefulWidget)
- StatelessWidget: Digunakan untuk bagian tampilan yang sifatnya tetap atau diam. Tampilannya tidak akan pernah berubah setelah pertama kali digambar di layar, misalnya kartu nama atau teks informasi profil.
- StatefulWidget: Digunakan untuk bagian tampilan yang interaktif atau bisa berubah angkanya, warnanya, atau isinya saat pengguna menyentuh layar. Widget ini memiliki objek State dan fungsi setState(). Fungsi setState() bertindak sebagai pemberitahuan kepada sistem agar menggambar ulang tampilan layar sesuai data terbaru.

### Hot Reload dan Hot Restart
- Hot Reload: Menyuntikkan perubahan kode yang baru saja disimpan langsung ke aplikasi yang sedang berjalan dalam waktu kurang dari satu detik, tanpa mengulang aplikasi dari awal dan tanpa menghilangkan data yang sedang tampil.
- Hot Restart: Memuat ulang seluruh sistem aplikasi dari awal dan mengatur ulang semua data kembali ke kondisi default.

---

## 4. Struktur Berkas Pertemuan 1

Berikut adalah struktur berkas yang terdapat pada folder lib/pertemuan1:
```text
lib/pertemuan1/
├── pertemuan1.dart   # Kode utama praktikum (Aplikasi Counter Interaktif)
├── latihan.dart      # Kode latihan mandiri (Tombol Tambah, Kurang, dan Reset)
├── tugas.dart        # Kode tugas mandiri (Kartu Perkenalan Profil Mahasiswa)
├── modul/
│   └── modul-praktikum-flutter-pertemuan-1.pdf
└── docs/
    └── README.md     # Dokumen panduan dan laporan lengkap ini
```

---

## 5. Dokumentasi Kode Lengkap dan Penjelasan

### A. Berkas pertemuan1.dart dan latihan.dart (Aplikasi Counter Interaktif)
Berkas ini membangun aplikasi penghitung angka yang interaktif, memiliki tombol penambah, pengurang, dan pengatur ulang angka hitungan.

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
      title: 'Pertemuan 1',
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({
    super.key,
    this.appBarTitle = 'Counter Saya',
  });

  final String appBarTitle;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bilah judul atas (AppBar)
      appBar: AppBar(
        title: const Text('Counter Saya'),
        backgroundColor: const Color.fromARGB(255, 247, 175, 67),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Badan halaman (Body) diletakkan di tengah layar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon Flutter Dash
            const Icon(Icons.flutter_dash, size: 80, color: Colors.blue),

            const SizedBox(height: 16),

            // Teks perkenalan nama
            const Text('Halo, nama saya Dafa', style: TextStyle(fontSize: 24)),

            // Teks nomor induk mahasiswa
            const Text('NIM: 20240801157', style: TextStyle(fontSize: 18)),

            const SizedBox(height: 30),

            // Teks angka counter
            Text('$_count', style: const TextStyle(fontSize: 48)),
          ],
        ),
      ),

      // Tiga Tombol Aksi di bagian bawah
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tombol Kurang (-)
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _count--;
                });
              },
              backgroundColor: const Color.fromARGB(255, 247, 175, 67),
              child: const Icon(Icons.remove),
            ),

            const SizedBox(width: 10),

            // Tombol Reset (kembali ke 0)
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _count = 0;
                });
              },
              backgroundColor: const Color.fromARGB(255, 247, 175, 67),
              child: const Icon(Icons.refresh),
            ),

            const SizedBox(width: 10),

            // Tombol Tambah (+)
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _count++;
                });
              },
              backgroundColor: const Color.fromARGB(255, 247, 175, 67),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Penjelasan Rinci Kode di Atas:
1. `void main()`: Titik masuk utama aplikasi saat pertama kali dijalankan oleh sistem operasi. Perintah `runApp(const MyApp())` bertugas memasang widget induk ke layar.
2. `class MyApp extends StatelessWidget`: Komponen pembungkus utama aplikasi yang mengembalikan `MaterialApp`. `home: const CounterPage()` menetapkan bahwa halaman pertama yang dibuka adalah halaman hitungan.
3. `class CounterPage extends StatefulWidget`: Komponen dinamis yang membutuhkan pengelolaan status (state). Di sini dideklarasikan `createState()` yang menghubungkan widget dengan class pengelola tampilannya.
4. `class _CounterPageState extends State<CounterPage>`:
   - Variabel `int _count = 0`: Menyimpan angka hitungan awal.
   - `Scaffold`: Kerangka tampilan standar Android yang menyediakan slot untuk `appBar`, `body`, dan `floatingActionButton`.
   - `AppBar`: Bagian atas layar dengan warna latar oranye hangat (`Color.fromARGB(255, 247, 175, 67)`) dan teks tebal "Counter Saya".
   - `Center` dan `Column`: Menata seluruh anak tampilan secara simetris di tengah layar dari atas ke bawah.
   - `Icon(Icons.flutter_dash)`: Menampilkan maskot burung Flutter berwarna biru.
   - `Text('$_count')`: Menampilkan isi variabel angka secara dinamis ke layar.
   - `FloatingActionButton`: Tiga tombol aksi bulat yang dibungkus dalam `Row`. Pemanggilan fungsi `setState()` di setiap penekanan tombol memastikan sistem Flutter langsung menggambar ulang angka terbaru ke layar ponsel.

---

### B. Berkas tugas.dart (Aplikasi Kartu Perkenalan Profil)
Berkas ini membangun kartu perkenalan profil mahasiswa yang bersih dan rapi.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const KartuPerkenalanApp());
}

class KartuPerkenalanApp extends StatelessWidget {
  const KartuPerkenalanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Kartu Perkenalan'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              // Foto atau Ikon Profil
              Icon(
                Icons.account_circle,
                size: 120,
              ),

              SizedBox(height: 20),

              // Nama Mahasiswa
              Text(
                'Dafa Rafi Nurwansyah',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              // NIM Mahasiswa
              Text(
                'NIM: 20240801157',
                style: TextStyle(fontSize: 18),
              ),

              SizedBox(height: 10),

              // Jurusan
              Text(
                'Teknik Informatika',
                style: TextStyle(fontSize: 18),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Penjelasan Rinci Kode di Atas:
1. `class KartuPerkenalanApp extends StatelessWidget`: Menggunakan komponen statis karena tampilan profil bersifat tetap dan tidak membutuhkan pembaruan nilai atau interaksi hitungan dinamis.
2. `Icon(Icons.account_circle, size: 120)`: Menampilkan lambang avatar lingkaran berukuran besar di bagian atas badan layar.
3. `Text('Dafa Rafi Nurwansyah')`: Menampilkan nama lengkap dengan properti `fontWeight: FontWeight.bold` agar tercetak tebal dan menonjol.
4. `SizedBox(height: ...)`: Memberikan jarak spasi vertikal antar baris agar informasi tidak bertumpuk dan mudah dibaca.

---

## 6. Penyelesaian Latihan Mandiri
Berikut adalah rincian solusi kode untuk setiap butir latihan pada modul pertemuan 1:
1. Mengubah warna AppBar dan warna teks:
   ```dart
   backgroundColor: const Color.fromARGB(255, 247, 175, 67),
   titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
   ```
2. Menambahkan tombol Icons.remove untuk mengurangi angka:
   ```dart
   FloatingActionButton(
     onPressed: () => setState(() => _count--),
     child: const Icon(Icons.remove),
   )
   ```
3. Menambahkan tombol reset yang mengembalikan angka ke 0:
   ```dart
   FloatingActionButton(
     onPressed: () => setState(() => _count = 0),
     child: const Icon(Icons.refresh),
   )
   ```
4. Mencegah angka menjadi negatif:
   ```dart
   onPressed: () {
     if (_count > 0) {
       setState(() => _count--);
     }
   }
   ```

---

## 7. Penyelesaian Tugas Praktikum
Tugas mandiri membuat aplikasi Kartu Perkenalan telah diimplementasikan secara utuh pada berkas tugas.dart. Tampilan menyajikan kartu profil mahasiswa yang simetris di tengah layar, memuat foto ikon lingkaran, nama lengkap, NIM, dan program studi sesuai kriteria modul praktikum.

---

## 8. Jawaban Pertanyaan Refleksi Modul

### Pertanyaan 1: Apa perbedaan StatelessWidget dan StatefulWidget?
Jawaban:
- StatelessWidget adalah komponen tampilan yang tidak memiliki data internal yang berubah selama aplikasi berjalan. Sekali dibuat dan ditampilkan, tampilannya akan selalu sama persis. Cocok untuk teks judul, logo, atau kartu profil statis.
- StatefulWidget adalah komponen tampilan yang menyimpan data dinamis yang dapat berubah sewaktu-waktu akibat adanya aksi pengguna seperti mengetik, mencentang, atau menekan tombol. Pembaruan data pada StatefulWidget ditangani melalui objek State.

### Pertanyaan 2: Mengapa perubahan variabel _count perlu dibungkus setState()?
Jawaban:
Di dalam sistem Flutter, mengubah nilai variabel saja hanya akan mengubah data di memori komputer, tetapi sistem tidak tahu bahwa layar perlu digambar ulang. Dengan membungkus perubahan variabel di dalam fungsi setState(), kita mengirimkan sinyal kepada Flutter framework bahwa data telah diperbarui, sehingga framework akan langsung menjalankan ulang method pembuat tampilan (build) untuk menampilkan angka terbaru di layar ponsel.

### Pertanyaan 3: Apa keuntungan Hot Reload dibanding Rebuild penuh (Full Restart)?
Jawaban:
- Kecepatan Eksekusi: Hot Reload membutuhkan waktu kurang dari 1 detik karena hanya mengompilasi berkas kode yang baru diubah, sedangkan Full Restart membutuhkan waktu jauh lebih lama karena memuat ulang seluruh sistem dari awal.
- Mempertahankan Data (State Preservation): Hot Reload tidak menghapus data yang sedang dibuka atau diisi pada layar, misalnya angka counter yang sedang berjalan tidak akan kembali ke angka nol, sehingga memudahkan pengembang saat menyempurnakan tampilan antarmuka.

---

## 9. Panduan Menjalankan Program Hingga Berhasil

Langkah-langkah menjalankan kode program di komputer lokal melalui terminal:

1. Buka aplikasi terminal atau terminal terintegrasi pada editor kode di folder proyek:
   ```bash
   cd /home/dafarafi/pemob/praktikum
   ```

2. Pastikan perangkat emulator atau ponsel Android sudah tersambung dan terdeteksi dengan mengetik:
   ```bash
   flutter devices
   ```

3. Jalankan aplikasi latihan counter interaktif:
   ```bash
   flutter run -t lib/pertemuan1/pertemuan1.dart
   ```
   Tunggu hingga proses kompilasi selesai. Aplikasi akan terbuka di layar perangkat, menampilkan logo Flutter Dash, teks nama mahasiswa, dan tiga tombol counter di bagian bawah. Tekan tombol tambah untuk memastikan angka bertambah, tekan tombol kurang untuk mengurangi, dan tekan tombol putar balik untuk mengembalikan angka ke nol.

4. Jalankan aplikasi tugas kartu perkenalan profil mahasiswa:
   ```bash
   flutter run -t lib/pertemuan1/tugas.dart
   ```
   Aplikasi akan terbuka dan menampilkan kartu profil perkenalan mahasiswa di tengah layar dengan rapi.

### Panduan Mengatasi Kendala Umum (Troubleshooting)
- Jika muncul pesan error bahwa perintah flutter tidak dikenali: Pastikan lokasi folder flutter/bin sudah dimasukkan ke dalam PATH sistem operasi Anda, lalu buka ulang jendela terminal.
- Jika emulator terasa lambat: Pastikan fitur virtualisasi perangkat keras (Hardware Virtualization / VT-x atau AMD-V) telah aktif pada pengaturan BIOS komputer Anda.
- Jika perangkat fisik tidak terdeteksi: Pastikan fitur USB Debugging pada opsi pengembang di ponsel Anda sudah dinyalakan dan izinkan koneksi komputer saat jendela konfirmasi muncul di ponsel.

---

## 10. Referensi dan Sumber Belajar
1. Modul Praktikum Flutter Fundamental - Pertemuan 1: Pengenalan Flutter, Instalasi, dan Aplikasi Pertama. Program Studi Teknik Informatika.
2. Dokumentasi Resmi Flutter: https://docs.flutter.dev
3. Tur Bahasa Pemrograman Dart (Dart Language Tour): https://dart.dev/language
4. Katalog Widget Resmi Flutter: https://docs.flutter.dev/ui/widgets
5. Dokumentasi State Management Dasar Flutter: https://docs.flutter.dev/development/data-and-backend/state-mgmt/ephemeral-vs-app
