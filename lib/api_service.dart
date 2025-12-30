import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import ini wajib
import 'models.dart';

class ApiService {
  static const String baseUrlQuran = 'https://equran.id/api/v2';
  static const String baseUrlDoa = 'https://equran.id/api';

  // --- 1. GET DAFTAR SURAH (Dengan Cache) ---
  Future<List<Surah>> getDaftarSurah() async {
    const String cacheKey = 'cache_daftar_surah';
    final prefs = await SharedPreferences.getInstance();

    // A. Cek apakah ada data di HP?
    if (prefs.containsKey(cacheKey)) {
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        // Parse data dari cache
        final Map<String, dynamic> json = jsonDecode(cachedData);
        final List<dynamic> data = json['data'];
        return data.map((e) => Surah.fromJson(e)).toList();
      }
    }

    // B. Jika tidak ada, ambil dari Internet
    try {
      final response = await http.get(Uri.parse('$baseUrlQuran/surat'));
      if (response.statusCode == 200) {
        // Simpan data mentah ke HP
        await prefs.setString(cacheKey, response.body);
        
        // Parse data dari internet
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        return data.map((e) => Surah.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat daftar surat');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // --- 2. GET DETAIL SURAH (Dengan Cache) ---
  Future<List<Ayat>> getDetailSurah(int nomor) async {
    final String cacheKey = 'cache_detail_surah_$nomor'; // Key unik per surat
    final prefs = await SharedPreferences.getInstance();

    // A. Cek Cache
    if (prefs.containsKey(cacheKey)) {
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final Map<String, dynamic> json = jsonDecode(cachedData);
        final List<dynamic> ayatData = json['data']['ayat'];
        return ayatData.map((e) => Ayat.fromJson(e)).toList();
      }
    }

    // B. Ambil Internet
    try {
      final response = await http.get(Uri.parse('$baseUrlQuran/surat/$nomor'));
      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, response.body);

        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> ayatData = json['data']['ayat'];
        return ayatData.map((e) => Ayat.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat detail surat');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // --- 3. GET TAFSIR SURAH (Dengan Cache) ---
  Future<List<Tafsir>> getTafsirSurah(int nomor) async {
    final String cacheKey = 'cache_tafsir_surah_$nomor';
    final prefs = await SharedPreferences.getInstance();

    // A. Cek Cache
    if (prefs.containsKey(cacheKey)) {
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final Map<String, dynamic> json = jsonDecode(cachedData);
        final List<dynamic> tafsirData = json['data']['tafsir'];
        return tafsirData.map((e) => Tafsir.fromJson(e)).toList();
      }
    }

    // B. Ambil Internet
    try {
      final response = await http.get(Uri.parse('$baseUrlQuran/tafsir/$nomor'));
      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, response.body);

        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> tafsirData = json['data']['tafsir'];
        return tafsirData.map((e) => Tafsir.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat tafsir');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // --- 4. GET DAFTAR DOA (Dengan Cache) ---
  Future<List<Doa>> getDaftarDoa() async {
    const String cacheKey = 'cache_daftar_doa';
    final prefs = await SharedPreferences.getInstance();

    // A. Cek Cache
    if (prefs.containsKey(cacheKey)) {
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final Map<String, dynamic> json = jsonDecode(cachedData);
        final List<dynamic> data = json['data'];
        return data.map((e) => Doa.fromJson(e)).toList();
      }
    }

    // B. Ambil Internet
    try {
      final response = await http.get(Uri.parse('$baseUrlDoa/doa'));
      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, response.body);

        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        return data.map((e) => Doa.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat daftar doa');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // --- 5. GET DETAIL DOA (Dengan Cache) ---
  Future<Doa> getDetailDoa(int id) async {
    final String cacheKey = 'cache_detail_doa_$id';
    final prefs = await SharedPreferences.getInstance();

    // A. Cek Cache
    if (prefs.containsKey(cacheKey)) {
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final Map<String, dynamic> json = jsonDecode(cachedData);
        final Map<String, dynamic> data = json['data'];
        return Doa.fromJson(data);
      }
    }

    // B. Ambil Internet
    try {
      final response = await http.get(Uri.parse('$baseUrlDoa/doa/$id'));
      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, response.body);

        final Map<String, dynamic> json = jsonDecode(response.body);
        final Map<String, dynamic> data = json['data'];
        return Doa.fromJson(data);
      } else {
        throw Exception('Gagal memuat detail doa');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }
}