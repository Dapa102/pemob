import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../state/pengaturan.dart';
import '../utils/format.dart';

/// Tab ketiga: target tabungan, tema, warna, dan reset data.
class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  bool _menghapus = false;

  Future<void> _resetData() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua data?'),
        content: const Text(
          'Seluruh kegiatan akan dihapus permanen. Pengaturan tema dan '
          'target tidak ikut dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus semua'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    setState(() => _menghapus = true);
    await DbHelper.hapusSemua();
    if (!mounted) return;
    setState(() => _menghapus = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua data kegiatan sudah dihapus.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([temaMode, warnaSeed, targetTabungan]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Target tabungan harian', style: tema.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Rp ${formatRupiah(targetTabungan.value)}',
              style: tema.textTheme.headlineSmall?.copyWith(
                color: tema.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: targetTabungan.value.clamp(0, 100000).toDouble(),
              min: 0,
              max: 100000,
              divisions: 20,
              label: 'Rp ${formatRupiah(targetTabungan.value)}',
              onChanged: (v) => targetTabungan.value = v.round(),
              onChangeEnd: (v) => simpanTarget(v.round()),
            ),
            Text(
              'Geser lalu lepaskan untuk menyimpan target.',
              style: tema.textTheme.bodySmall,
            ),
            const Divider(height: 32),
            Text('Tampilan', style: tema.textTheme.titleMedium),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                temaMode.value == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: const Text('Mode gelap'),
              subtitle: const Text('Tersimpan setelah aplikasi ditutup'),
              value: temaMode.value == ThemeMode.dark,
              onChanged: simpanGelap,
            ),
            const SizedBox(height: 8),
            Text('Warna tema', style: tema.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                for (final c in pilihanWarna)
                  GestureDetector(
                    onTap: () => simpanWarna(c),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: c,
                      child: warnaSeed.value == c
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
            const Divider(height: 32),
            Text('Data', style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: tema.colorScheme.error,
                ),
                title: const Text('Hapus semua kegiatan'),
                subtitle: const Text('Tindakan ini tidak dapat dibatalkan'),
                trailing: _menghapus
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _menghapus ? null : _resetData,
              ),
            ),
            const SizedBox(height: 24),
            Text('Tentang', style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.savings),
                title: const Text('TabungKu'),
                subtitle: const Text(
                  'Mini proyek Pertemuan 7\n'
                  'To-do list + manajemen keuangan\n'
                  'Dafa Rafi Nurwansyah - 20240801157',
                ),
                isThreeLine: true,
              ),
            ),
          ],
        );
      },
    );
  }
}
