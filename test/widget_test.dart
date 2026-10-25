// Smoke test aplikasi utama (Pertemuan 6) yang dipakai sebagai pintu masuk
// proyek. Test bawaan counter sudah tidak relevan karena main.dart telah
// diganti dengan aplikasi praktikum.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum/main.dart';

void main() {
  testWidgets('aplikasi menampilkan navigasi utama', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Beranda'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();

    expect(find.text('Mode gelap'), findsOneWidget);
  });
}
