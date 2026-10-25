import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../state/pengaturan.dart';
import '../utils/format.dart';
import '../widgets/ringkasan_card.dart';

/// Tab kedua: laporan harian, pengeluaran per kategori, dan grafik 7 hari.
class LaporanPage extends StatefulWidget {
  /// Menyalakan ekspor clipboard dan laporan bulanan (fitur lanjutan).
  final bool fiturLanjutan;

  const LaporanPage({super.key, this.fiturLanjutan = false});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  late String _tanggal;
  late DateTime _bulan;
  late Future<LaporanHarian> _futureHarian;
  late Future<List<HariLaporan>> _futureTujuh;
  late Future<List<HariLaporan>> _futureBulan;
  bool _modeBulan = false;

  @override
  void initState() {
    super.initState();
    final sekarang = DateTime.now();
    _tanggal = tanggalIso(sekarang);
    _bulan = DateTime(sekarang.year, sekarang.month);
    _muat();
    versiData.addListener(_muat);
  }

  @override
  void dispose() {
    versiData.removeListener(_muat);
    super.dispose();
  }

  void _muat() {
    if (!mounted) return;
    setState(() {
      _futureHarian = DbHelper.laporanHarian(_tanggal);
      _futureTujuh = DbHelper.tujuhHariTerakhir(_tanggal);
      _futureBulan = DbHelper.laporanBulan(_bulan.year, _bulan.month);
    });
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: parseTanggalIso(_tanggal),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal laporan',
    );
    if (hasil == null) return;
    setState(() {
      _tanggal = tanggalIso(hasil);
      _modeBulan = false;
    });
    _muat();
  }

  Future<void> _pilihBulan() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _bulan,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih bulan laporan (tanggal diabaikan)',
    );
    if (hasil == null) return;
    setState(() => _bulan = DateTime(hasil.year, hasil.month));
    _muat();
  }

  Future<void> _ekspor() async {
    final teks = await DbHelper.eksporLaporan(_tanggal);
    await Clipboard.setData(ClipboardData(text: teks));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Laporan disalin ke papan klip.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return FutureBuilder<LaporanHarian>(
      future: _futureHarian,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Galat: ${snapshot.error}'));
        }
        final laporan = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            _muat();
            await _futureHarian;
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(formatTanggalPanjang(_tanggal)),
                  subtitle: Text(namaHari(_tanggal)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: _pilihTanggal,
                        child: const Text('Tanggal'),
                      ),
                      if (widget.fiturLanjutan)
                        IconButton(
                          tooltip: 'Ekspor laporan',
                          icon: const Icon(Icons.copy_all),
                          onPressed: _ekspor,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              RingkasanCard(
                ringkasan: laporan.ringkasan,
                target: targetTabungan.value,
              ),
              const SizedBox(height: 16),
              Text(
                'Pengeluaran per kategori',
                style: tema.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (laporan.perKategori.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Belum ada pengeluaran pada tanggal ini.'),
                  ),
                )
              else
                _DaftarKategori(data: laporan.perKategori),
              const SizedBox(height: 20),
              if (widget.fiturLanjutan)
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('7 hari'),
                      icon: Icon(Icons.view_week),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Bulan ini'),
                      icon: Icon(Icons.calendar_view_month),
                    ),
                  ],
                  selected: {_modeBulan},
                  onSelectionChanged: (v) {
                    setState(() => _modeBulan = v.first);
                  },
                )
              else
                Text('Tujuh hari terakhir', style: tema.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_modeBulan) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bulan ${_bulan.month}/${_bulan.year}',
                        style: tema.textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: _pilihBulan,
                      child: const Text('Ganti bulan'),
                    ),
                  ],
                ),
                FutureBuilder<List<HariLaporan>>(
                  future: _futureBulan,
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Galat: ${snap.error}'),
                        ),
                      );
                    }
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _GrafikHari(
                      data: snap.data!,
                      labelRingkas: (h) => '${parseTanggalIso(h.tanggal).day}',
                      kosong: 'Belum ada kegiatan bulan ini.',
                    );
                  },
                ),
              ] else
                FutureBuilder<List<HariLaporan>>(
                  future: _futureTujuh,
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Galat: ${snap.error}'),
                        ),
                      );
                    }
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _GrafikHari(
                      data: snap.data!,
                      labelRingkas: (h) => labelTanggalPendek(h.tanggal),
                      kosong: 'Belum ada kegiatan pada tujuh hari ini.',
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _DaftarKategori extends StatelessWidget {
  final List<MapEntry<String, int>> data;

  const _DaftarKategori({required this.data});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final maks = data.first.value == 0 ? 1 : data.first.value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final e in data) ...[
              Row(
                children: [
                  Expanded(child: Text(e.key)),
                  Text(
                    'Rp ${formatRupiah(e.value)}',
                    style: tema.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: e.value / maks,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _GrafikHari extends StatelessWidget {
  final List<HariLaporan> data;
  final String Function(HariLaporan) labelRingkas;
  final String kosong;

  const _GrafikHari({
    required this.data,
    required this.labelRingkas,
    required this.kosong,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final adaData = data.any((h) => h.ringkasan.jumlahKegiatan > 0);
    if (!adaData) {
      return Card(
        child: Padding(padding: const EdgeInsets.all(16), child: Text(kosong)),
      );
    }
    final nilaiMaks = data
        .map((h) => h.ringkasan.tabungan.abs())
        .fold<int>(1, (a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final h in data)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 46,
                      child: Text(
                        labelRingkas(h),
                        style: tema.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: h.ringkasan.tabungan.abs() / nilaiMaks,
                          minHeight: 10,
                          color: h.ringkasan.negatif
                              ? tema.colorScheme.error
                              : tema.colorScheme.primary,
                          backgroundColor:
                              tema.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 82,
                      child: Text(
                        'Rp ${formatRupiah(h.ringkasan.tabungan)}',
                        textAlign: TextAlign.right,
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: h.ringkasan.negatif
                              ? tema.colorScheme.error
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total tabungan',
                    style: tema.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  'Rp ${formatRupiah(data.fold<int>(0, (a, h) => a + h.ringkasan.tabungan))}',
                  style: tema.textTheme.titleSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
