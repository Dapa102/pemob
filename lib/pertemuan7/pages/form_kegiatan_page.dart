import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

/// Daftar kategori pengeluaran sesuai aturan bisnis modul.
const kategoriPengeluaran = [
  'Makan',
  'Transport',
  'Belajar',
  'Hiburan',
  'Lainnya',
];

/// Form tambah/ubah kegiatan.
///
/// Rute `/form` menerima argumen [Kegiatan] (null berarti tambah baru).
class FormKegiatanPage extends StatefulWidget {
  final Kegiatan? kegiatan;
  final String? tanggalAwal;

  const FormKegiatanPage({super.key, this.kegiatan, this.tanggalAwal});

  @override
  State<FormKegiatanPage> createState() => _FormKegiatanPageState();
}

class _FormKegiatanPageState extends State<FormKegiatanPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judul;
  late final TextEditingController _nominal;
  late Tipe _tipe;
  late String _kategori;
  late DateTime _tanggal;
  bool _menyimpan = false;

  bool get _ubah => widget.kegiatan != null;

  @override
  void initState() {
    super.initState();
    final k = widget.kegiatan;
    _judul = TextEditingController(text: k?.judul ?? '');
    _nominal = TextEditingController(
      text: (k == null || k.nominal == 0) ? '' : k.nominal.toString(),
    );
    _tipe = k?.tipe ?? Tipe.tanpa;
    _kategori = k?.kategori == '-' || k?.kategori == null
        ? kategoriPengeluaran.first
        : k!.kategori;
    _tanggal = k == null
        ? (widget.tanggalAwal == null
              ? DateTime.now()
              : parseTanggalIso(widget.tanggalAwal!))
        : parseTanggalIso(k.tanggal);
  }

  @override
  void dispose() {
    _judul.dispose();
    _nominal.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal kegiatan',
    );
    if (hasil == null) return;
    setState(() => _tanggal = hasil);
  }

  Future<void> _hapus() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus kegiatan?'),
        content: Text('"${widget.kegiatan!.judul}" akan dihapus permanen.'),
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
    await DbHelper.hapus(widget.kegiatan!.id!);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);

    // Aturan bisnis: kegiatan tanpa uang selalu bernominal 0 dan kategori '-'.
    final nominal = _tipe == Tipe.tanpa ? 0 : int.parse(_nominal.text.trim());
    final kategori = _tipe == Tipe.pengeluaran ? _kategori : '-';

    final data = Kegiatan(
      id: widget.kegiatan?.id,
      judul: _judul.text.trim(),
      tanggal: tanggalIso(_tanggal),
      selesai: widget.kegiatan?.selesai ?? false,
      tipe: _tipe,
      nominal: nominal,
      kategori: kategori,
    );

    if (_ubah) {
      await DbHelper.ubah(data);
    } else {
      await DbHelper.tambah(data);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_ubah ? 'Ubah Kegiatan' : 'Tambah Kegiatan'),
        actions: [
          if (_ubah)
            IconButton(
              tooltip: 'Hapus kegiatan',
              icon: const Icon(Icons.delete_outline),
              onPressed: _hapus,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judul,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nama kegiatan',
                hintText: 'Contoh: Makan siang',
                prefixIcon: Icon(Icons.edit_note),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: tema.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              leading: const Icon(Icons.calendar_today),
              title: const Text('Tanggal'),
              subtitle: Text(
                '${namaHari(tanggalIso(_tanggal))}, '
                '${formatTanggalPanjang(tanggalIso(_tanggal))}',
              ),
              trailing: TextButton(
                onPressed: _pilihTanggal,
                child: const Text('Pilih'),
              ),
            ),
            const SizedBox(height: 16),
            Text('Jenis keuangan', style: tema.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<Tipe>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: Tipe.tanpa,
                  label: Text('Tanpa uang'),
                  icon: Icon(Icons.money_off),
                ),
                ButtonSegment(
                  value: Tipe.pemasukan,
                  label: Text('Masuk'),
                  icon: Icon(Icons.south_west),
                ),
                ButtonSegment(
                  value: Tipe.pengeluaran,
                  label: Text('Keluar'),
                  icon: Icon(Icons.north_east),
                ),
              ],
              selected: {_tipe},
              onSelectionChanged: (pilihan) {
                setState(() {
                  _tipe = pilihan.first;
                  if (_tipe == Tipe.tanpa) _nominal.clear();
                });
              },
            ),
            if (_tipe != Tipe.tanpa) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _nominal,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  hintText: '15000',
                  prefixText: 'Rp ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (v) {
                  if (_tipe == Tipe.tanpa) return null;
                  if (v == null || v.trim().isEmpty) {
                    return 'Nominal wajib diisi';
                  }
                  final angka = int.tryParse(v.trim());
                  if (angka == null) return 'Nominal harus berupa angka';
                  if (angka <= 0) return 'Nominal harus lebih dari 0';
                  return null;
                },
              ),
            ],
            if (_tipe == Tipe.pengeluaran) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori pengeluaran',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  for (final k in kategoriPengeluaran)
                    DropdownMenuItem(value: k, child: Text(k)),
                ],
                onChanged: (v) => setState(() => _kategori = v ?? 'Lainnya'),
                validator: (v) => v == null ? 'Pilih kategori' : null,
              ),
            ],
            const SizedBox(height: 12),
            Card(
              color: tema.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: tema.colorScheme.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Tabungan harian dihitung dari semua kegiatan '
                        'pada tanggal tersebut, baik yang sudah selesai '
                        'maupun belum.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _menyimpan ? null : _simpan,
              icon: _menyimpan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_menyimpan ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
