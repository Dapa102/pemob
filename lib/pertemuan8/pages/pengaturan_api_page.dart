import 'package:flutter/material.dart';

import '../config/api_config.dart';

/// Pengaturan alamat API. Alamat disimpan dengan shared_preferences.
class PengaturanApiPage extends StatelessWidget {
  const PengaturanApiPage({super.key});

  Future<void> _ubahAlamat(BuildContext context) async {
    final hasil = await showDialog<String>(
      context: context,
      builder: (_) => DialogAlamatApi(awal: apiUrl.value),
    );
    if (hasil == null || !context.mounted) return;
    await simpanApiUrl(hasil);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Alamat API disimpan: $hasil')));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ValueListenableBuilder<String>(
        valueListenable: apiUrl,
        builder: (context, alamat, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Alamat API'),
                  subtitle: Text(alamat),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _ubahAlamat(context),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Alamat sesuai perangkat',
                style: tema.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.android),
                      title: Text('Emulator Android'),
                      subtitle: Text('http://10.0.2.2:8000'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.phone_iphone),
                      title: Text('Simulator iOS'),
                      subtitle: Text('http://localhost:8000'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.wifi),
                      title: Text('HP fisik (Wi-Fi sama)'),
                      subtitle: Text('http://IP-LAPTOP:8000'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Alamat juga dapat diatur saat menjalankan aplikasi:\n'
                'flutter run --dart-define=API_URL=http://192.168.1.10:8000',
                style: tema.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Card(
                color: tema.colorScheme.surfaceContainerHighest,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Catatan: http:// hanya untuk pengembangan. Untuk '
                    'produksi gunakan HTTPS dan hapus usesCleartextTraffic.',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Dialog ubah alamat dengan validasi format URL.
class DialogAlamatApi extends StatefulWidget {
  final String awal;

  const DialogAlamatApi({super.key, required this.awal});

  @override
  State<DialogAlamatApi> createState() => _DialogAlamatApiState();
}

class _DialogAlamatApiState extends State<DialogAlamatApi> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.awal,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alamat API'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'URL',
            hintText: 'http://10.0.2.2:8000',
          ),
          validator: validasiUrl,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _simpan, child: const Text('Simpan')),
      ],
    );
  }
}
