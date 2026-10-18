import 'package:flutter/material.dart';

import 'post.dart';
import 'post_service.dart';

// Tugas Pertemuan 4: Aplikasi Daftar Postingan.
// Model dan pengambil data berada di post.dart dan post_service.dart,
// sedangkan berkas ini hanya menangani tampilan (UI).

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Postingan',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const PostinganPage(),
    );
  }
}

// Halaman utama: daftar postingan (judul + potongan isi)
class PostinganPage extends StatefulWidget {
  const PostinganPage({super.key});
  @override
  State<PostinganPage> createState() => _PostinganPageState();
}

class _PostinganPageState extends State<PostinganPage> {
  late Future<List<Postingan>> _future;

  @override
  void initState() {
    super.initState();
    _future = ambilPostingan();
  }

  void _muatUlang() {
    setState(() {
      _future = ambilPostingan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Postingan'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _muatUlang),
        ],
      ),
      body: FutureBuilder<List<Postingan>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _TampilanGalat(onCobaLagi: _muatUlang);
          }

          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('Tidak ada data'));
          }

          return RefreshIndicator(
            onRefresh: () async => _muatUlang(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = data[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${p.id}')),
                  title: Text(
                    p.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    p.isi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPostinganPage(postingan: p),
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

// Halaman detail: isi lengkap + daftar komentar (Future kedua)
class DetailPostinganPage extends StatefulWidget {
  final Postingan postingan;
  const DetailPostinganPage({super.key, required this.postingan});

  @override
  State<DetailPostinganPage> createState() => _DetailPostinganPageState();
}

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
          Text(
            p.judul,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Ditulis oleh pengguna #${p.userId}'),
          const Divider(height: 32),
          Text(p.isi, style: const TextStyle(fontSize: 16, height: 1.5)),
          const Divider(height: 32),
          const Text(
            'Komentar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
              if (komentar.isEmpty) {
                return const Text('Belum ada komentar');
              }

              return Column(
                children: [
                  for (final k in komentar)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(k.nama[0])),
                        title: Text(
                          k.nama,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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

// Widget bantu untuk menampilkan status galat beserta tombol "Coba lagi"
class _TampilanGalat extends StatelessWidget {
  final VoidCallback? onCobaLagi;
  const _TampilanGalat({this.onCobaLagi});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            const Text(
              'Terjadi kesalahan saat memuat data.\nPeriksa koneksi internet Anda.',
              textAlign: TextAlign.center,
            ),
            if (onCobaLagi != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onCobaLagi,
                child: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
