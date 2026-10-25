// Model data TabungKu (Pertemuan 7).
// Berkas ini hanya berisi struktur data; akses SQLite ada di data/db_helper.dart.

enum Tipe { tanpa, pemasukan, pengeluaran }

extension TipeLabel on Tipe {
  String get label => switch (this) {
    Tipe.tanpa => 'Tidak melibatkan uang',
    Tipe.pemasukan => 'Pemasukan',
    Tipe.pengeluaran => 'Pengeluaran',
  };

  /// Nilai yang disimpan di kolom `tipe` SQLite.
  String get nilai => name;
}

/// Satu kegiatan pada tanggal tertentu.
class Kegiatan {
  final int? id;
  final String judul;

  /// Disimpan sebagai teks yyyy-MM-dd agar mudah diurutkan dan dibandingkan.
  final String tanggal;
  final bool selesai;
  final Tipe tipe;
  final int nominal;

  /// Hanya diisi untuk pengeluaran; selain itu '-'.
  final String kategori;

  const Kegiatan({
    this.id,
    required this.judul,
    required this.tanggal,
    this.selesai = false,
    this.tipe = Tipe.tanpa,
    this.nominal = 0,
    this.kategori = '-',
  });

  Kegiatan copyWith({
    int? id,
    String? judul,
    String? tanggal,
    bool? selesai,
    Tipe? tipe,
    int? nominal,
    String? kategori,
  }) {
    return Kegiatan(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      tanggal: tanggal ?? this.tanggal,
      selesai: selesai ?? this.selesai,
      tipe: tipe ?? this.tipe,
      nominal: nominal ?? this.nominal,
      kategori: kategori ?? this.kategori,
    );
  }

  /// Konversi ke Map untuk SQLite. Boolean disimpan sebagai 0/1.
  Map<String, Object?> toMap() => {
    'id': id,
    'judul': judul,
    'tanggal': tanggal,
    'selesai': selesai ? 1 : 0,
    'tipe': tipe.nilai,
    'nominal': nominal,
    'kategori': kategori,
  };

  factory Kegiatan.fromMap(Map<String, Object?> m) => Kegiatan(
    id: m['id'] as int,
    judul: m['judul'] as String,
    tanggal: m['tanggal'] as String,
    selesai: (m['selesai'] as int) == 1,
    tipe: Tipe.values.byName(m['tipe'] as String),
    nominal: m['nominal'] as int,
    kategori: m['kategori'] as String,
  );
}

/// Angka ringkasan satu hari.
class Ringkasan {
  final int jumlahKegiatan;
  final int selesai;
  final int pemasukan;
  final int pengeluaran;

  const Ringkasan({
    this.jumlahKegiatan = 0,
    this.selesai = 0,
    this.pemasukan = 0,
    this.pengeluaran = 0,
  });

  /// Tabungan harian = pemasukan - pengeluaran.
  int get tabungan => pemasukan - pengeluaran;

  bool get negatif => tabungan < 0;
}

/// Data lengkap satu hari: ringkasan + daftar kegiatan.
class DataHari {
  final Ringkasan ringkasan;
  final List<Kegiatan> kegiatan;

  const DataHari({required this.ringkasan, required this.kegiatan});

  const DataHari.kosong() : ringkasan = const Ringkasan(), kegiatan = const [];
}

/// Laporan satu hari beserta rincian pengeluaran per kategori.
class LaporanHarian {
  final String tanggal;
  final Ringkasan ringkasan;

  /// Urut dari pengeluaran terbesar.
  final List<MapEntry<String, int>> perKategori;

  const LaporanHarian({
    required this.tanggal,
    required this.ringkasan,
    this.perKategori = const [],
  });
}

/// Ringkasan satu hari di dalam rentang 7 hari terakhir.
class HariLaporan {
  final String tanggal;
  final Ringkasan ringkasan;

  const HariLaporan(this.tanggal, this.ringkasan);
}
