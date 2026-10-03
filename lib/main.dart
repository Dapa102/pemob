import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Barang {
  final String nama;
  final int jumlah;
  final String kategori;
  bool sudahDibeli;

  Barang({
    required this.nama,
    required this.jumlah,
    required this.kategori,
    this.sudahDibeli = false,
  });
}

class BelanjaModel extends ChangeNotifier {
  final List<Barang> _items = [];

  List<Barang> get items => List.unmodifiable(_items);

  // Menghitung jumlah barang yang belum dibeli
  int get jumlahBelumDibeli {
    return _items.where((barang) => !barang.sudahDibeli).length;
  }

  // Menambahkan barang
  void tambahBarang({
    required String nama,
    required int jumlah,
    required String kategori,
  }) {
    _items.add(
      Barang(
        nama: nama,
        jumlah: jumlah,
        kategori: kategori,
      ),
    );

    notifyListeners();
  }

  // Mengubah status sudah dibeli
  void toggleDibeli(int index) {
    _items[index].sudahDibeli = !_items[index].sudahDibeli;
    notifyListeners();
  }

  // Menghapus barang
  void hapusBarang(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BelanjaModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Belanja',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const DaftarPage(),
    );
  }
}

class DaftarPage extends StatelessWidget {
  const DaftarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BelanjaModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Belanja (${model.jumlahBelumDibeli})',
        ),
      ),

      body: model.items.isEmpty
          ? const Center(
              child: Text(
                'Belum ada barang',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              itemCount: model.items.length,
              itemBuilder: (context, index) {
                final barang = model.items[index];

                return ListTile(
                  // Checkbox
                  leading: Checkbox(
                    value: barang.sudahDibeli,
                    onChanged: (_) {
                      context
                          .read<BelanjaModel>()
                          .toggleDibeli(index);
                    },
                  ),

                  // Nama barang
                  title: Text(
                    barang.nama,
                    style: TextStyle(
                      fontSize: 17,
                      decoration: barang.sudahDibeli
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  // Jumlah dan kategori
                  subtitle: Text(
                    '${barang.jumlah} • ${barang.kategori}',
                  ),

                  // Tombol hapus
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context
                          .read<BelanjaModel>()
                          .hapusBarang(index);
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final berhasil = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahBarangPage(),
            ),
          );

          // SnackBar setelah berhasil menambahkan barang
          if (berhasil == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Barang ditambahkan'),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TambahBarangPage extends StatefulWidget {
  const TambahBarangPage({super.key});

  @override
  State<TambahBarangPage> createState() =>
      _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Controller
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();

  // Menyimpan kategori yang dipilih
  String? _kategori;

  // Daftar kategori
  final List<String> _kategoriList = [
    'Makanan',
    'Minuman',
    'Kebutuhan Rumah',
    'Elektronik',
    'Lainnya',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _simpan() {
    // Jalankan validasi
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nama = _namaController.text.trim();

    final jumlah = int.parse(
      _jumlahController.text.trim(),
    );

    // Tambahkan ke Provider
    context.read<BelanjaModel>().tambahBarang(
          nama: nama,
          jumlah: jumlah,
          kategori: _kategori!,
        );

    // Kembali ke halaman daftar
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Barang'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  hintText: 'Contoh: Beras',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Nama barang wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  hintText: 'Contoh: 1',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Jumlah wajib diisi';
                  }

                  final jumlah = int.tryParse(
                    value.trim(),
                  );

                  if (jumlah == null) {
                    return 'Jumlah harus berupa angka';
                  }

                  if (jumlah <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _kategori,

                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),

                items: _kategoriList.map((kategori) {
                  return DropdownMenuItem<String>(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    _kategori = value;
                  });
                },

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori wajib dipilih';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: _simpan,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}