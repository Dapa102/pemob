import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../state/pengaturan.dart';
import '../utils/format.dart';
import '../widgets/kegiatan_tile.dart';
import '../widgets/ringkasan_card.dart';

class _TampilanHari {
  final Ringkasan ringkasan;
  final List<Kegiatan> kegiatan;
  final bool hasilCari;

  const _TampilanHari(this.ringkasan, this.kegiatan, this.hasilCari);
}

/// Tab pertama: ringkasan dan daftar kegiatan hari ini.
class BerandaPage extends StatefulWidget {
  /// Menyalakan pencarian/filter (fitur pengembangan lanjutan).
  final bool fiturLanjutan;

  const BerandaPage({super.key, this.fiturLanjutan = false});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final _pencarian = TextEditingController();
  late String _tanggal;
  late Future<_TampilanHari> _future;
  Tipe? _filterTipe;
  String? _filterKategori;

  bool get _adaFilter =>
      _pencarian.text.trim().isNotEmpty ||
      _filterTipe != null ||
      _filterKategori != null;

  @override
  void initState() {
    super.initState();
    _tanggal = tanggalIso(DateTime.now());
    _future = _ambil();
    versiData.addListener(_muat);
  }

  @override
  void dispose() {
    versiData.removeListener(_muat);
    _pencarian.dispose();
    super.dispose();
  }

  void _muat() {
    if (!mounted) return;
    setState(() => _future = _ambil());
  }

  Future<_TampilanHari> _ambil() async {
    final data = await DbHelper.dataHari(_tanggal);
    if (!_adaFilter) {
      return _TampilanHari(data.ringkasan, data.kegiatan, false);
    }
    final hasil = await DbHelper.cari(
      tanggal: _tanggal,
      kata: _pencarian.text,
      tipe: _filterTipe,
      kategori: _filterKategori,
    );
    return _TampilanHari(data.ringkasan, hasil, true);
  }

  Future<void> _bukaForm([Kegiatan? kegiatan]) async {
    await Navigator.pushNamed(context, '/form', arguments: kegiatan);
  }

  Future<void> _konfirmasiHapus(Kegiatan k) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus kegiatan?'),
        content: Text('"${k.judul}" akan dihapus permanen.'),
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
    if (yakin == true) await DbHelper.hapus(k.id!);
  }

  void _bersihkanFilter() {
    _pencarian.clear();
    setState(() {
      _filterTipe = null;
      _filterKategori = null;
      _future = _ambil();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return FutureBuilder<_TampilanHari>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Galat: ${snapshot.error}'));
        }
        final data = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            _muat();
            await _future;
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.fiturLanjutan) ...[
                _PencarianFilter(
                  controller: _pencarian,
                  tipe: _filterTipe,
                  kategori: _filterKategori,
                  onCari: (_) => _muat(),
                  onTipe: (t) {
                    setState(() {
                      _filterTipe = t;
                      _future = _ambil();
                    });
                  },
                  onKategori: (k) {
                    setState(() {
                      _filterKategori = k;
                      _future = _ambil();
                    });
                  },
                  onBersihkan: _bersihkanFilter,
                ),
                const SizedBox(height: 8),
              ],
              RingkasanCard(
                ringkasan: data.ringkasan,
                target: targetTabungan.value,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.hasilCari ? 'Hasil pencarian' : 'Kegiatan hari ini',
                      style: tema.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '${data.kegiatan.length} kegiatan',
                    style: tema.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${namaHari(_tanggal)}, ${formatTanggalPanjang(_tanggal)}',
                style: tema.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              if (data.kegiatan.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          data.hasilCari
                              ? Icons.search_off
                              : Icons.event_available,
                          size: 48,
                          color: tema.colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.hasilCari
                              ? 'Tidak ada kegiatan yang cocok.'
                              : 'Belum ada kegiatan hari ini.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tekan tombol + untuk menambah kegiatan.',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final k in data.kegiatan)
                  KegiatanTile(
                    kegiatan: k,
                    onUbah: () => _bukaForm(k),
                    onHapus: () => _konfirmasiHapus(k),
                  ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class _PencarianFilter extends StatelessWidget {
  final TextEditingController controller;
  final Tipe? tipe;
  final String? kategori;
  final ValueChanged<String> onCari;
  final ValueChanged<Tipe?> onTipe;
  final ValueChanged<String?> onKategori;
  final VoidCallback onBersihkan;

  const _PencarianFilter({
    required this.controller,
    required this.tipe,
    required this.kategori,
    required this.onCari,
    required this.onTipe,
    required this.onKategori,
    required this.onBersihkan,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              onChanged: onCari,
              decoration: InputDecoration(
                hintText: 'Cari nama kegiatan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: onBersihkan,
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('Semua jenis'),
                  selected: tipe == null,
                  onSelected: (_) => onTipe(null),
                ),
                for (final t in Tipe.values)
                  ChoiceChip(
                    label: Text(
                      t == Tipe.tanpa
                          ? 'Tanpa uang'
                          : (t == Tipe.pemasukan ? 'Masuk' : 'Keluar'),
                    ),
                    selected: tipe == t,
                    onSelected: (_) => onTipe(t),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey(kategori),
              initialValue: kategori ?? 'Semua kategori',
              decoration: const InputDecoration(
                labelText: 'Filter kategori pengeluaran',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(
                  value: 'Semua kategori',
                  child: Text('Semua kategori'),
                ),
                for (final k in const [
                  'Makan',
                  'Transport',
                  'Belajar',
                  'Hiburan',
                  'Lainnya',
                ])
                  DropdownMenuItem(value: k, child: Text(k)),
              ],
              onChanged: (v) {
                onKategori(v == 'Semua kategori' ? null : v);
              },
            ),
            if (tipe != null || kategori != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onBersihkan,
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Bersihkan filter'),
                ),
              ),
            ],
            Text(
              'Pencarian dan filter dijalankan lewat query SQL LIKE/WHERE.',
              style: tema.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
