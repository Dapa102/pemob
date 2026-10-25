// Utilitas format tanggal dan rupiah untuk TabungKu.

/// 15000 -> "15.000"; -25000 -> "-25.000".
String formatRupiah(int angka) {
  final negatif = angka < 0;
  final teks = angka.abs().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return negatif ? '-$teks' : teks;
}

/// DateTime -> "yyyy-MM-dd" (format yang disimpan di SQLite).
String tanggalIso(DateTime tanggal) {
  final y = tanggal.year.toString().padLeft(4, '0');
  final m = tanggal.month.toString().padLeft(2, '0');
  final d = tanggal.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// "2026-10-06" -> DateTime(2026, 10, 6).
DateTime parseTanggalIso(String tanggal) => DateTime.parse(tanggal);

/// "2026-10-06" -> "06 Oktober 2026".
String formatTanggalPanjang(String tanggal) {
  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final t = parseTanggalIso(tanggal);
  return '${t.day.toString().padLeft(2, '0')} '
      '${bulan[t.month - 1]} ${t.year}';
}

/// "2026-10-06" -> "Selasa".
String namaHari(String tanggal) {
  const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  return hari[parseTanggalIso(tanggal).weekday - 1];
}

/// Label pendek untuk grafik 7 hari: "06/10".
String labelTanggalPendek(String tanggal) {
  final t = parseTanggalIso(tanggal);
  return '${t.day.toString().padLeft(2, '0')}/'
      '${t.month.toString().padLeft(2, '0')}';
}
