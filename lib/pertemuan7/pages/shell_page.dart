import 'package:flutter/material.dart';

import 'beranda_page.dart';
import 'laporan_page.dart';
import 'pengaturan_page.dart';

/// Kerangka utama dengan NavigationBar tiga tab.
class ShellPage extends StatefulWidget {
  final String judul;
  final bool fiturLanjutan;

  const ShellPage({
    super.key,
    this.judul = 'TabungKu',
    this.fiturLanjutan = false,
  });

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  late final List<Widget> _halaman = [
    BerandaPage(fiturLanjutan: widget.fiturLanjutan),
    LaporanPage(fiturLanjutan: widget.fiturLanjutan),
    const PengaturanPage(),
  ];

  static const _judulTab = ['Hari Ini', 'Laporan', 'Pengaturan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.judul} · ${_judulTab[_index]}')),
      body: IndexedStack(index: _index, children: _halaman),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/form'),
              icon: const Icon(Icons.add),
              label: const Text('Kegiatan'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hari Ini',
          ),
          NavigationDestination(
            icon: Icon(Icons.insert_chart_outlined),
            selectedIcon: Icon(Icons.insert_chart),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
