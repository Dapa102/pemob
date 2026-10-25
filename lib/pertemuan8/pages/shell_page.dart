import 'package:flutter/material.dart';

import 'info_server_page.dart';
import 'pengaturan_api_page.dart';
import 'status_server_page.dart';

/// Kerangka tiga tab: Status Server, Info Server, dan Pengaturan.
class ShellPage extends StatefulWidget {
  final int tabAwal;

  const ShellPage({super.key, this.tabAwal = 0});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  late int _index = widget.tabAwal.clamp(0, 2);

  static const _halaman = [
    StatusServerPage(),
    InfoServerPage(),
    PengaturanApiPage(),
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
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud),
            label: 'Status',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'Info',
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
