import 'package:flutter/material.dart';

import '../models/kegiatan.dart';
import '../services/api_exception.dart';
import '../services/kegiatan_api.dart';
import '../utils/format.dart';

const kategoriPengeluaran = [
  'Makan',
  'Transport',
  'Belajar',
  'Hiburan',
  'Lainnya',
];

/// Form tambah/ubah kegiatan yang memanggil API (POST/PUT).
class FormKegiatanApiPage extends StatefulWidget {
  final Kegiatan? kegiatan;
  final KegiatanApi api;

  const FormKegiatanApiPage({super.key, this.kegiatan, required this.api});

  @override
  State<FormKegiatanApiPage> createState() => _FormKegiatanApiPageState();
}

class _FormKegiatanApiPageState extends State<FormKegiatanApiPage> {
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
    _kategori = (k == null || k.kategori == '-')
        ? kategoriPengeluaran.first
        : k.kategori;
    _tanggal = k == null ? DateTime.now() : parseTanggalIso(k.tanggal);
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
    );
    if (hasil == null) return;
    setState(() => _tanggal = hasil);
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    final data = Kegiatan(
      id: widget.kegiatan?.id,
      judul: _judul.text.trim(),
      tanggal: tanggalIso(_tanggal),
      selesai: widget.kegiatan?.selesai ?? false,
      tipe: _tipe,
      nominal: _tipe == Tipe.tanpa ? 0 : int.parse(_nominal.text.trim()),
      kategori: _tipe == Tipe.pengeluaran ? _kategori : '-',
    );
    try {
      if (_ubah) {
        await widget.api.ubah(widget.kegiatan!.id!, data);
      } else {
        await widget.api.tambah(data);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.pesan)));
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_ubah ? 'Ubah Kegiatan' : 'Tambah Kegiatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judul,
              decoration: const InputDecoration(
                labelText: 'Nama kegiatan',
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
              subtitle: Text(formatTanggalPanjang(tanggalIso(_tanggal))),
              trailing: TextButton(
                onPressed: _pilihTanggal,
                child: const Text('Pilih'),
              ),
            ),
            const SizedBox(height: 16),
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
              onSelectionChanged: (p) {
                setState(() {
                  _tipe = p.first;
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
                  prefixText: 'Rp ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (v) {
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
            Text(
              'Validasi ganda: form mencegah input salah, backend Pydantic '
              'juga memvalidasi dan membalas 422 dengan detail field.',
              style: tema.textTheme.bodySmall,
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
                  : const Icon(Icons.cloud_upload),
              label: Text(_menyimpan ? 'Mengirim...' : 'Simpan ke server'),
            ),
          ],
        ),
      ),
    );
  }
}
