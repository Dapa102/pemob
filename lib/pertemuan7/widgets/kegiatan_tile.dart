import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

/// Satu baris kegiatan: centang selesai, nominal, serta menu ubah/hapus.
class KegiatanTile extends StatelessWidget {
  final Kegiatan kegiatan;
  final VoidCallback onUbah;
  final VoidCallback onHapus;

  const KegiatanTile({
    super.key,
    required this.kegiatan,
    required this.onUbah,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;
    final teksNominal = switch (kegiatan.tipe) {
      Tipe.pemasukan => '+Rp ${formatRupiah(kegiatan.nominal)}',
      Tipe.pengeluaran => '-Rp ${formatRupiah(kegiatan.nominal)}',
      Tipe.tanpa => '-',
    };
    final warnaL = switch (kegiatan.tipe) {
      Tipe.pemasukan => Colors.green,
      Tipe.pengeluaran => warna.error,
      Tipe.tanpa => warna.onSurfaceVariant,
    };
    final rincian = [
      kegiatan.tipe.label,
      if (kegiatan.tipe == Tipe.pengeluaran) kegiatan.kategori,
    ].join(' • ');

    return Card(
      child: ListTile(
        leading: Checkbox(
          value: kegiatan.selesai,
          onChanged: (nilai) => DbHelper.ubahSelesai(kegiatan, nilai ?? false),
        ),
        title: Text(
          kegiatan.judul,
          style: TextStyle(
            decoration: kegiatan.selesai ? TextDecoration.lineThrough : null,
            color: kegiatan.selesai ? warna.onSurfaceVariant : null,
          ),
        ),
        subtitle: Text(rincian),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              teksNominal,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: warnaL,
                fontWeight: FontWeight.w600,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Menu kegiatan',
              onSelected: (nilai) {
                if (nilai == 'ubah') {
                  onUbah();
                } else {
                  onHapus();
                }
              },
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
