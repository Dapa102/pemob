import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Latihan Mandiri Pertemuan 6:
// 1. Menyimpan mode gelap dan warna tema dengan shared_preferences.
// 2. Menambahkan Drawer pada ShellPage untuk berpindah tab.
// 3. Transisi halaman detail memakai PageRouteBuilder + FadeTransition.
// 4. onUnknownRoute menampilkan halaman "404 - Halaman tidak ditemukan".
// 5. Demo keempat pada AnimasiTab: AnimatedOpacity.

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.indigo);

const pilihanWarna = [
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.pink,
];

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

// Latihan 1: menyimpan pilihan tema ke penyimpanan lokal
Future<void> simpanGelap(bool gelap) async {
  themeMode.value = gelap ? ThemeMode.dark : ThemeMode.light;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('gelap', gelap);
}

Future<void> simpanWarna(Color warna) async {
  seedColor.value = warna;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('seed', warna.toARGB32());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  themeMode.value = (prefs.getBool('gelap') ?? false)
      ? ThemeMode.dark
      : ThemeMode.light;
  seedColor.value = Color(prefs.getInt('seed') ?? Colors.indigo.toARGB32());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Praktikum 6 - Latihan',
          debugShowCheckedModeBanner: false,
          theme: buatTema(seedColor.value, Brightness.light),
          darkTheme: buatTema(seedColor.value, Brightness.dark),
          themeMode: themeMode.value,
          initialRoute: '/',
          routes: {'/': (_) => const ShellPage()},
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final item = settings.arguments as Item;
              // Latihan 3: transisi memudar memakai PageRouteBuilder + FadeTransition
              return PageRouteBuilder(
                settings: settings,
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (_, _, _) => DetailPage(item: item),
                transitionsBuilder: (_, animation, _, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              );
            }
            return null;
          },
          // Latihan 4: halaman 404 untuk rute yang tidak dikenal
          onUnknownRoute: (settings) => MaterialPageRoute(
            settings: settings,
            builder: (_) =>
                HalamanTidakDitemukanPage(namaRute: settings.name ?? '-'),
          ),
        );
      },
    );
  }
}

// Halaman 404
class HalamanTidakDitemukanPage extends StatelessWidget {
  final String namaRute;
  const HalamanTidakDitemukanPage({super.key, required this.namaRute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 72),
              const SizedBox(height: 16),
              Text(
                '404 - Halaman tidak ditemukan',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Rute "$namaRute" tidak terdaftar.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (_) => false,
                ),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Mode gelap'),
              value: themeMode.value == ThemeMode.dark,
              onChanged: simpanGelap,
            ),
            const SizedBox(height: 8),
            Text('Warna tema', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                for (final c in pilihanWarna)
                  GestureDetector(
                    onTap: () => simpanWarna(c),
                    child: CircleAvatar(
                      backgroundColor: c,
                      child: seedColor.value == c
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

class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: daftarItem.length,
      itemBuilder: (context, i) {
        final item = daftarItem[i];
        return ListTile(
          leading: Hero(
            tag: 'ikon-${item.nama}',
            child: CircleAvatar(
              backgroundColor: item.warna,
              child: Icon(item.ikon, color: Colors.white),
            ),
          ),
          title: Text(item.nama),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, '/detail', arguments: item);
          },
        );
      },
    );
  }
}

class DetailPage extends StatelessWidget {
  final Item item;
  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(item.nama)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'ikon-${item.nama}',
              child: CircleAvatar(
                radius: 64,
                backgroundColor: item.warna,
                child: Icon(item.ikon, size: 64, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(item.nama, style: tema.textTheme.headlineMedium),
            Text('Detail untuk ${item.nama}', style: tema.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class AnimasiTab extends StatefulWidget {
  const AnimasiTab({super.key});

  @override
  State<AnimasiTab> createState() => _AnimasiTabState();
}

class _AnimasiTabState extends State<AnimasiTab>
    with SingleTickerProviderStateMixin {
  bool _besar = false;
  int _hitung = 0;
  bool _tampil = true; // Latihan 5: status untuk AnimatedOpacity
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
    _putar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('1. AnimatedContainer', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: _besar ? 200 : 100,
            height: 100,
            decoration: BoxDecoration(
              color: _besar ? warna.primary : warna.tertiary,
              borderRadius: BorderRadius.circular(_besar ? 50 : 8),
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _besar = !_besar),
          child: const Text('Ubah bentuk'),
        ),
        const Divider(),
        Text('2. AnimatedSwitcher', style: tema.textTheme.titleMedium),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) {
              return ScaleTransition(scale: anim, child: child);
            },
            child: Text(
              '$_hitung',
              key: ValueKey(_hitung),
              style: tema.textTheme.displayMedium,
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _hitung++),
          child: const Text('Tambah'),
        ),
        const Divider(),
        Text('3. AnimationController', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        Center(
          child: RotationTransition(
            turns: _putar,
            child: Icon(Icons.settings, size: 64, color: warna.primary),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_putar.isAnimating) {
              _putar.stop();
            } else {
              _putar.repeat();
            }
            setState(() {});
          },
          child: Text(_putar.isAnimating ? 'Berhenti' : 'Putar'),
        ),
        const Divider(),
        // Latihan 5: demo keempat, AnimatedOpacity
        Text('4. AnimatedOpacity', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        Center(
          child: AnimatedOpacity(
            opacity: _tampil ? 1 : 0,
            duration: const Duration(milliseconds: 600),
            child: Card(
              color: warna.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Kartu ini memudar',
                  style: TextStyle(color: warna.onSecondaryContainer),
                ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _tampil = !_tampil),
          child: Text(_tampil ? 'Sembunyikan' : 'Munculkan'),
        ),
      ],
    );
  }
}

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _halaman = [BerandaTab(), AnimasiTab(), PengaturanTab()];
  static const _judul = ['Beranda', 'Animasi', 'Pengaturan'];

  // Latihan 2: Drawer untuk berpindah tab
  Widget _drawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Praktikum 6',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
          for (var i = 0; i < _judul.length; i++)
            ListTile(
              leading: Icon(
                [
                  Icons.home_outlined,
                  Icons.animation,
                  Icons.settings_outlined,
                ][i],
              ),
              title: Text(_judul[i]),
              selected: _index == i,
              onTap: () {
                setState(() => _index = i);
                Navigator.pop(context);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.link_off),
            title: const Text('Rute tidak dikenal (404)'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/rute-tidak-ada');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_index])),
      drawer: _drawer(context),
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
