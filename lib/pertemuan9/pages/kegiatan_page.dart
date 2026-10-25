import 'package:flutter/material.dart';

import '../models/kegiatan.dart';
import '../services/api_exception.dart';
import '../services/kegiatan_api.dart';
import '../utils/format.dart';
import 'form_kegiatan_page.dart';

/// Halaman daftar kegiatan yang membaca API (GET /kegiatan).
class KegiatanPage extends StatefulWidget {
  /// Menyalakan filter selesai, urutan, dan uji tanggal salah (latihan).
  final bool modeLatihan;

  const KegiatanPage({super.key, this.modeLatihan = false});

  @override
  State<KegiatanPage> createState() => _KegiatanPageState();
}

class _KegiatanPageState extends State<KegiatanPage> {
  final _api = KegiatanApi();
  late Future<List<Kegiatan>> _future;
  bool? _selesai;
  String _urut = 'terbaru';

  @override
  void initState() {
    super.initState();
    _future = _ambil();
  }

  @override
  void dispose() {
    _api.tutup();
    super.dispose();
  }

  Future<List<Kegiatan>> _ambil() {
    return _api.daftar(selesai: _selesai, urut: _urut);
  }

  void _muat() {
    if (!mounted) return;
    setState(() => _future = _ambil());
  }

  Future<void> _bukaForm([Kegiatan? kegiatan]) async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormKegiatanApiPage(kegiatan: kegiatan, api: _api),
      ),
    );
    if (berhasil == true) _muat();
  }

  Future<void> _toggle(Kegiatan k) async {
    try {
      await _api.setSelesai(k.id!, !k.selesai);
      _muat();
    } on ApiException catch (e) {
      _pesan(e.pesan);
    }
  }

  Future<void> _hapus(Kegiatan k) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus kegiatan?'),
        content: Text('"${k.judul}" akan dihapus dari server.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    try {
      await _api.hapus(k.id!);
      _muat();
    } on ApiException catch (e) {
      _pesan(e.pesan);
    }
  }

  Future<void> _ujiTanggalSalah() async {
    try {
      await _api.daftar(tanggal: '06-10-2026');
      _pesan('Tidak ada galat? Periksa validasi backend.');
    } on ApiException catch (e) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Respons 422'),
          content: Text(
            '${e.pesan}\n\nFormat tanggal yang benar: YYYY-MM-DD '
            '(contoh 2026-10-06).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kegiatan (API)'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _muat,
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.modeLatihan) _filterLatihan(tema),
          Expanded(
            child: FutureBuilder<List<Kegiatan>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        color: tema.colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.cloud_off,
                                size: 48,
                                color: tema.colorScheme.onErrorContainer,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gagal memuat kegiatan',
                                style: tema.textTheme.titleMedium?.copyWith(
                                  color: tema.colorScheme.onErrorContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: tema.colorScheme.onErrorContainer,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pastikan backend berjalan '
                                '(docker compose up -d) dan alamat API '
                                'benar.',
                                textAlign: TextAlign.center,
                                style: tema.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _muat,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba lagi'),
                      ),
                    ],
                  );
                }
                final data = snapshot.data!;
                if (data.isEmpty) {
                  return const Center(
                    child: Text('Belum ada kegiatan di server.'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    _muat();
                    await _future;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      final k = data[i];
                      return _Tile(
                        kegiatan: k,
                        onToggle: () => _toggle(k),
                        onUbah: () => _bukaForm(k),
                        onHapus: () => _hapus(k),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Kegiatan'),
      ),
    );
  }

  Widget _filterLatihan(ThemeData tema) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Latihan: filter & urutan',
                style: tema.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _selesai == null,
                    onSelected: (_) {
                      setState(() {
                        _selesai = null;
                        _future = _ambil();
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Selesai'),
                    selected: _selesai == true,
                    onSelected: (_) {
                      setState(() {
                        _selesai = true;
                        _future = _ambil();
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Belum'),
                    selected: _selesai == false,
                    onSelected: (_) {
                      setState(() {
                        _selesai = false;
                        _future = _ambil();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Urutan'),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _urut,
                    items: const [
                      DropdownMenuItem(
                        value: 'terbaru',
                        child: Text('Terbaru'),
                      ),
                      DropdownMenuItem(
                        value: 'terlama',
                        child: Text('Terlama'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _urut = v ?? 'terbaru';
                        _future = _ambil();
                      });
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _ujiTanggalSalah,
                    child: const Text('Uji tanggal salah'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final Kegiatan kegiatan;
  final VoidCallback onToggle;
  final VoidCallback onUbah;
  final VoidCallback onHapus;

  const _Tile({
    required this.kegiatan,
    required this.onToggle,
    required this.onUbah,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;
    final nominal = switch (kegiatan.tipe) {
      Tipe.pemasukan => '+Rp ${formatRupiah(kegiatan.nominal)}',
      Tipe.pengeluaran => '-Rp ${formatRupiah(kegiatan.nominal)}',
      Tipe.tanpa => '-',
    };
    final warnaL = switch (kegiatan.tipe) {
      Tipe.pemasukan => Colors.green,
      Tipe.pengeluaran => warna.error,
      Tipe.tanpa => warna.onSurfaceVariant,
    };
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: kegiatan.selesai,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          kegiatan.judul,
          style: TextStyle(
            decoration: kegiatan.selesai ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${kegiatan.tanggal} • ${kegiatan.tipe.label}'
          '${kegiatan.tipe == Tipe.pengeluaran ? ' • ${kegiatan.kategori}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              nominal,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: warnaL,
                fontWeight: FontWeight.w600,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) => v == 'ubah' ? onUbah() : onHapus(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'ubah', child: Text('Ubah')),
                PopupMenuItem(value: 'hapus', child: Text('Hapus')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
