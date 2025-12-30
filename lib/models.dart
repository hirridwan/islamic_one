class Surah {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;

  Surah({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      nomor: json['nomor'],
      nama: json['nama'],
      namaLatin: json['namaLatin'],
      jumlahAyat: json['jumlahAyat'],
      tempatTurun: json['tempatTurun'],
      arti: json['arti'],
      deskripsi: json['deskripsi'],
    );
  }
}

class Ayat {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;

  Ayat({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      nomorAyat: json['nomorAyat'],
      teksArab: json['teksArab'],
      teksLatin: json['teksLatin'],
      teksIndonesia: json['teksIndonesia'],
    );
  }
}

class Tafsir {
  final int ayat;
  final String teks;

  Tafsir({required this.ayat, required this.teks});

  factory Tafsir.fromJson(Map<String, dynamic> json) {
    return Tafsir(
      ayat: json['ayat'],
      teks: json['teks'],
    );
  }
}

// --- MODEL BARU: DOA ---
class Doa {
  final int id;
  final String nama;
  final String arab;
  final String latin; // 'tr' dalam JSON
  final String indo; // 'idn' dalam JSON
  final String tentang;
  final String grup;

  Doa({
    required this.id,
    required this.nama,
    required this.arab,
    required this.latin,
    required this.indo,
    required this.tentang,
    required this.grup,
  });

  factory Doa.fromJson(Map<String, dynamic> json) {
    return Doa(
      id: json['id'],
      nama: json['nama'],
      arab: json['ar'],
      latin: json['tr'],
      indo: json['idn'],
      tentang: json['tentang'] ?? '',
      grup: json['grup'] ?? '',
    );
  }
}