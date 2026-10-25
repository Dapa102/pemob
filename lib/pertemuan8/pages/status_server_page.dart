import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/health_service.dart';

/// Halaman status server: API dan database ditampilkan terpisah.
class StatusServerPage extends StatefulWidget {
  const StatusServerPage({super.key});

  @override
  State<StatusServerPage> createState() => _StatusServerPageState();
}

class _StatusServerPageState extends State<StatusServerPage> {
  late Future<StatusServer> _future;

  @override
  void initState() {
    super.initState();
    _future = cekServer();
    // Ganti alamat di Pengaturan -> halaman ini memeriksa ulang otomatis.
    apiUrl.addListener(_periksa);
  }

  @override
  void dispose() {
    apiUrl.removeListener(_periksa);
    super.dispose();
  }

  void _periksa() {
    if (!mounted) return;
    setState(() => _future = cekServer());
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Server'),
        actions: [
          IconButton(
            tooltip: 'Periksa lagi',
            icon: const Icon(Icons.refresh),
            onPressed: _periksa,
          ),
        ],
      ),
      body: FutureBuilder<StatusServer>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Kartu(
                  ikon: Icons.cloud_off,
                  judul: 'API tidak dapat dihubungi',
                  warna: tema.colorScheme.error,
                  anak: [
                    Text('${snapshot.error}', style: tema.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Pastikan docker compose sedang berjalan dan alamat '
                      'API sesuai perangkat.',
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _AlamatCard(),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _periksa,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Periksa lagi'),
                ),
              ],
            );
          }

          final status = snapshot.data!;
          final apiHidup = status.apiHidup;
          final dbHidup = status.databaseHidup;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (status.kode == 503)
                _Pesan(
                  ikon: Icons.warning_amber,
                  teks: 'API hidup, tetapi database tidak dapat dihubungi.',
                  warna: tema.colorScheme.errorContainer,
                  warnaTeks: tema.colorScheme.onErrorContainer,
                ),
              if (status.kode == 503) const SizedBox(height: 12),
              _StatusBaris(
                label: 'Status API',
                hidup: apiHidup,
                keterangan: apiHidup
                    ? 'Server FastAPI membalas (HTTP ${status.kode})'
                    : 'Server tidak membalas',
              ),
              const SizedBox(height: 8),
              _StatusBaris(
                label: 'Status Database',
                hidup: dbHidup,
                keterangan: dbHidup
                    ? 'MySQL terhubung'
                    : 'MySQL tidak dapat dihubungi',
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.link),
                      title: const Text('Alamat API'),
                      subtitle: Text(apiUrl.value),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Waktu server'),
                      subtitle: Text(status.waktuServer),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.speed),
                      title: const Text('Latensi'),
                      subtitle: Text('${status.latensi.inMilliseconds} ms'),
                    ),
                    if (status.mysqlVersion != null) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.storage),
                        title: const Text('Versi MySQL'),
                        subtitle: Text(status.mysqlVersion!),
                      ),
                    ],
                  ],
                ),
              ),
              if (status.pesan != null && status.pesan!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Kartu(
                  ikon: Icons.error_outline,
                  judul: 'Detail galat database',
                  warna: tema.colorScheme.error,
                  anak: [
                    SelectableText(
                      status.pesan!,
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _periksa,
                icon: const Icon(Icons.refresh),
                label: const Text('Periksa lagi'),
              ),
              const SizedBox(height: 8),
              Text(
                'Kode 503 dibaca sebagai "API hidup, database mati", bukan '
                'galat jaringan. Hentikan MySQL dengan '
                '"docker compose stop mysql" untuk mencobanya.',
                style: tema.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AlamatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.link),
        title: const Text('Alamat API'),
        subtitle: Text(apiUrl.value),
      ),
    );
  }
}

class _StatusBaris extends StatelessWidget {
  final String label;
  final bool hidup;
  final String keterangan;

  const _StatusBaris({
    required this.label,
    required this.hidup,
    required this.keterangan,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = hidup ? Colors.green : tema.colorScheme.error;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: warna.withValues(alpha: 0.15),
          child: Icon(hidup ? Icons.check_circle : Icons.cancel, color: warna),
        ),
        title: Text(label),
        subtitle: Text(keterangan),
        trailing: Text(
          hidup ? 'Hidup' : 'Mati',
          style: tema.textTheme.labelLarge?.copyWith(
            color: warna,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _Kartu extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final Color warna;
  final List<Widget> anak;

  const _Kartu({
    required this.ikon,
    required this.judul,
    required this.warna,
    required this.anak,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ikon, color: warna),
                const SizedBox(width: 8),
                Expanded(child: Text(judul, style: tema.textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 8),
            ...anak,
          ],
        ),
      ),
    );
  }
}

class _Pesan extends StatelessWidget {
  final IconData ikon;
  final String teks;
  final Color warna;
  final Color warnaTeks;

  const _Pesan({
    required this.ikon,
    required this.teks,
    required this.warna,
    required this.warnaTeks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(ikon, color: warnaTeks),
          const SizedBox(width: 8),
          Expanded(
            child: Text(teks, style: TextStyle(color: warnaTeks)),
          ),
        ],
      ),
    );
  }
}
