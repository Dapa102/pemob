import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

// Berkas ini merupakan pengembangan dari Bagian C dan D modul Pertemuan 4
// ditambah penyelesaian Latihan Mandiri 1 sampai 4.

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 4 - Latihan',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const PenggunaLatihanPage(),
    );
  }
}

// Latihan 1: menambahkan kolom username dan kota (data bersarang address.city)
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
      // Data bersarang: json['address'] bertipe Map, di dalamnya ada 'city'
      kota: (json['address'] as Map<String, dynamic>)['city'] as String,
    );
  }
}

// Kode pengambil data dipisah dari kode tampilan (UI)
Future<List<Pengguna>> ambilPengguna() async {
  final uri = Uri.parse('https://jsonplaceholder.typicode.com/users');
  final response = await http.get(uri).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Gagal memuat data (kode ${response.statusCode})');
  }

  final List<dynamic> data = jsonDecode(response.body);
  return data.map((e) => Pengguna.fromJson(e as Map<String, dynamic>)).toList();
}

class PenggunaLatihanPage extends StatefulWidget {
  const PenggunaLatihanPage({super.key});
  @override
  State<PenggunaLatihanPage> createState() => _PenggunaLatihanPageState();
}

class _PenggunaLatihanPageState extends State<PenggunaLatihanPage> {
  late Future<List<Pengguna>> _future;

  @override
  void initState() {
    super.initState();
    _future = ambilPengguna();
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
          // Latihan 4: menampilkan jumlah pengguna setelah data berhasil dimuat
          FutureBuilder<List<Pengguna>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text('${snapshot.data!.length} pengguna'),
                ),
              );
            },
          ),
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terjadi kesalahan:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _muatUlang,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;

          // Latihan 3: bila daftar kosong tampilkan teks "Tidak ada data"
          if (data.isEmpty) {
            return const Center(child: Text('Tidak ada data'));
          }

          // Latihan 2: RefreshIndicator agar daftar dapat ditarik ke bawah
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
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPenggunaPage(pengguna: p),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailPenggunaPage extends StatelessWidget {
  final Pengguna pengguna;
  const DetailPenggunaPage({super.key, required this.pengguna});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pengguna.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('@${pengguna.username}'),
          ),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(pengguna.kota),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(pengguna.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(pengguna.phone),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(pengguna.website),
          ),
        ],
      ),
    );
  }
}
