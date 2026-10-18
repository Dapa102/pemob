// Model data untuk tugas Pertemuan 4 (Daftar Postingan).
// Berkas ini terpisah dari kode UI agar struktur kode lebih rapi.

class Postingan {
  final int userId;
  final int id;
  final String judul;
  final String isi;

  const Postingan({
    required this.userId,
    required this.id,
    required this.judul,
    required this.isi,
  });

  factory Postingan.fromJson(Map<String, dynamic> json) {
    return Postingan(
      userId: json['userId'] as int,
      id: json['id'] as int,
      judul: json['title'] as String,
      isi: json['body'] as String,
    );
  }
}

class Komentar {
  final int postId;
  final int id;
  final String nama;
  final String email;
  final String isi;

  const Komentar({
    required this.postId,
    required this.id,
    required this.nama,
    required this.email,
    required this.isi,
  });

  factory Komentar.fromJson(Map<String, dynamic> json) {
    return Komentar(
      postId: json['postId'] as int,
      id: json['id'] as int,
      nama: json['name'] as String,
      email: json['email'] as String,
      isi: json['body'] as String,
    );
  }
}
