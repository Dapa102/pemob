// Utilitas format untuk lapisan API Pertemuan 9.

String formatRupiah(int angka) {
  final negatif = angka < 0;
  final teks = angka.abs().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return negatif ? '-$teks' : teks;
}

String tanggalIso(DateTime t) {
  final y = t.year.toString().padLeft(4, '0');
  final m = t.month.toString().padLeft(2, '0');
  final d = t.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime parseTanggalIso(String t) => DateTime.parse(t);

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

String labelPendek(String tanggal) {
  final t = parseTanggalIso(tanggal);
  return '${t.day.toString().padLeft(2, '0')}/'
      '${t.month.toString().padLeft(2, '0')}';
}
