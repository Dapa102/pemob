import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Aplikasi utama
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 3',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const FormPage(),
    );
  }
}

// Halaman Form Pendaftaran
class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  // Key untuk validasi Form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input nama dan email
  final _nama = TextEditingController();
  final _email = TextEditingController();

  // Menyimpan jurusan yang dipilih
  String? _jurusan;

  // Menyimpan status persetujuan
  bool _setuju = false;

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    super.dispose();
  }

  // Fungsi untuk mengirim form
  void _kirim() {
    if (_formKey.currentState!.validate()) {
      final jurusan = _jurusan ?? '-';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terdaftar: ${_nama.text} ($jurusan)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Pendaftaran')),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Input Nama
            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama lengkap',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            // Input Email
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email wajib diisi';
                }

                if (!value.contains('@')) {
                  return 'Email tidak valid';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            // Pilihan Jurusan
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Jurusan',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'TI',
                  child: Text('Teknik Informatika'),
                ),
                DropdownMenuItem(
                  value: 'SI', 
                  child: Text('Sistem Informasi')),
              ],
              onChanged: (value) {
                setState(() {
                  _jurusan = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Pilih jurusan';
                }

                return null;
              },
            ),

            const SizedBox(height: 8),

            // Checkbox Persetujuan
            CheckboxListTile(
              title: const Text('Saya menyetujui ketentuan'),
              value: _setuju,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {
                setState(() {
                  _setuju = value ?? false;
                });
              },
            ),

            const SizedBox(height: 8),

            // Tombol Daftar
            ElevatedButton(
              onPressed: _setuju ? _kirim : null,
              child: const Text('Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
