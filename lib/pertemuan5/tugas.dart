import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pengeluaran_db.dart';

// Tugas Pertemuan 5: Aplikasi Pencatat Pengeluaran.
// - CRUD lengkap (daftar, tambah, ubah, hapus) memakai SQLite.
// - Validasi formulir: nama wajib, jumlah angka > 0, kategori dari dropdown.
// - Total pengeluaran ditampilkan pada halaman utama.
// - Satu pengaturan (mode gelap) disimpan dengan shared_preferences.
// - Data tetap ada setelah aplikasi ditutup dan dibuka kembali.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final gelapAwal = prefs.getBool('gelap') ?? false;
  runApp(PengeluaranApp(gelapAwal: gelapAwal));
}

// Memformat angka menjadi format rupiah sederhana, misalnya 15000 -> 15.000
String formatRupiah(int angka) {
  return angka.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
}

// Mengubah DateTime menjadi teks dd-MM-yyyy
String formatTanggal(DateTime tanggal) {
  final d = tanggal.day.toString().padLeft(2, '0');
  final m = tanggal.month.toString().padLeft(2, '0');
  return '$d-$m-${tanggal.year}';
}

class PengeluaranApp extends StatefulWidget {
  final bool gelapAwal;
  const PengeluaranApp({super.key, required this.gelapAwal});

  @override
  State<PengeluaranApp> createState() => _PengeluaranAppState();
}

class _PengeluaranAppState extends State<PengeluaranApp> {
  late bool _gelap = widget.gelapAwal;

  Future<void> _ubahGelap(bool nilai) async {
    setState(() => _gelap = nilai);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gelap', nilai);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pencatat Pengeluaran',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _gelap ? ThemeMode.dark : ThemeMode.light,
      home: PengeluaranPage(gelap: _gelap, onUbahGelap: _ubahGelap),
    );
  }
}

class PengeluaranPage extends StatefulWidget {
  final bool gelap;
  final ValueChanged<bool> onUbahGelap;
  const PengeluaranPage({
    super.key,
    required this.gelap,
    required this.onUbahGelap,
  });

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  late Future<List<Pengeluaran>> _future;

  @override
  void initState() {
    super.initState();
    _future = DbPengeluaran.semua();
  }

  void _muat() {
    setState(() {
      _future = DbPengeluaran.semua();
    });
  }

  Future<void> _buka([Pengeluaran? pengeluaran]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormPengeluaranPage(pengeluaran: pengeluaran),
      ),
    );
    if (!mounted) return;
    _muat();
  }

  Future<void> _konfirmasiHapus(Pengeluaran e) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus pengeluaran ini?'),
        content: Text('"${e.nama}" akan dihapus secara permanen.'),
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
    await DbPengeluaran.hapus(e.id!);
    if (!mounted) return;
    _muat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatat Pengeluaran'),
        actions: [
          IconButton(
            tooltip: 'Ubah tema',
            icon: Icon(widget.gelap ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.onUbahGelap(!widget.gelap),
          ),
        ],
      ),
      body: FutureBuilder<List<Pengeluaran>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Galat: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          // Total dihitung di Dart dari data yang sudah dimuat
          final total = data.fold<int>(0, (jumlah, e) => jumlah + e.jumlah);

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('Total Pengeluaran'),
                  subtitle: Text(
                    'Rp ${formatRupiah(total)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text('${data.length} data'),
                ),
              ),
              Expanded(
                child: data.isEmpty
                    ? const Center(child: Text('Belum ada pengeluaran'))
                    : ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, i) {
                          final e = data[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.shopping_cart),
                              ),
                              title: Text(e.nama),
                              subtitle: Text('${e.kategori} • ${e.tanggal}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Rp ${formatRupiah(e.jumlah)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _konfirmasiHapus(e),
                                  ),
                                ],
                              ),
                              onTap: () => _buka(e),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormPengeluaranPage extends StatefulWidget {
  final Pengeluaran? pengeluaran;
  const FormPengeluaranPage({super.key, this.pengeluaran});

  @override
  State<FormPengeluaranPage> createState() => _FormPengeluaranPageState();
}

class _FormPengeluaranPageState extends State<FormPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _jumlah;
  String? _kategori;
  late DateTime _tanggal;

  final List<String> _daftarKategori = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Tagihan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.pengeluaran;
    _nama = TextEditingController(text: e?.nama ?? '');
    _jumlah = TextEditingController(text: e?.jumlah.toString() ?? '');
    _kategori = e?.kategori;
    _tanggal = e == null ? DateTime.now() : DateTime.parse(e.tanggal);
  }

  @override
  void dispose() {
    _nama.dispose();
    _jumlah.dispose();
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

    final data = Pengeluaran(
      id: widget.pengeluaran?.id,
      nama: _nama.text.trim(),
      jumlah: int.parse(_jumlah.text.trim()),
      kategori: _kategori!,
      tanggal: formatTanggal(_tanggal),
    );

    if (widget.pengeluaran == null) {
      await DbPengeluaran.tambah(data);
    } else {
      await DbPengeluaran.ubah(data);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.pengeluaran == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(baru ? 'Pengeluaran Baru' : 'Ubah Pengeluaran'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama pengeluaran',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah (Rp)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Jumlah wajib diisi';
                }
                final nilai = int.tryParse(v.trim());
                if (nilai == null) return 'Jumlah harus berupa angka';
                if (nilai <= 0) return 'Jumlah harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: _daftarKategori
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v),
              validator: (v) => v == null ? 'Pilih kategori' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Tanggal'),
              subtitle: Text(formatTanggal(_tanggal)),
              trailing: TextButton(
                onPressed: _pilihTanggal,
                child: const Text('Pilih'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
