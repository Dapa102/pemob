import 'package:flutter/material.dart';

import '../../pertemuan8/pages/pengaturan_api_page.dart';
import 'kegiatan_page.dart';
import 'laporan_page.dart';

/// Tiga tab: Kegiatan, Laporan, dan Pengaturan alamat API.
class ShellPage extends StatefulWidget {
  final int tabAwal;
  final bool modeLatihan;

  const ShellPage({super.key, this.tabAwal = 0, this.modeLatihan = false});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  late int _index = widget.tabAwal.clamp(0, 2);
  late final List<Widget> _halaman = [
    KegiatanPage(modeLatihan: widget.modeLatihan),
    const LaporanPage(),
    const PengaturanApiPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Kegiatan',
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
