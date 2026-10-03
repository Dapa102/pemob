import 'package:flutter/material.dart';

void main() {
  runApp(const KartuPerkenalanApp());
}

class KartuPerkenalanApp extends StatelessWidget {
  const KartuPerkenalanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Kartu Perkenalan'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Foto / Ikon
              const Icon(
                Icons.account_circle,
                size: 120,
              ),

              const SizedBox(height: 20),

              // Nama
              const Text(
                'Dafa Rafi Nurwansyah',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // NIM
              const Text(
                'NIM: 20240801157',
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 10),

              // Jurusan
              const Text(
                'Teknik Informatika',
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}