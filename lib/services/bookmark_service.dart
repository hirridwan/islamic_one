import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String keySurah = 'last_read_surah';
  static const String keyAyat = 'last_read_ayat';
  static const String keySurahName = 'last_read_surah_name';

  // Simpan posisi terakhir baca
  Future<void> saveLastRead(int surahNomor, int ayatNomor, String surahNama) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keySurah, surahNomor);
    await prefs.setInt(keyAyat, ayatNomor);
    await prefs.setString(keySurahName, surahNama);
  }

  // Ambil data terakhir baca
  Future<Map<String, dynamic>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final int? surah = prefs.getInt(keySurah);
    final int? ayat = prefs.getInt(keyAyat);
    final String? nama = prefs.getString(keySurahName);

    if (surah != null && ayat != null && nama != null) {
      return {
        'surah': surah,
        'ayat': ayat,
        'nama': nama,
      };
    }
    return null;
  }
}