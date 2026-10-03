import 'package:flutter/material.dart';

// Class untuk menyimpan data kontak
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

// Daftar kontak
const daftarKontak = [
  Kontak(
    'Andi Saputra',
    '081234567890',
    'andi@gmail.com',
  ),
  Kontak(
    'Budi Santoso',
    '082345678901',
    'budi@gmail.com',
  ),
  Kontak(
    'Citra Lestari',
    '083456789012',
    'citra@gmail.com',
  ),
  Kontak(
    'Deni Pratama',
    '084567890123',
    'deni@gmail.com',
  ),
  Kontak(
    'Eka Putri',
    '085678901234',
    'eka@gmail.com',
  ),
  Kontak(
    'Fajar Ramadhan',
    '086789012345',
    'fajar@gmail.com',
  ),
];

void main() {
  runApp(const MyApp());
}

// Aplikasi utama
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

// Halaman utama daftar kontak
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

          return ListTile(
            // Avatar berisi huruf pertama nama
            leading: CircleAvatar(
              child: Text(
                kontak.nama[0],
              ),
            ),

            // Nama kontak
            title: Text(
              kontak.nama,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            // Nomor telepon
            subtitle: Text(
              kontak.nomorTelepon,
            ),

            // Ikon panah
            trailing: const Icon(
              Icons.chevron_right,
            ),

            // Membuka halaman detail
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailKontakPage(
                    kontak: kontak,
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

// Halaman detail kontak
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
        title: const Text('Detail Kontak'),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar besar
              CircleAvatar(
                radius: 50,
                child: Text(
                  kontak.nama[0],
                  style: const TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Nama
              Text(
                kontak.nama,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Nomor telepon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone),
                  const SizedBox(width: 10),
                  Text(
                    kontak.nomorTelepon,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Email
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email),
                  const SizedBox(width: 10),
                  Text(
                    kontak.email,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Tombol kembali
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