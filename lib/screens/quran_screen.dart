import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api_service.dart';
import '../models.dart';
import '../services/bookmark_service.dart';
import 'detail_surah_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final ApiService api = ApiService();
  final BookmarkService bookmarkService = BookmarkService();
  
  // --- STATE VARIABLES ---
  List<Surah> _allSurah = [];
  List<Surah> _filteredSurah = [];
  Map<String, dynamic>? _lastRead;
  
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIC: LOAD DATA ---
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });

      // Ambil data API dan Bookmark secara bersamaan (Parallel)
      final results = await Future.wait([
        api.getDaftarSurah(),
        bookmarkService.getLastRead(),
      ]);

      if (mounted) {
        setState(() {
          _allSurah = results[0] as List<Surah>;
          _filteredSurah = _allSurah; // Default tampilkan semua
          _lastRead = results[1] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // --- LOGIC: REFRESH BOOKMARK ---
  // Dipanggil saat kembali dari halaman detail
  void _refreshLastRead() async {
    final lastRead = await bookmarkService.getLastRead();
    if (mounted) {
      setState(() {
        _lastRead = lastRead;
      });
    }
  }

  // --- LOGIC: FILTER SEARCH ---
  void _filterSurah(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSurah = _allSurah;
      });
    } else {
      final lowerQuery = query.toLowerCase();
      final filtered = _allSurah.where((surah) {
        return surah.namaLatin.toLowerCase().contains(lowerQuery) || 
               surah.arti.toLowerCase().contains(lowerQuery) ||
               surah.nomor.toString().contains(lowerQuery);
      }).toList();

      setState(() {
        _filteredSurah = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APP BAR DENGAN SEARCH BAR ---
      appBar: AppBar(
        title: const Text('Al-Quran'),
        // Ruang di bawah title untuk Search Bar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80), 
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSurah,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Cari Surat (ex: Yasin, 36)...",
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1B5E20)),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _filterSurah('');
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
                filled: true,
                fillColor: Colors.white,
                // Border melengkung agar sesuai header
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
        ),
      ),
      
      // --- BODY CONTENT ---
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Loading State
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
    }

    // 2. Error State
    if (_isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text("Gagal memuat data: $_errorMessage", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
              child: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    // 3. Empty Search State
    if (_filteredSurah.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text("Surat tidak ditemukan", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    // 4. List Data
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF1B5E20),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        // Item count +1 jika widget Last Read muncul
        itemCount: (_lastRead != null && _searchController.text.isEmpty) 
            ? _filteredSurah.length + 1 
            : _filteredSurah.length,
        itemBuilder: (context, index) {
          // --- WIDGET LAST READ (Hanya muncul jika tidak sedang search) ---
          if (_lastRead != null && _searchController.text.isEmpty) {
            if (index == 0) {
              return _buildLastReadWidget();
            }
            // Geser index data karena index 0 dipakai header
            return _buildSurahItem(_filteredSurah[index - 1]);
          }

          // --- LIST SURAT BIASA ---
          return _buildSurahItem(_filteredSurah[index]);
        },
      ),
    );
  }

  // --- WIDGET: KARTU TERAKHIR DIBACA ---
  Widget _buildLastReadWidget() {
    return InkWell(
      onTap: () async {
        try {
          // Cari surat berdasarkan ID yang tersimpan
          final targetSurah = _allSurah.firstWhere(
            (s) => s.nomor == _lastRead!['surah'],
          );
          // Buka Detail Surah & Scroll ke Ayat
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailSurahScreen(
                surah: targetSurah,
                initialAyat: _lastRead!['ayat'], 
              ),
            ),
          );
          _refreshLastRead(); // Refresh saat kembali
        } catch (e) {
          // Handle jika data bookmark error
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFE65100), Colors.orange.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Terakhir Dibaca",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 12,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_lastRead!['nama']}",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "Ayat ${_lastRead!['ayat']}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: ITEM SURAT ---
  Widget _buildSurahItem(Surah surah) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailSurahScreen(surah: surah),
              ),
            );
            _refreshLastRead(); // Refresh saat kembali
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Nomor Surat (Container Hijau)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), // Hijau sangat muda
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${surah.nomor}',
                    style: const TextStyle(
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info Surat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.namaLatin,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            surah.tempatTurun,
                            style: TextStyle(
                              color: Colors.grey[600], 
                              fontSize: 12,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle
                            ),
                          ),
                          Text(
                            "${surah.jumlahAyat} Ayat",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Nama Arab
                Text(
                  surah.nama,
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}