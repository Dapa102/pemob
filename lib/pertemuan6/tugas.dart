import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Tugas Pertemuan 6: Aplikasi Galeri/Katalog Interaktif
// "Katalog Tempat Wisata Nusantara" dengan ketentuan:
// - Minimal 3 tab memakai NavigationBar (Beranda, Favorit, Pengaturan).
// - Named routes dengan argumen untuk halaman detail, dan Hero.
// - Minimal dua jenis animasi: implisit (AnimatedContainer) dan eksplisit
//   (AnimationController + RotationTransition).
// - Pengaturan tema terang/gelap dan 3 pilihan warna, tersimpan permanen.
// - Warna dan gaya teks diambil dari Theme.of(context).

// ---------- PENGATURAN TEMA (disimpan dengan shared_preferences) ----------
final temaMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final warnaSeed = ValueNotifier<Color>(Colors.indigo);

const pilihanWarna = [Colors.indigo, Colors.teal, Colors.deepOrange];

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

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

// ---------- FAVORIT (state global sederhana) ----------
final favorit = ValueNotifier<Set<String>>(<String>{});

void toggleFavorit(String nama) {
  final s = Set<String>.from(favorit.value);
  if (!s.add(nama)) s.remove(nama);
  favorit.value = s;
}

// ---------- MODEL ----------
class Wisata {
  final String nama;
  final String lokasi;
  final String deskripsi;
  final IconData ikon;
  final Color aksen;

  const Wisata({
    required this.nama,
    required this.lokasi,
    required this.deskripsi,
    required this.ikon,
    required this.aksen,
  });
}

const daftarWisata = [
  Wisata(
    nama: 'Candi Borobudur',
    lokasi: 'Magelang, Jawa Tengah',
    deskripsi:
        'Candi Buddha terbesar di dunia yang dibangun pada abad ke-9. '
        'Terkenal dengan stupa bertingkat dan relief yang indah.',
    ikon: Icons.temple_buddhist,
    aksen: Colors.orange,
  ),
  Wisata(
    nama: 'Danau Toba',
    lokasi: 'Sumatera Utara',
    deskripsi:
        'Danau vulkanik terbesar di Asia Tenggara dengan Pulau Samosir '
        'di tengahnya dan pemandangan yang menakjubkan.',
    ikon: Icons.water,
    aksen: Colors.blue,
  ),
  Wisata(
    nama: 'Raja Ampat',
    lokasi: 'Papua Barat',
    deskripsi:
        'Kepulauan dengan keanekaragaman hayati laut terkaya di dunia, '
        'cocok untuk menyelam dan menikmati terumbu karang.',
    ikon: Icons.scuba_diving,
    aksen: Colors.teal,
  ),
  Wisata(
    nama: 'Gunung Bromo',
    lokasi: 'Jawa Timur',
    deskripsi:
        'Gunung berapi aktif yang terkenal dengan pemandangan matahari '
        'terbit dan lautan pasir yang luas.',
    ikon: Icons.landscape,
    aksen: Colors.deepOrange,
  ),
  Wisata(
    nama: 'Tanah Lot',
    lokasi: 'Bali',
    deskripsi:
        'Pura di atas batu karang yang menjadi ikon wisata Bali, '
        'sangat indah saat matahari terbenam.',
    ikon: Icons.beach_access,
    aksen: Colors.green,
  ),
];

// ---------- APLIKASI ----------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  temaMode.value = (prefs.getBool('tugas_gelap') ?? false)
      ? ThemeMode.dark
      : ThemeMode.light;
  warnaSeed.value = Color(
    prefs.getInt('tugas_seed') ?? Colors.indigo.toARGB32(),
  );
  runApp(const GaleriApp());
}

class GaleriApp extends StatelessWidget {
  const GaleriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([temaMode, warnaSeed]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Katalog Wisata Nusantara',
          debugShowCheckedModeBanner: false,
          theme: buatTema(warnaSeed.value, Brightness.light),
          darkTheme: buatTema(warnaSeed.value, Brightness.dark),
          themeMode: temaMode.value,
          initialRoute: '/',
          routes: {'/': (_) => const ShellPage()},
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final wisata = settings.arguments as Wisata;
              return MaterialPageRoute(
                builder: (_) => DetailWisataPage(wisata: wisata),
                settings: settings,
              );
            }
            return null;
          },
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('404')),
              body: const Center(child: Text('Halaman tidak ditemukan')),
            ),
          ),
        );
      },
    );
  }
}

// ---------- TAB 1: BERANDA ----------
class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jelajahi Keindahan Indonesia',
                  style: tema.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Temukan dan simpan tempat wisata favoritmu.',
                  style: tema.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final w in daftarWisata) DaftarWisataTile(wisata: w),
      ],
    );
  }
}

// ---------- TAB 2: FAVORIT ----------
class FavoritTab extends StatelessWidget {
  const FavoritTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favorit,
      builder: (context, setFavorit, _) {
        if (setFavorit.isEmpty) {
          return const Center(child: Text('Belum ada wisata favorit'));
        }
        final data = daftarWisata
            .where((w) => setFavorit.contains(w.nama))
            .toList();
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [for (final w in data) DaftarWisataTile(wisata: w)],
        );
      },
    );
  }
}

// Kartu daftar yang dipakai oleh tab Beranda dan Favorit
class DaftarWisataTile extends StatelessWidget {
  final Wisata wisata;
  const DaftarWisataTile({super.key, required this.wisata});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Hero(
          tag: 'wisata-${wisata.nama}',
          child: CircleAvatar(
            backgroundColor: wisata.aksen,
            child: Icon(wisata.ikon, color: Colors.white),
          ),
        ),
        title: Text(wisata.nama),
        subtitle: Text(wisata.lokasi),
        trailing: ValueListenableBuilder<Set<String>>(
          valueListenable: favorit,
          builder: (context, setFavorit, _) {
            final disukai = setFavorit.contains(wisata.nama);
            return IconButton(
              icon: Icon(disukai ? Icons.favorite : Icons.favorite_border),
              onPressed: () => toggleFavorit(wisata.nama),
            );
          },
        ),
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: wisata);
        },
      ),
    );
  }
}

// ---------- TAB 3: PENGATURAN ----------
class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([temaMode, warnaSeed]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Mode gelap'),
              subtitle: const Text('Tersimpan setelah aplikasi ditutup'),
              value: temaMode.value == ThemeMode.dark,
              onChanged: simpanGelap,
            ),
            const SizedBox(height: 12),
            Text('Warna tema', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              children: [
                for (final c in pilihanWarna)
                  GestureDetector(
                    onTap: () => simpanWarna(c),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: c,
                      child: warnaSeed.value == c
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ---------- HALAMAN DETAIL (Hero + Animasi) ----------
class DetailWisataPage extends StatefulWidget {
  final Wisata wisata;
  const DetailWisataPage({super.key, required this.wisata});

  @override
  State<DetailWisataPage> createState() => _DetailWisataPageState();
}

class _DetailWisataPageState extends State<DetailWisataPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _putar;
  bool _lebar = false;

  @override
  void initState() {
    super.initState();
    // Animasi eksplisit: ikon kompas berputar terus-menerus.
    _putar = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _putar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final w = widget.wisata;

    return Scaffold(
      appBar: AppBar(
        title: Text(w.nama),
        actions: [
          ValueListenableBuilder<Set<String>>(
            valueListenable: favorit,
            builder: (context, setFavorit, _) {
              final disukai = setFavorit.contains(w.nama);
              return IconButton(
                icon: Icon(disukai ? Icons.favorite : Icons.favorite_border),
                onPressed: () => toggleFavorit(w.nama),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Hero(
              tag: 'wisata-${w.nama}',
              child: CircleAvatar(
                radius: 64,
                backgroundColor: w.aksen,
                child: Icon(w.ikon, size: 64, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            w.nama,
            textAlign: TextAlign.center,
            style: tema.textTheme.headlineSmall,
          ),
          Text(
            w.lokasi,
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Animasi implisit: ukuran dan warna kartu berubah saat ditekan.
          GestureDetector(
            onTap: () => setState(() => _lebar = !_lebar),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: double.infinity,
              padding: EdgeInsets.all(_lebar ? 24 : 12),
              decoration: BoxDecoration(
                color: _lebar
                    ? tema.colorScheme.primaryContainer
                    : tema.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(_lebar ? 24 : 8),
              ),
              child: Text(
                w.deskripsi,
                style: tema.textTheme.bodyLarge?.copyWith(
                  color: _lebar
                      ? tema.colorScheme.onPrimaryContainer
                      : tema.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Animasi eksplisit: ikon kompas berputar.
          Center(
            child: RotationTransition(
              turns: _putar,
              child: Icon(
                Icons.explore,
                size: 56,
                color: tema.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Ketuk kartu di atas untuk mengubah bentuknya',
              style: tema.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- SHELL: NAVIGASI TAB BAWAH ----------
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _halaman = [BerandaTab(), FavoritTab(), PengaturanTab()];
  static const _judul = ['Katalog Wisata', 'Favorit', 'Pengaturan'];

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
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
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
