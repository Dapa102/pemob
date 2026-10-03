import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Tugas {
  String judul;
  bool selesai;

  Tugas(this.judul, {this.selesai = false});
}

class TugasModel extends ChangeNotifier {
  final List<Tugas> _items = [];

  // Mengambil daftar tugas
  List<Tugas> get items => List.unmodifiable(_items);

  // Menghitung jumlah tugas yang sudah selesai
  int get jumlahSelesai {
    return _items.where((t) => t.selesai).length;
  }

  // Menambahkan tugas
  void tambah(String judul) {
    _items.add(Tugas(judul));
    notifyListeners();
  }

  // Mengubah status selesai/belum selesai
  void toggle(int index) {
    _items[index].selesai = !_items[index].selesai;
    notifyListeners();
  }

  // Menghapus tugas
  void hapus(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => TugasModel(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Tugas',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const TugasPage(),
    );
  }
}

class TugasPage extends StatelessWidget {
  const TugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // watch digunakan untuk mendengarkan perubahan data
    final model = context.watch<TugasModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tugas (${model.jumlahSelesai}/${model.items.length})'),
      ),

      body: model.items.isEmpty
          ? const Center(
              child: Text('Belum ada tugas', style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: model.items.length,
              itemBuilder: (context, index) {
                final tugas = model.items[index];

                return ListTile(
                  // Checkbox untuk mengubah status tugas
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

                  // Tombol hapus
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
            MaterialPageRoute(builder: (_) => const TambahPage()),
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
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fungsi menyimpan tugas
  void _simpan() {
    final judul = _controller.text.trim();

    // Jika kosong, jangan simpan
    if (judul.isEmpty) {
      return;
    }

    // Mengakses Provider tanpa rebuild
    context.read<TugasModel>().tambah(judul);

    // Kembali ke halaman daftar
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Judul tugas',
                border: OutlineInputBorder(),
              ),

              // Tekan Enter untuk menyimpan
              onSubmitted: (_) => _simpan(),
            ),

            const SizedBox(height: 12),

            // Tombol simpan
            ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
