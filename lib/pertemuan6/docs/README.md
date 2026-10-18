# Dokumentasi Praktikum Flutter - Pertemuan 6
Tema, Routing dan Navigasi, serta Animasi

## Informasi Praktikum
- Topik Praktikum: Pembuatan tema terang/gelap dan warna tema yang dapat diganti pengguna dengan ThemeData dan ThemeMode, pemakaian nilai tema melalui Theme.of(context), penerapan named routes dan onGenerateRoute beserta pengiriman argumen, navigasi tab bawah dengan NavigationBar dan IndexedStack, serta pembuatan animasi implisit, transisi Hero, dan animasi eksplisit dengan AnimationController.
- Nama Mahasiswa: Dafa Rafi Nurwansyah
- NIM: 20240801157
- Program Studi: Teknik Informatika

---

## 1. Tujuan Pembelajaran
Sesuai dengan modul praktikum pertemuan 6, setelah menyelesaikan praktikum ini mahasiswa diharapkan mampu:
1. Membuat tema terang/gelap dan warna tema yang dapat diganti pengguna dengan ThemeData dan ThemeMode.
2. Memakai nilai tema (Theme.of(context)) alih-alih warna dan gaya yang ditulis manual.
3. Menerapkan named routes, mengirim argumen antar halaman, dan onGenerateRoute.
4. Membuat navigasi tab bawah dengan NavigationBar dan IndexedStack.
5. Membuat animasi implisit (AnimatedContainer, AnimatedSwitcher), transisi Hero, dan animasi eksplisit (AnimationController).

---

## 2. Alat dan Bahan
- Laptop dengan Flutter SDK versi stabil terbaru (versi 3.47.4) beserta Dart.
- Editor kode Visual Studio Code atau Android Studio.
- Emulator Android atau perangkat fisik Android yang terhubung.
- Tidak perlu paket tambahan (hanya memakai `shared_preferences` yang sudah ada untuk latihan menyimpan tema).

---

## 3. Teori Singkat dan Konsep Dasar untuk Orang Awam

### Tema
`ThemeData` menyimpan seluruh gaya aplikasi (warna, tipografi, gaya komponen). Cukup menentukan satu warna dasar (seed color), Material 3 menghasilkan seluruh palet warnanya. `MaterialApp` menerima `theme` (terang), `darkTheme` (gelap), dan `themeMode` (sistem/terang/gelap). Widget membaca tema dengan `Theme.of(context)` sehingga otomatis menyesuaikan saat tema berubah.

### Routing (Navigasi Bernama)
Selain `Navigator.push` langsung, halaman dapat diberi nama sehingga navigasi lebih rapi dan terpusat.

| Method | Fungsi |
| --- | --- |
| `pushNamed(ctx, '/detail', arguments: x)` | Membuka halaman bernama, membawa argumen |
| `pop(ctx)` | Menutup halaman saat ini |
| `pushReplacementNamed(...)` | Mengganti halaman saat ini (tidak bisa kembali) |
| `pushNamedAndRemoveUntil(...)` | Membuka halaman baru sambil menghapus riwayat sebelumnya |

### Animasi

| Jenis | Widget/kelas | Kapan dipakai |
| --- | --- | --- |
| Implisit | AnimatedContainer, AnimatedOpacity, AnimatedSwitcher | Cukup ubah nilai lewat setState; Flutter menganimasikan perubahannya |
| Transisi Hero | Hero | Elemen "terbang" mulus antar dua halaman (tag harus sama) |
| Eksplisit | AnimationController + RotationTransition | Butuh kontrol penuh: ulang, berhenti, urutan, sinkronisasi |

---

## 4. Struktur Berkas Pertemuan 6

Berikut adalah struktur berkas yang terdapat pada folder lib/pertemuan6:
```text
lib/pertemuan6/
├── pertemuan6.dart   # Bagian A–D (tema, named routes & Hero, animasi, navigasi tab bawah)
├── latihan.dart      # Latihan Mandiri 1–5 (tema tersimpan, Drawer, FadeTransition, 404, AnimatedOpacity)
├── tugas.dart        # Tugas Praktikum (Galeri/Katalog Interaktif "Katalog Wisata Nusantara")
├── modul/
│   └── modul-praktikum-flutter-pertemuan-6.pdf
└── docs/
    └── README.md     # Dokumen panduan dan laporan lengkap ini
```

---

## 5. Dokumentasi Kode Lengkap dan Penjelasan

### A. Berkas pertemuan6.dart (Bagian A: Tema Terang/Gelap dan Warna Tema)
Dua `ValueNotifier` global menyimpan pilihan tema; `ListenableBuilder` membangun ulang `MaterialApp` saat salah satunya berubah.

```dart
// Dua ValueNotifier global menyimpan pilihan tema aplikasi.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.indigo);

const pilihanWarna = [Colors.indigo, Colors.teal, Colors.deepOrange, Colors.pink];

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Praktikum 6',
          debugShowCheckedModeBanner: false,
          theme: buatTema(seedColor.value, Brightness.light),
          darkTheme: buatTema(seedColor.value, Brightness.dark),
          themeMode: themeMode.value,
          initialRoute: '/',
          routes: {'/': (_) => const ShellPage()},
          onGenerateRoute: (settings) { /* rute /detail dengan argumen */ },
        );
      },
    );
  }
}
```

```dart
// Tab Pengaturan: saklar mode gelap dan pilihan warna tema
SwitchListTile(
  title: const Text('Mode gelap'),
  value: themeMode.value == ThemeMode.dark,
  onChanged: (v) => themeMode.value = v ? ThemeMode.dark : ThemeMode.light,
),
Wrap(
  spacing: 12,
  children: [
    for (final c in pilihanWarna)
      GestureDetector(
        onTap: () => seedColor.value = c,
        child: CircleAvatar(
          backgroundColor: c,
          child: seedColor.value == c
              ? const Icon(Icons.check, color: Colors.white)
              : null,
        ),
      ),
  ],
),
```

#### Penjelasan Rinci Kode di Atas:
1. `Listenable.merge([themeMode, seedColor])` membuat `MaterialApp` mendengarkan kedua notifier sekaligus.
2. `buatTema` menghasilkan tema terang dan gelap dari warna dasar yang sama sehingga seluruh aplikasi konsisten.
3. Tidak ada warna yang ditulis manual pada widget; semuanya berasal dari tema.

---

### B. Berkas pertemuan6.dart (Bagian B: Named Routes, Argumen, dan Hero)
Daftar item membuka halaman detail memakai `Navigator.pushNamed`, dan ikon "terbang" memakai `Hero` dengan tag yang sama.

```dart
class Item {
  final String nama;
  final IconData ikon;
  final Color warna;
  const Item(this.nama, this.ikon, this.warna);
}

const daftarItem = [
  Item('Flutter', Icons.flutter_dash, Colors.blue),
  Item('Musik', Icons.music_note, Colors.pink),
  Item('Kamera', Icons.camera_alt, Colors.orange),
  Item('Peta', Icons.map, Colors.green),
];

// Rute yang membawa argumen ditangani di onGenerateRoute
onGenerateRoute: (settings) {
  if (settings.name == '/detail') {
    final item = settings.arguments as Item;
    return MaterialPageRoute(
      builder: (_) => DetailPage(item: item),
      settings: settings,
    );
  }
  return null;
},

// Di halaman daftar
Hero(
  tag: 'ikon-${item.nama}',
  child: CircleAvatar(
    backgroundColor: item.warna,
    child: Icon(item.ikon, color: Colors.white),
  ),
),
```

#### Penjelasan Rinci Kode di Atas:
1. `onGenerateRoute` memeriksa `settings.name`, mengambil argumen, dan mengembalikan halaman dengan tipe yang sudah dipastikan (lebih aman daripada `ModalRoute.of(context)`).
2. Kedua `Hero` (di daftar dan di halaman detail) memakai tag yang sama, yaitu `'ikon-${item.nama}'`, agar animasi terbang bekerja dua arah.

---

### C. Berkas pertemuan6.dart (Bagian C: Animasi)
Tab Animasi menampilkan tiga demo: animasi implisit, AnimatedSwitcher, dan animasi eksplisit.

```dart
class _AnimasiTabState extends State<AnimasiTab>
    with SingleTickerProviderStateMixin {
  bool _besar = false;
  int _hitung = 0;
  late final AnimationController _putar;

  @override
  void initState() {
    super.initState();
    _putar = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _putar.dispose(); // wajib agar tidak terjadi kebocoran memori
    super.dispose();
  }
}
```

```dart
// 1. Implisit: AnimatedContainer
AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  curve: Curves.easeInOut,
  width: _besar ? 200 : 100,
  height: 100,
  decoration: BoxDecoration(
    color: _besar ? warna.primary : warna.tertiary,
    borderRadius: BorderRadius.circular(_besar ? 50 : 8),
  ),
),

// 2. Implisit: AnimatedSwitcher (anak harus punya key berbeda)
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
  child: Text('$_hitung', key: ValueKey(_hitung), style: tema.textTheme.displayMedium),
),

// 3. Eksplisit: AnimationController + RotationTransition
Center(
  child: RotationTransition(
    turns: _putar,
    child: Icon(Icons.settings, size: 64, color: warna.primary),
  ),
),
```

#### Penjelasan Rinci Kode di Atas:
1. `SingleTickerProviderStateMixin` menyediakan `vsync` yang dibutuhkan `AnimationController`.
2. `AnimatedSwitcher` membutuhkan `key` yang berbeda pada anaknya agar Flutter mengenali bahwa anak telah berubah dan menjalankan animasi.
3. `_putar.repeat()` membuat ikon berputar terus, dan tombol "Berhenti"/"Putar" mengontrolnya.

---

### D. Berkas pertemuan6.dart (Bagian D: Navigasi Tab Bawah)
`ShellPage` menampung tiga tab, dan `IndexedStack` menjaga state setiap tab tetap hidup saat berpindah.

```dart
class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _halaman = [BerandaTab(), AnimasiTab(), PengaturanTab()];
  static const _judul = ['Beranda', 'Animasi', 'Pengaturan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_index])),
      body: IndexedStack(index: _index, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(icon: Icon(Icons.animation), label: 'Animasi'),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
```

#### Penjelasan Rinci Kode di Atas:
1. `IndexedStack` menumpuk semua halaman dan menampilkan satu sesuai `index`, sehingga posisi gulir dan state tab lain tidak hilang.
2. Tema yang diubah pada tab Pengaturan langsung memengaruhi seluruh aplikasi, termasuk halaman detail.

---

### E. Berkas tugas.dart (Tugas: Katalog Wisata Nusantara)
Aplikasi tugas memiliki tiga tab (Beranda, Favorit, Pengaturan), halaman detail dengan Hero, serta dua jenis animasi (implisit dan eksplisit).

```dart
// Tema tersimpan dengan shared_preferences
Future<void> simpanGelap(bool gelap) async {
  temaMode.value = gelap ? ThemeMode.dark : ThemeMode.light;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('tugas_gelap', gelap);
}

Future<void> simpanWarna(Color warna) async {
  warnaSeed.value = warna;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('tugas_seed', warna.toARGB32());
}
```

```dart
// Halaman detail: animasi implisit + eksplisit
class _DetailWisataPageState extends State<DetailWisataPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _putar;
  bool _lebar = false;

  @override
  void initState() {
    super.initState();
    // Animasi eksplisit: ikon kompas berputar terus-menerus.
    _putar = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    // Animasi implisit: ukuran dan warna kartu berubah saat ditekan.
    return GestureDetector(
      onTap: () => setState(() => _lebar = !_lebar),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: _lebar
              ? tema.colorScheme.primaryContainer
              : tema.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(_lebar ? 24 : 8),
        ),
        child: Text(w.deskripsi),
      ),
    );
    // ... RotationTransition(turns: _putar, child: Icon(Icons.explore))
  }
}
```

#### Penjelasan Rinci Kode di Atas:
1. Tema terang/gelap dan tiga pilihan warna disimpan dengan shared_preferences lalu dimuat pada `main()`.
2. Hero dipakai pada ikon di daftar dan halaman detail dengan tag `'wisata-${nama}'`.
3. Warna dan gaya teks diambil dari `Theme.of(context)` (misalnya `tema.colorScheme.primaryContainer`), bukan ditulis manual.

---

## 6. Penyelesaian Latihan Mandiri
Berikut rincian solusi setiap butir latihan pada modul pertemuan 6:
1. Menyimpan mode gelap dan warna tema dengan shared_preferences lalu memuatnya saat aplikasi dimulai (`WidgetsFlutterBinding.ensureInitialized()` di `main()`).
2. Menambahkan `Drawer` pada `ShellPage` berisi menu untuk berpindah tab (dan tautan untuk mencoba halaman 404).
3. Mengganti transisi halaman detail dengan `PageRouteBuilder` yang memakai `FadeTransition` di dalam `onGenerateRoute`.
4. Menambahkan `onUnknownRoute` yang menampilkan halaman "404 - Halaman tidak ditemukan".
5. Menambahkan demo keempat di `AnimasiTab`, yaitu `AnimatedOpacity` yang memudarkan dan memunculkan sebuah kartu.

---

## 7. Penyelesaian Tugas Praktikum
Aplikasi Galeri/Katalog Interaktif dengan tema "Katalog Tempat Wisata Nusantara" telah diimplementasikan penuh pada berkas `tugas.dart`. Seluruh kriteria tugas terpenuhi:
- Minimal 3 tab memakai NavigationBar (Beranda, Favorit, Pengaturan).
- Named routes dengan argumen untuk halaman detail, dan halaman detail memakai Hero.
- Minimal dua jenis animasi: implisit (AnimatedContainer) dan eksplisit (AnimationController + RotationTransition).
- Pengaturan tema terang/gelap dan tiga pilihan warna yang tersimpan setelah aplikasi ditutup.
- Warna dan gaya teks mengambil dari `Theme.of(context)`.

---

## 8. Jawaban Pertanyaan Refleksi Modul

### Pertanyaan 1: Apa perbedaan animasi implisit dan eksplisit? Kapan memilih masing-masing?
Jawaban:
- Animasi implisit (AnimatedContainer, AnimatedOpacity, AnimatedSwitcher) cukup dengan mengubah nilai di dalam `setState`; Flutter mengurus animasinya secara otomatis. Cocok untuk perubahan sederhana satu arah seperti ukuran, warna, atau opasitas.
- Animasi eksplisit (AnimationController) memberikan kontrol penuh: dapat diulang, dihentikan, diatur urutannya, dan disinkronkan antar beberapa nilai. Cocok ketika animasi perlu berjalan terus-menerus, dikendalikan pengguna, atau memiliki urutan khusus.
Prinsipnya: pilih implisit bila cukup; pilih eksplisit bila butuh kendali.

### Pertanyaan 2: Mengapa dua Hero harus memiliki tag yang sama, dan apa yang terjadi bila tag-nya kembali muncul dua kali di halaman yang sama?
Jawaban:
Hero mencocokkan elemen sumber dan tujuan berdasarkan tag. Tag yang sama pada dua halaman membuat Flutter tahu elemen mana yang harus "terbang" dari halaman asal ke halaman tujuan. Bila ada dua Hero dengan tag yang sama di satu halaman yang sama, Flutter tidak dapat menentukan mana yang harus dianimasikan sehingga memunculkan galat "There are multiple heroes that share the same tag within a subtree". Karena itu setiap Hero harus memiliki tag yang unik dalam satu halaman.

### Pertanyaan 3: Apa keuntungan memakai Theme.of(context) dibanding menulis warna langsung pada widget?
Jawaban:
Dengan `Theme.of(context)`, warna dan gaya otomatis mengikuti tema aktif (terang atau gelap) dan warna dasar yang dipilih pengguna. Bila tema berubah, seluruh widget ikut menyesuaikan tanpa perlu diubah satu per satu. Selain itu kode menjadi konsisten, lebih mudah dirawat, dan menghindarkan tampilan yang sulit dibaca (misalnya teks gelap di latar gelap) karena warna yang ditulis manual tidak ikut mode gelap.

### Pertanyaan 4: Apa perbedaan berpindah tab dengan IndexedStack dan membuka halaman dengan Navigator?
Jawaban:
- `IndexedStack` menampilkan satu tab sambil tetap menyimpan semua tab lain di memori, sehingga posisi gulir dan state setiap tab tetap hidup. Cocok untuk berpindah bagian utama aplikasi tanpa menutup tab lain.
- `Navigator` membuka halaman baru di atas halaman sebelumnya sebagai lapisan terpisah dan menyediakan tombol kembali serta riwayat navigasi. Cocok untuk masuk ke tampilan detail yang lebih dalam dan akan ditutup kembali.

### Pertanyaan 5: Mengapa AnimationController wajib di-dispose?
Jawaban:
`AnimationController` mendaftarkan ticker ke sistem animasi Flutter yang terus memanggil pembaruan setiap frame. Bila controller tidak di-dispose saat widget dihapus, ticker akan terus berjalan dan menahan alokasi memori sehingga terjadi kebocoran memori (memory leak) dan pemborosan kinerja. Karena itu `dispose()` wajib dipanggil pada `dispose()` milik State, seperti terlihat pada `_putar.dispose()`.

---

## 9. Panduan Menjalankan Program Hingga Berhasil

Langkah-langkah menjalankan kode program melalui terminal:

1. Pastikan paket dependensi sudah terpasang:
   ```bash
   flutter pub get
   ```
2. Jalankan aplikasi praktikum utama (Bagian A–D):
   ```bash
   flutter run -t lib/pertemuan6/pertemuan6.dart
   ```
   Verifikasi: saklar mode gelap dan pilihan warna langsung mengubah AppBar dan seluruh aplikasi tanpa restart; mengetuk item membuka halaman detail dengan animasi Hero; tab Animasi menjalankan ketiga demo animasi.
3. Jalankan aplikasi latihan mandiri:
   ```bash
   flutter run -t lib/pertemuan6/latihan.dart
   ```
   Verifikasi: tema tersimpan setelah aplikasi ditutup; Drawer membuka menu berpindah tab; halaman detail bertransisi memudar; menu "Rute tidak dikenal (404)" menampilkan halaman 404; demo AnimatedOpacity bekerja.
4. Jalankan aplikasi tugas Katalog Wisata:
   ```bash
   flutter run -t lib/pertemuan6/tugas.dart
   ```
   Verifikasi: tiga tab bawah berjalan; mengetuk destinasi membuka detail dengan Hero; tombol hati menandai favorit yang muncul di tab Favorit; tema terang/gelap dan warna tema tersimpan setelah aplikasi ditutup.

### Panduan Mengatasi Kendala Umum (Troubleshooting)
- "Could not find a generator for route": nama rute salah ketik, atau belum ditangani di `routes`/`onGenerateRoute`.
- Hero tidak beranimasi: pastikan tag sama di kedua halaman dan unik di halaman yang sama.
- Tema tidak berubah saat saklar digeser: pastikan `MaterialApp` dibungkus `ListenableBuilder` dan nilai diubah lewat `themeMode.value` (bukan variabel biasa).
- Sebagian warna tidak ikut mode gelap: warna ditulis manual; ganti dengan `Theme.of(context).colorScheme`.
- `AnimatedContainer` tidak beranimasi: nilai harus berubah di dalam `setState` dan kedua nilai harus bertipe sama.
- `AnimatedSwitcher` tidak beranimasi: anak harus punya key yang berbeda tiap perubahan (misalnya `ValueKey`).
- Galat vsync / TickerProvider: tambahkan `with SingleTickerProviderStateMixin` pada state class.

---

## 10. Referensi dan Sumber Belajar
1. Modul Praktikum Flutter Fundamental - Pertemuan 6: Tema, Routing dan Navigasi, serta Animasi. Program Studi Teknik Informatika.
2. Tema aplikasi: https://docs.flutter.dev/cookbook/design/themes
3. Navigasi dengan named routes: https://docs.flutter.dev/cookbook/navigation/named-routes
4. Pengantar animasi: https://docs.flutter.dev/ui/animations
5. Hero animations: https://docs.flutter.dev/ui/animations/hero-animations
