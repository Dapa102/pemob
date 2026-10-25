import 'pertemuan9.dart';

// Tugas Pertemuan 9:
// - Endpoint GET /laporan/harian dan GET /laporan/rentang dihitung di SQL.
// - Flutter: LaporanHarian, LaporanRentang, LaporanApi + unit test MockClient.
// - Aplikasi ini langsung membuka tab Laporan untuk memeriksa hasilnya.
//
// Contoh skenario modul 7 (4 kegiatan, 2 selesai, masuk 50.000,
// keluar 25.000, tabungan 25.000) dapat dimasukkan lewat tab Kegiatan.

Future<void> main() =>
    jalankanApiApp(judul: 'TabungKu Cloud - Laporan', tabAwal: 1);
