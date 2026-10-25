// Model JSON untuk lapisan API Pertemuan 9.
// Bedanya dengan toMap() SQLite: selesai berupa boolean dan id tidak dikirim
// saat POST karena sudah ada di URL.

enum Tipe { tanpa, pemasukan, pengeluaran }

extension TipeLabel on Tipe {
  String get label => switch (this) {
    Tipe.tanpa => 'Tidak melibatkan uang',
    Tipe.pemasukan => 'Pemasukan',
    Tipe.pengeluaran => 'Pengeluaran',
  };
}

class Kegiatan {
  final int? id;
  final String judul;
  final String tanggal;
  final bool selesai;
  final Tipe tipe;
  final int nominal;
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

  /// JSON untuk POST/PUT. id tidak dikirim karena ada di URL.
  Map<String, Object?> toJson() => {
    'judul': judul,
    'tanggal': tanggal,
    'selesai': selesai,
    'tipe': tipe.name,
    'nominal': nominal,
    'kategori': kategori,
  };

  factory Kegiatan.fromJson(Map<String, dynamic> j) => Kegiatan(
    id: j['id'] as int,
    judul: j['judul'] as String,
    tanggal: j['tanggal'] as String,
    selesai: j['selesai'] as bool,
    tipe: Tipe.values.byName(j['tipe'] as String),
    nominal: j['nominal'] as int,
    kategori: j['kategori'] as String,
  );
}

class KategoriTotal {
  final String kategori;
  final int total;

  const KategoriTotal(this.kategori, this.total);

  factory KategoriTotal.fromJson(Map<String, dynamic> j) =>
      KategoriTotal(j['kategori'] as String, j['total'] as int);
}

/// Ringkasan laporan dari GET /laporan/harian atau /laporan/rentang.
class Ringkasan {
  final int jumlahKegiatan;
  final int selesai;
  final int pemasukan;
  final int pengeluaran;
  final int tabungan;

  const Ringkasan({
    required this.jumlahKegiatan,
    required this.selesai,
    required this.pemasukan,
    required this.pengeluaran,
    required this.tabungan,
  });

  factory Ringkasan.fromJson(Map<String, dynamic> j) => Ringkasan(
    jumlahKegiatan: j['jumlah_kegiatan'] as int,
    selesai: j['selesai'] as int,
    pemasukan: j['pemasukan'] as int,
    pengeluaran: j['pengeluaran'] as int,
    tabungan: j['tabungan'] as int,
  );
}

class LaporanHarian {
  final String tanggal;
  final Ringkasan ringkasan;
  final List<KategoriTotal> perKategori;

  const LaporanHarian({
    required this.tanggal,
    required this.ringkasan,
    required this.perKategori,
  });

  factory LaporanHarian.fromJson(Map<String, dynamic> j) => LaporanHarian(
    tanggal: j['tanggal'] as String,
    ringkasan: Ringkasan.fromJson(j),
    perKategori: [
      for (final e in (j['per_kategori'] as List<dynamic>? ?? []))
        KategoriTotal.fromJson(e as Map<String, dynamic>),
    ],
  );
}

class HariLaporan {
  final String tanggal;
  final Ringkasan ringkasan;

  const HariLaporan({required this.tanggal, required this.ringkasan});

  factory HariLaporan.fromJson(Map<String, dynamic> j) => HariLaporan(
    tanggal: j['tanggal'] as String,
    ringkasan: Ringkasan.fromJson(j),
  );
}

class LaporanRentang {
  final String mulai;
  final String sampai;
  final int jumlahHari;
  final List<HariLaporan> hari;

  const LaporanRentang({
    required this.mulai,
    required this.sampai,
    required this.jumlahHari,
    required this.hari,
  });

  factory LaporanRentang.fromJson(Map<String, dynamic> j) => LaporanRentang(
    mulai: j['mulai'] as String,
    sampai: j['sampai'] as String,
    jumlahHari: j['jumlah_hari'] as int,
    hari: [
      for (final e in (j['hari'] as List<dynamic>? ?? []))
        HariLaporan.fromJson(e as Map<String, dynamic>),
    ],
  );
}
