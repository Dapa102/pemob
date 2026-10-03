import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Tugas {
  String judul;
  bool selesai;

  Tugas(
    this.judul, {
    this.selesai = false,
  });
}

class TugasModel extends ChangeNotifier {
  final List<Tugas> _items = [];

  // Mengambil daftar tugas
  List<Tugas> get items => List.unmodifiable(_items);

  // Menghitung jumlah tugas yang selesai
  int get jumlahSelesai {
    return _items.where((t) => t.selesai).length;
  }

  // Menambahkan tugas
  void tambah(String judul) {
    _items.add(Tugas(judul));
    notifyListeners();
  }

  // Mengubah status tugas
  void toggle(int index) {
    _items[index].selesai = !_items[index].selesai;
    notifyListeners();
  }

  // Menghapus satu tugas
  void hapus(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  // Menghapus semua tugas yang sudah selesai
  void hapusSelesai() {
    _items.removeWhere((tugas) => tugas.selesai);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TugasModel(),
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
      title: 'Daftar Tugas',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const TugasPage(),
    );
  }
}

class TugasPage extends StatelessWidget {
  const TugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TugasModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tugas (${model.jumlahSelesai}/${model.items.length})',
        ),

        // Tombol hapus semua tugas yang selesai
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus tugas selesai',
            onPressed: model.jumlahSelesai == 0
                ? null
                : () {
                    context.read<TugasModel>().hapusSelesai();
                  },
          ),
        ],
      ),

      // Jika daftar kosong
      body: model.items.isEmpty
          ? const Center(
              child: Text(
                'Belum ada tugas',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              itemCount: model.items.length,
              itemBuilder: (context, index) {
                final tugas = model.items[index];

                return ListTile(
                  // Checkbox tugas
                  leading: Checkbox(
                    value: tugas.selesai,
                    onChanged: (_) {
                      context.read<TugasModel>().toggle(index);
                    },
                  ),

                  // Judul tugas
                  title: Text(
                    tugas.judul,
                    style: TextStyle(
                      decoration: tugas.selesai
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  // Tombol hapus satu tugas
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<TugasModel>().hapus(index);
                    },
                  ),
                );
              },
            ),

      // Tombol tambah tugas
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TambahPage extends StatefulWidget {
  const TambahPage({super.key});

  @override
  State<TambahPage> createState() => _TambahPageState();
}

class _TambahPageState extends State<TambahPage> {
  final _formKey = GlobalKey<FormState>();

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fungsi menyimpan tugas
  void _simpan() {
    // Jalankan validasi Form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final judul = _controller.text.trim();

    // Tambahkan tugas menggunakan Provider
    context.read<TugasModel>().tambah(judul);

    // Kembali ke halaman sebelumnya
    Navigator.pop(context);

    // Tampilkan SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tugas ditambahkan'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tugas'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Input judul tugas
              TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Judul tugas',
                  border: OutlineInputBorder(),
                ),

                // Validasi minimal 3 karakter
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tugas wajib diisi';
                  }

                  if (value.trim().length < 3) {
                    return 'Judul minimal 3 karakter';
                  }

                  return null;
                },

                // Tekan Enter untuk menyimpan
                onFieldSubmitted: (_) {
                  _simpan();
                },
              ),

              const SizedBox(height: 12),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _simpan,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}