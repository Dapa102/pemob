import 'package:flutter/material.dart';

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

// Daftar menu
const daftarMenu = [
  Makanan(
    'Nasi Goreng',
    15000,
    'Nasi goreng dengan telur dan sayuran yang lezat.',
  ),
  Makanan(
    'Mie Ayam',
    12000,
    'Mie ayam dengan potongan ayam dan kuah gurih.',
  ),
  Makanan(
    'Es Teh',
    4000,
    'Minuman teh manis yang menyegarkan.',
  ),
  Makanan(
    'Ayam Bakar',
    20000,
    'Ayam bakar dengan bumbu khas yang lezat.',
  ),
  Makanan(
    'Sate Ayam',
    18000,
    'Sate ayam dengan bumbu kacang dan kecap.',
  ),
  Makanan(
    'Bakso',
    15000,
    'Bakso sapi dengan kuah gurih dan mie.',
  ),
  Makanan(
    'Seblak',
    13000,
    'Seblak pedas dengan kerupuk dan berbagai topping.',
  ),
];

// Aplikasi utama
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

// Halaman daftar menu
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
      ),

      // ListView membuat daftar dapat di-scroll
      body: ListView.builder(
        itemCount: daftarMenu.length,
        itemBuilder: (context, index) {
          final item = daftarMenu[index];

          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),

            // Warna latar dan sudut membulat
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),

            child: ListTile(
              leading: const Icon(
                Icons.restaurant,
                size: 32,
              ),

              title: Text(
                item.nama,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Harga sudah menggunakan format ribuan
              subtitle: Text(
                'Rp ${formatRupiah(item.harga)}',
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(
                      makanan: item,
                    ),
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

// Halaman detail makanan
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
              const Icon(
                Icons.restaurant_menu,
                size: 80,
              ),

              const SizedBox(height: 16),

              Text(
                makanan.nama,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Harga dengan format ribuan
              Text(
                'Rp ${formatRupiah(makanan.harga)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Deskripsi makanan
              Text(
                makanan.deskripsi,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
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