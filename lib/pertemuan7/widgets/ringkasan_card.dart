import 'package:flutter/material.dart';

import '../models/kegiatan.dart';
import '../utils/format.dart';

/// Kartu ringkasan hari ini + indikator kemajuan target yang beranimasi.
class RingkasanCard extends StatelessWidget {
  final Ringkasan ringkasan;
  final int target;

  const RingkasanCard({
    super.key,
    required this.ringkasan,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;
    final tercapai = target > 0 && ringkasan.tabungan >= target;
    final progres = target <= 0
        ? 0.0
        : (ringkasan.tabungan / target).clamp(0.0, 1.0);
    final warnaProgres = ringkasan.negatif
        ? warna.error
        : (tercapai ? Colors.green : warna.primary);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tabungan hari ini',
                    style: tema.textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    '${ringkasan.selesai}/${ringkasan.jumlahKegiatan} selesai',
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Rp ${formatRupiah(ringkasan.tabungan)}',
              style: tema.textTheme.headlineMedium?.copyWith(
                color: ringkasan.negatif ? warna.error : null,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progres),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, nilai, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: nilai,
                    minHeight: 10,
                    color: warnaProgres,
                    backgroundColor: warna.surfaceContainerHighest,
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Target Rp ${formatRupiah(target)}',
                    style: tema.textTheme.bodySmall,
                  ),
                ),
                Text(
                  '${(progres * 100).round()}%',
                  style: tema.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _Angka(
                  ikon: Icons.south_west,
                  label: 'Pemasukan',
                  nilai: 'Rp ${formatRupiah(ringkasan.pemasukan)}',
                  warna: Colors.green,
                ),
                _Angka(
                  ikon: Icons.north_east,
                  label: 'Pengeluaran',
                  nilai: 'Rp ${formatRupiah(ringkasan.pengeluaran)}',
                  warna: warna.error,
                ),
              ],
            ),
            if (ringkasan.negatif) ...[
              const SizedBox(height: 12),
              _Pesan(
                ikon: Icons.warning_amber_rounded,
                teks: 'Tabungan hari ini minus. Kurangi pengeluaran kecil.',
                warna: warna.errorContainer,
                warnaTeks: warna.onErrorContainer,
              ),
            ] else if (tercapai) ...[
              const SizedBox(height: 12),
              _Pesan(
                ikon: Icons.emoji_events,
                teks: 'Selamat! Target tabungan hari ini tercapai.',
                warna: Colors.green.withValues(alpha: 0.15),
                warnaTeks: Colors.green.shade800,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Angka extends StatelessWidget {
  final IconData ikon;
  final String label;
  final String nilai;
  final Color warna;

  const _Angka({
    required this.ikon,
    required this.label,
    required this.nilai,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ikon, size: 18, color: warna),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: tema.textTheme.labelSmall),
            Text(
              nilai,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: warna,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(ikon, color: warnaTeks, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(teks, style: TextStyle(color: warnaTeks)),
          ),
        ],
      ),
    );
  }
}
