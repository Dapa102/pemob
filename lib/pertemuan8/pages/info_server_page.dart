import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/info_service.dart';

/// Latihan Mandiri 1: menampilkan hasil endpoint GET /info.
class InfoServerPage extends StatefulWidget {
  const InfoServerPage({super.key});

  @override
  State<InfoServerPage> createState() => _InfoServerPageState();
}

class _InfoServerPageState extends State<InfoServerPage> {
  late Future<InfoServer> _future;

  @override
  void initState() {
    super.initState();
    _future = ambilInfo();
    apiUrl.addListener(_muat);
  }

  @override
  void dispose() {
    apiUrl.removeListener(_muat);
    super.dispose();
  }

  void _muat() {
    if (!mounted) return;
    setState(() => _future = ambilInfo());
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Server'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _muat,
          ),
        ],
      ),
      body: FutureBuilder<InfoServer>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memuat /info.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final info = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.apps),
                      title: const Text('Nama aplikasi'),
                      subtitle: Text(info.namaAplikasi),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.numbers),
                      title: const Text('Versi'),
                      subtitle: Text(info.versi),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.public),
                      title: const Text('Zona waktu server'),
                      subtitle: Text(info.zonaWaktu),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Waktu server'),
                      subtitle: Text(info.waktuServer),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.speed),
                      title: const Text('Latensi'),
                      subtitle: Text('${info.latensi.inMilliseconds} ms'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Latihan Mandiri: endpoint GET /info ditambahkan pada '
                'backend dan ditampilkan di halaman ini. Alamat API: '
                '${apiUrl.value}',
                style: tema.textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
