import 'package:flutter/material.dart';

import '../models/kegiatan.dart';
import '../services/laporan_api.dart';
import '../utils/format.dart';

/// Tugas Pertemuan 9: halaman laporan memakai GET /laporan/harian dan
/// GET /laporan/rentang.
class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final _api = LaporanApi();
  late String _tanggal;
  late Future<LaporanHarian> _future;
  late Future<LaporanRentang> _futureRentang;

  @override
  void initState() {
    super.initState();
    _tanggal = tanggalIso(DateTime.now());
    _future = _api.harian(_tanggal);
    _futureRentang = _rentang();
  }

  @override
  void dispose() {
    _api.tutup();
    super.dispose();
  }

  Future<LaporanRentang> _rentang() {
    final akhir = parseTanggalIso(_tanggal);
    final mulai = akhir.subtract(const Duration(days: 6));
    return _api.rentang(tanggalIso(mulai), _tanggal);
  }

  void _muat() {
    if (!mounted) return;
    setState(() {
      _future = _api.harian(_tanggal);
      _futureRentang = _rentang();
    });
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: parseTanggalIso(_tanggal),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (hasil == null) return;
    setState(() => _tanggal = tanggalIso(hasil));
    _muat();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan (API)'),
        actions: [
          IconButton(
            tooltip: 'Pilih tanggal',
            icon: const Icon(Icons.event),
            onPressed: _pilihTanggal,
          ),
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _muat,
          ),
        ],
      ),
      body: FutureBuilder<LaporanHarian>(
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
                  'Gagal memuat laporan.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final laporan = snapshot.data!;
          final r = laporan.ringkasan;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(formatTanggalPanjang(laporan.tanggal)),
                  subtitle: const Text('Laporan harian dihitung di SQL'),
                  trailing: TextButton(
                    onPressed: _pilihTanggal,
                    child: const Text('Ganti'),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tabungan', style: tema.textTheme.titleMedium),
                      Text(
                        'Rp ${formatRupiah(r.tabungan)}',
                        style: tema.textTheme.headlineMedium?.copyWith(
                          color: r.tabungan < 0 ? tema.colorScheme.error : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _Angka(
                            label: 'Kegiatan',
                            nilai: '${r.selesai}/${r.jumlahKegiatan}',
                            ikon: Icons.checklist,
                          ),
                          _Angka(
                            label: 'Pemasukan',
                            nilai: 'Rp ${formatRupiah(r.pemasukan)}',
                            ikon: Icons.south_west,
                            warna: Colors.green,
                          ),
                          _Angka(
                            label: 'Pengeluaran',
                            nilai: 'Rp ${formatRupiah(r.pengeluaran)}',
                            ikon: Icons.north_east,
                            warna: tema.colorScheme.error,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                    child: Text('Tidak ada pengeluaran pada tanggal ini.'),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _KategoriList(data: laporan.perKategori),
                  ),
                ),
              const SizedBox(height: 20),
              Text('Tujuh hari terakhir', style: tema.textTheme.titleMedium),
              const SizedBox(height: 8),
              FutureBuilder<LaporanRentang>(
                future: _futureRentang,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Galat rentang: ${snap.error}'),
                      ),
                    );
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _GrafikRentang(data: snap.data!.hari),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Angka di atas berasal dari query COUNT, SUM(CASE WHEN ...), '
                'dan GROUP BY di MySQL, bukan penjumlahan di Dart.',
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

class _Angka extends StatelessWidget {
  final String label;
  final String nilai;
  final IconData ikon;
  final Color? warna;

  const _Angka({
    required this.label,
    required this.nilai,
    required this.ikon,
    this.warna,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 16, color: warna ?? tema.colorScheme.primary),
            const SizedBox(width: 4),
            Text(label, style: tema.textTheme.labelSmall),
          ],
        ),
        Text(
          nilai,
          style: tema.textTheme.bodyMedium?.copyWith(
            color: warna,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _KategoriList extends StatelessWidget {
  final List<KategoriTotal> data;

  const _KategoriList({required this.data});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final maks = data.first.total == 0 ? 1 : data.first.total;
    return Column(
      children: [
        for (final e in data) ...[
          Row(
            children: [
              Expanded(child: Text(e.kategori)),
              Text(
                'Rp ${formatRupiah(e.total)}',
                style: tema.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: e.total / maks, minHeight: 8),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _GrafikRentang extends StatelessWidget {
  final List<HariLaporan> data;

  const _GrafikRentang({required this.data});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final maks = data
        .map((h) => h.ringkasan.tabungan.abs())
        .fold<int>(1, (a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final h in data)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 42,
                  child: Text(
                    labelPendek(h.tanggal),
                    style: tema.textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: h.ringkasan.tabungan.abs() / maks,
                      minHeight: 10,
                      color: h.ringkasan.tabungan < 0
                          ? tema.colorScheme.error
                          : tema.colorScheme.primary,
                      backgroundColor: tema.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 78,
                  child: Text(
                    'Rp ${formatRupiah(h.ringkasan.tabungan)}',
                    textAlign: TextAlign.right,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: h.ringkasan.tabungan < 0
                          ? tema.colorScheme.error
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
