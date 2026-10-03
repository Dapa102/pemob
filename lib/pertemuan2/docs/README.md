# Dokumentasi Praktikum Flutter - Pertemuan 2
Tata Letak (Layout), Tampilan Daftar (ListView), dan Navigasi Antar Halaman

## Informasi Praktikum
- Topik Praktikum: Penyusunan Tata Letak Antarmuka, Pemodelan Data Sederhana, Daftar Dinamis (ListView.builder), dan Sistem Navigasi Bertumpuk (Navigator.push dan pop).
- Nama Mahasiswa: Dafa Rafi Nurwansyah
- NIM: 20240801157
- Program Studi: Teknik Informatika

---

## 1. Tujuan Pembelajaran
Sesuai dengan modul praktikum pertemuan 2, setelah menyelesaikan praktikum ini mahasiswa diharapkan mampu:
1. Menyusun antarmuka halaman menggunakan komponen tata letak dasar: Container, Padding, Row, Column, dan Expanded.
2. Memahami arah sumbu tata letak (Main Axis dan Cross Axis) pada komponen Row dan Column.
3. Mengatasi dan mencegah terjadinya masalah tampilan terpotong atau meluap (render overflow) menggunakan Expanded.
4. Membuat pemodelan data terstruktur menggunakan class pada bahasa pemrograman Dart.
5. Menampilkan kumpulan data dalam bentuk daftar yang efisien dan dapat digulir menggunakan ListView.builder dan ListTile.
6. Menerapkan navigasi perpindahan antar halaman dengan mengirimkan objek data menggunakan Navigator.push dan menutup halaman dengan Navigator.pop.

---

## 2. Alat dan Bahan
- Laptop dengan sistem operasi Linux, Windows, atau macOS.
- Flutter SDK versi stabil terbaru beserta Dart.
- Editor kode Visual Studio Code atau Android Studio dengan ekstensi resmi Flutter dan Dart.
- Emulator Android atau ponsel fisik yang telah terhubung dan terverifikasi.
- Proyek praktikum yang telah dikonfigurasi.

---

## 3. Teori Singkat dan Konsep Dasar untuk Orang Awam

### Konsep Tata Letak Antarmuka (Layout)
Di dalam aplikasi mobile, tata letak adalah teknik mengatur letak teks, tombol, dan gambar agar tersusun rapi dan proporsional di berbagai ukuran layar ponsel:
- Container: Komponen pembungkus serbaguna yang dapat diatur tinggi, lebar, warna latar belakang, garis batas, dan kelengkungan sudutnya.
- Padding: Memberikan jarak ruang kosong di sekeliling suatu komponen agar tidak menempel terlalu rapat ke pinggir layar.
- Row: Menyusun komponen secara mendatar dari kiri ke kanan. Arah utamanya (Main Axis) adalah horizontal, sedangkan arah silangnya (Cross Axis) adalah vertikal.
- Column: Menyusun komponen secara menurun dari atas ke bawah. Arah utamanya (Main Axis) adalah vertikal, sedangkan arah silangnya (Cross Axis) adalah horizontal.
- Expanded: Memaksa komponen anak untuk mengambil seluruh sisa ruang kosong yang tersedia pada baris atau kolom, sekaligus mencegah teks panjang meluap keluar dari batas layar.

### Perbedaan Daftar Biasa dan Daftar Pintar (ListView.builder)
Jika kita membuat daftar yang panjang menggunakan ListView biasa, semua item akan langsung dimuat ke dalam memori ponsel sekaligus. Jika ada ratusan data, aplikasi akan menjadi berat dan boros memori.
Dengan menggunakan ListView.builder, Flutter menerapkan konsep daftar pintar (lazy loading). Komponen hanya akan dibuat saat item tersebut muncul atau hampir masuk ke layar ponsel. Begitu item keluar dari layar karena digeser oleh pengguna, memori akan didaur ulang. Ini membuat pengguliran daftar selalu lancar dan hemat memori.

### Cara Kerja Navigasi (Sistem Tumpukan / Stack)
Perpindahan halaman pada Flutter bekerja seperti tumpukan kartu:
- Navigator.push: Meletakkan halaman baru di atas halaman yang sedang aktif. Pengguna akan melihat halaman baru tersebut tampil di layar.
- Navigator.pop: Mengambil dan menyingkirkan halaman paling atas dari tumpukan, sehingga layar kembali menampilkan halaman sebelumnya di bawahnya.

---

## 4. Struktur Berkas Pertemuan 2

Berikut adalah struktur berkas yang terdapat pada folder lib/pertemuan2:
```text
lib/pertemuan2/
├── pertemuan2.dart   # Kode Bagian A (Tata Letak Kartu Profil dengan Row dan Column)
├── daftarmenu.dart   # Kode Aplikasi Katalog Daftar Menu Makanan dan Halaman Detail
├── latihan.dart      # Kode penyelesaian Latihan Mandiri 1 sampai 4
├── tugas.dart        # Kode penyelesaian Tugas Mandiri Aplikasi Daftar Kontak
├── modul/
│   └── modul-praktikum-flutter-pertemuan-2.pdf
└── docs/
    └── README.md     # Dokumen panduan dan laporan lengkap ini
```

---

## 5. Dokumentasi Kode Lengkap dan Penjelasan

### A. Berkas pertemuan2.dart (Tata Letak Kartu Profil)
Berkas ini mendemonstrasikan bagaimana menyusun kartu profil pengguna dengan memadukan Container, dekorasi sudut, Row, Avatar, dan Column.

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pertemuan 2',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Avatar lingkaran di sebelah kiri
              const CircleAvatar(
                radius: 32,
                child: Icon(
                  Icons.person,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              // Kolom teks nama dan NIM di sebelah kanan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Dafa Rafi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('20240801157'),
                ],
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
1. `BoxDecoration`: Memberikan warna latar belakang biru muda lembut (`Colors.blue.shade50`) dan membuat sudut-sudut kartu menjadi tumpul melengkung dengan `BorderRadius.circular(12)`.
2. `Row`: Menyusun komponen foto avatar di kiri dan kumpulan teks di kanan secara horizontal.
3. `CircleAvatar`: Komponen siap pakai untuk membuat gambar atau ikon profil berbentuk lingkaran dengan radius 32 piksel.
4. `Column` dengan `crossAxisAlignment: CrossAxisAlignment.start`: Menyusun nama dan NIM dari atas ke bawah dengan posisi perataan rata kiri yang simetris.

---

### B. Berkas daftarmenu.dart dan latihan.dart (Katalog Menu Makanan dan Navigasi Detail)
Berkas ini memuat model data, fungsi konversi mata uang rupiah, daftar menu yang dapat digulir, serta halaman detail lengkap dengan tombol kembali.

```dart
import 'package:flutter/material.dart';

// Fungsi untuk mengubah angka integer biasa menjadi format rupiah dengan pemisah titik
String formatRupiah(int angka) {
  return angka.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );
}

// Model data makanan
class Makanan {
  final String nama;
  final int harga;
  final String deskripsi;

  const Makanan(
    this.nama,
    this.harga,
    this.deskripsi,
  );
}

// Daftar menu makanan dan minuman lengkap
const daftarMenu = [
  Makanan('Nasi Goreng', 15000, 'Nasi goreng dengan telur dan sayuran yang lezat.'),
  Makanan('Mie Ayam', 12000, 'Mie ayam dengan potongan ayam dan kuah gurih.'),
  Makanan('Es Teh', 4000, 'Minuman teh manis yang menyegarkan.'),
  Makanan('Ayam Bakar', 20000, 'Ayam bakar dengan bumbu khas yang lezat.'),
  Makanan('Sate Ayam', 18000, 'Sate ayam dengan bumbu kacang dan kecap.'),
  Makanan('Bakso', 15000, 'Bakso sapi dengan kuah gurih dan mie.'),
  Makanan('Seblak', 13000, 'Seblak pedas dengan kerupuk dan berbagai topping.'),
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Menu',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const MenuPage(),
    );
  }
}

// Halaman utama daftar menu makanan
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
      ),
      body: ListView.builder(
        itemCount: daftarMenu.length,
        itemBuilder: (context, index) {
          final item = daftarMenu[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.restaurant, size: 32),
              title: Text(
                item.nama,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Rp ${formatRupiah(item.harga)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Berpindah ke Halaman Detail dengan mengirim objek makanan
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(makanan: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Halaman rincian detail makanan
class DetailPage extends StatelessWidget {
  final Makanan makanan;

  const DetailPage({
    super.key,
    required this.makanan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(makanan.nama),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu, size: 80),
              const SizedBox(height: 16),
              Text(
                makanan.nama,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${formatRupiah(makanan.harga)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                makanan.deskripsi,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Menutup halaman detail dan kembali ke daftar
                  Navigator.pop(context);
                },
                child: const Text('Kembali'),
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
1. `formatRupiah(int angka)`: Menggunakan ekspresi reguler (RegExp) untuk mencari setiap kelompok 3 digit angka dan menyisipkan tanda titik pemisah ribuan.
2. `class Makanan`: Struktur cetakan data yang menyimpan atribut nama makanan, harga angka, dan deskripsi penjelasan.
3. `ListView.builder`: Merender daftar makanan secara bertahap saat item masuk ke area pandang layar, menghemat penggunaan memori ponsel.
4. `Navigator.push`: Membuka `DetailPage` sambil menyuntikkan data `item` makanan yang dipilih melalui konstruktor.
5. `Navigator.pop(context)`: Menutup halaman detail dan mengembalikan pengguna ke halaman daftar menu makanan sebelumnya.

---

### C. Berkas tugas.dart (Aplikasi Daftar Kontak Mahasiswa)
Berkas ini merupakan tugas mandiri pertemuan 2 dengan implementasi model Kontak, avatar inisial, dan rincian kontak.

```dart
import 'package:flutter/material.dart';

// Class cetakan data kontak
class Kontak {
  final String nama;
  final String nomorTelepon;
  final String email;

  const Kontak(
    this.nama,
    this.nomorTelepon,
    this.email,
  );
}

// Daftar enam data kontak teman
const daftarKontak = [
  Kontak('Andi Saputra', '081234567890', 'andi@gmail.com'),
  Kontak('Budi Santoso', '082345678901', 'budi@gmail.com'),
  Kontak('Citra Lestari', '083456789012', 'citra@gmail.com'),
  Kontak('Deni Pratama', '084567890123', 'deni@gmail.com'),
  Kontak('Eka Putri', '085678901234', 'eka@gmail.com'),
  Kontak('Fajar Ramadhan', '086789012345', 'fajar@gmail.com'),
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Kontak',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const KontakPage(),
    );
  }
}

// Halaman utama yang menampilkan daftar kontak
class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kontak'),
      ),
      body: ListView.builder(
        itemCount: daftarKontak.length,
        itemBuilder: (context, index) {
          final kontak = daftarKontak[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              // Menampilkan inisial huruf pertama dari nama kontak
              leading: CircleAvatar(
                child: Text(
                  kontak.nama[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                kontak.nama,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(kontak.nomorTelepon),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Berpindah ke Halaman Detail Kontak
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailKontakPage(kontak: kontak),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Halaman detail rincian kontak
class DetailKontakPage extends StatelessWidget {
  final Kontak kontak;

  const DetailKontakPage({
    super.key,
    required this.kontak,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kontak.nama),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar inisial berukuran besar
              CircleAvatar(
                radius: 50,
                child: Text(
                  kontak.nama[0],
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                kontak.nama,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Baris informasi nomor telepon dengan lambang telepon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(kontak.nomorTelepon, style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),
              // Baris informasi email dengan lambang amplop
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(kontak.email, style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Kembali'),
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
1. `CircleAvatar(child: Text(kontak.nama[0]))`: Mengambil karakter pertama dari nama kontak menggunakan indeks `[0]` untuk dijadikan gambar avatar inisial secara dinamis.
2. `ListTile`: Komponen baris standar yang membagi kolom menjadi bagian ikon kiri (leading), judul nama (title), subjudul nomor telepon (subtitle), dan panah kanan (trailing).
3. `DetailKontakPage`: Halaman rincian yang menerima objek `Kontak` secara utuh dan menampilkannya dengan ikon representatif telepon dan email yang rapi.

---

## 6. Penyelesaian Latihan Mandiri
Berikut adalah rincian solusi untuk setiap butir latihan pada modul pertemuan 2:
1. Menambahkan 3 menu baru: Daftar menu telah diperkaya menjadi tujuh varian menu lengkap dan daftar tetap dapat digulir dengan lancar.
2. Menambahkan properti deskripsi: Class Makanan ditambahkan atribut deskripsi dan ditampilkan pada halaman rincian.
3. Mengganti Card dengan Container kustom: Kartu daftar makanan diubah menggunakan Container dengan warna latar biru muda lembut dan radius kelengkungan sudut 16 piksel.
4. Menampilkan format ribuan rupiah: Dibuat fungsi bantu pemformatan teks `formatRupiah()` yang menyisipkan titik ribuan secara otomatis pada harga makanan.

---

## 7. Penyelesaian Tugas Praktikum
Aplikasi Daftar Kontak telah selesai dibangun pada berkas tugas.dart. Aplikasi telah memenuhi seluruh kriteria penilaian modul praktikum: memuat minimal enam data kontak berstruktur class, menampilkan inisial pada avatar lingkaran, dapat berpindah ke halaman rincian saat baris kontak ditekan, dan menyediakan tombol kembali yang berfungsi sempurna.

---

## 8. Jawaban Pertanyaan Refleksi Modul

### Pertanyaan 1: Apa perbedaan ListView biasa dengan ListView.builder?
Jawaban:
ListView biasa langsung membuat dan merender semua widget anaknya ke dalam memori sekaligus pada saat pertama kali dibuka. Metode ini hanya cocok untuk daftar dengan jumlah item yang sedikit dan tetap. Sedangkan ListView.builder menerapkan sistem pembuatan berdasarkan kebutuhan (lazy loading). Komponen anak hanya dibuat ketika posisinya mendekati area layar yang terlihat oleh pengguna, lalu komponen tersebut didaur ulang saat keluar layar. Hal ini sangat menghemat penggunaan memori dan menjaga aplikasi tetap responsif saat menangani ratusan hingga ribuan data.

### Pertanyaan 2: Mengapa Row yang berisi teks panjang dapat menyebabkan overflow, dan bagaimana Expanded membantu?
Jawaban:
Komponen Row memiliki karakteristik ruang horizontal yang tidak terbatas (unbounded width). Jika di dalam Row terdapat komponen teks yang isinya sangat panjang dan melebihi lebar fisik layar ponsel, Flutter tidak mengetahui di mana teks tersebut harus dipotong atau dilipat, sehingga terjadi galat render overflow (ditandai dengan garis loreng kuning-hitam di layar). Widget Expanded membantu dengan cara memberi batasan pasti pada teks tersebut agar hanya menempati sisa lebar ruang yang tersedia pada baris, serta memaksa teks melipat otomatis ke baris baru jika ruang horizontal sudah habis.

### Pertanyaan 3: Bagaimana data dikirim dari halaman daftar ke halaman detail pada praktikum ini?
Jawaban:
Pengiriman data dilakukan melalui metode Constructor Injection (injeksi lewat konstruktor). Pada halaman daftar, saat baris ditekan, objek data yang dipilih disisipkan ke dalam konstruktor halaman tujuan pada saat memanggil Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(makanan: item))). Halaman detail memiliki variabel penampung bertipe data objek tersebut dan menerimanya secara wajib (required this.makanan) melalui konstruktor kelasnya.

---

## 9. Panduan Menjalankan Program Hingga Berhasil

Langkah-langkah menjalankan kode program di komputer lokal melalui terminal:

1. Masuk ke direktori utama proyek melalui terminal:
   ```bash
   cd /home/dafarafi/pemob/praktikum
   ```

2. Jalankan aplikasi contoh tata letak profil mahasiswa:
   ```bash
   flutter run -t lib/pertemuan2/pertemuan2.dart
   ```
   Verifikasi hasil: Layar ponsel akan menampilkan kartu profil berwarna biru muda dengan foto lingkaran di kiri dan teks nama serta NIM tersusun rapi di kanan.

3. Jalankan aplikasi daftar menu makanan dan halaman detail:
   ```bash
   flutter run -t lib/pertemuan2/daftarmenu.dart
   ```
   Verifikasi hasil: Tampilan menampilkan daftar tujuh menu makanan dengan format harga rupiah. Ketuk salah satu menu makanan (misalnya Nasi Goreng). Layar akan berpindah ke halaman detail yang menampilkan penjelasan makanan dan harga. Tekan tombol "Kembali" untuk kembali ke daftar menu.

4. Jalankan aplikasi tugas daftar kontak mahasiswa:
   ```bash
   flutter run -t lib/pertemuan2/tugas.dart
   ```
   Verifikasi hasil: Tampilan menampilkan daftar enam nama kontak dengan inisial huruf di dalam lingkaran. Ketuk salah satu nama kontak untuk membuka halaman profil lengkap dengan nomor telepon dan alamat email. Tekan tombol "Kembali" untuk menutup halaman.

### Panduan Mengatasi Kendala Umum (Troubleshooting)
- Jika muncul garis loreng kuning-hitam di layar (RenderFlex Overflow): Bungkus komponen yang memuat teks atau gambar dengan widget Expanded jika berada di dalam Row atau Column, atau bungkus seluruh halaman dengan SingleChildScrollView jika konten melebihi tinggi layar.
- Jika muncul galat bahwa ListView tidak memiliki batasan tinggi saat dimasukkan ke dalam Column: Bungkus ListView.builder tersebut dengan widget Expanded agar sistem mengetahui batasan tinggi ruang yang tersedia.
- Jika perubahan kode pada daftar data tidak langsung terlihat di layar: Lakukan Hot Restart dengan menekan tombol R huruf besar di jendela terminal pengujian.

---

## 10. Referensi dan Sumber Belajar
1. Modul Praktikum Flutter Fundamental - Pertemuan 2: Layout, ListView, dan Navigasi Antar Halaman. Program Studi Teknik Informatika.
2. Panduan Tata Letak (Layouts) Flutter: https://docs.flutter.dev/ui/layout
3. Panduan Membuat Daftar yang Dapat Digulir (Lists Cookbook): https://docs.flutter.dev/cookbook/lists
4. Panduan Navigasi Antar Halaman (Navigation Basics): https://docs.flutter.dev/cookbook/navigation/navigation-basics
5. Dokumentasi Pengiriman Data Antar Halaman (Passing Data): https://docs.flutter.dev/cookbook/navigation/passing-data
