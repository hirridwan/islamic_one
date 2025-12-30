import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:provider/provider.dart';
import '../api_service.dart';
import '../models.dart';
import '../services/bookmark_service.dart';
import '../providers/settings_provider.dart';
import 'tafsir_screen.dart';

class DetailSurahScreen extends StatefulWidget {
  final Surah surah;
  final int? initialAyat;

  const DetailSurahScreen({super.key, required this.surah, this.initialAyat});

  @override
  State<DetailSurahScreen> createState() => _DetailSurahScreenState();
}

class _DetailSurahScreenState extends State<DetailSurahScreen> {
  final ApiService api = ApiService();
  final BookmarkService bookmarkService = BookmarkService();
  final AudioPlayer audioPlayer = AudioPlayer();
  
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  // Ubah ini agar tidak langsung diisi, tapi via fungsi
  late Future<List<Ayat>> futureAyat;
  
  bool _isDescriptionExpanded = false;
  int? _playingAyatIndex;
  bool _isAudioLoading = false;
  int? _currentBookmarkAyat; 

  @override
  void initState() {
    super.initState();
    _fetchData(); // Panggil fungsi fetch data
    _checkBookmark();
    
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _playingAyatIndex = null;
        });
      }
    });
  }

  // FUNGSI BARU: Untuk memuat data (bisa dipanggil ulang saat error)
  void _fetchData() {
    setState(() {
      futureAyat = api.getDetailSurah(widget.surah.nomor);
    });
  }

  Future<void> _checkBookmark() async {
    final lastRead = await bookmarkService.getLastRead();
    if (mounted && lastRead != null && lastRead['surah'] == widget.surah.nomor) {
      setState(() {
        _currentBookmarkAyat = lastRead['ayat'];
      });
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  // ... (Fungsi _playAudio dan _saveBookmark TETAP SAMA, tidak perlu diubah) ...
  Future<void> _playAudio(String url, int index) async {
    try {
      if (_playingAyatIndex == index) {
        await audioPlayer.stop();
        setState(() => _playingAyatIndex = null);
      } else {
        setState(() {
          _isAudioLoading = true;
          _playingAyatIndex = index;
        });
        await audioPlayer.setUrl(url);
        await audioPlayer.play();
        setState(() => _isAudioLoading = false);
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memutar audio: $e")),
        );
        setState(() {
          _isAudioLoading = false;
          _playingAyatIndex = null;
        });
      }
    }
  }

  Future<void> _saveBookmark(int ayatNum) async {
    await bookmarkService.saveLastRead(
      widget.surah.nomor, 
      ayatNum, 
      widget.surah.namaLatin
    );
    
    if (mounted) {
      setState(() {
        _currentBookmarkAyat = ayatNum;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ditandai: ${widget.surah.namaLatin} Ayat $ayatNum"),
          backgroundColor: const Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5, 
        title: Text(
          widget.surah.namaLatin,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'Lihat Tafsir',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TafsirScreen(surah: widget.surah),
                ),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<List<Ayat>>(
        future: futureAyat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
          } 
          
          // --- BAGIAN INI YANG MENGUBAH TAMPILAN ERROR ---
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    Text(
                      "Yah, koneksi internet terputus...",
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Pastikan internet kamu nyala untuk mengunduh surat ini pertama kali.",
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _fetchData, // Tombol Coba Lagi
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // -------------------------------------------------

          final List<Ayat> ayatList = snapshot.data!;

          return ScrollablePositionedList.builder( 
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: ayatList.length + 1,
            initialScrollIndex: widget.initialAyat ?? 0,
            itemBuilder: (context, index) {
              if (index == 0) return _buildHeaderSurahV2();
              final ayat = ayatList[index - 1];
              return _buildAyatItemV2(ayat, index - 1);
            },
          );
        },
      ),
    );
  }

  // ... (SISA KODE _buildHeaderSurahV2 dan _buildAyatItemV2 TETAP SAMA, TIDAK PERLU DIUBAH) ...
  // Paste ulang fungsi widget _buildHeaderSurahV2 dan _buildAyatItemV2 dari kode sebelumnya di sini
  // agar tidak terlalu panjang jawabannya, karena bagian itu tidak berubah.
  
  Widget _buildHeaderSurahV2() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1B5E20), Colors.green.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.surah.nama,
            style: GoogleFonts.amiri(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20)
            ),
            child: Text(
              "${widget.surah.arti} • ${widget.surah.tempatTurun}",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${widget.surah.jumlahAyat} Ayat",
             style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
          const SizedBox(height: 16),
          
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Column(
              children: [
                HtmlWidget(
                  widget.surah.deskripsi,
                  textStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 16),
              ],
            ),
            crossFadeState: _isDescriptionExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.3))
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isDescriptionExpanded ? "Tutup" : "Baca Deskripsi",
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isDescriptionExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyatItemV2(Ayat ayat, int index) {
    final settings = Provider.of<SettingsProvider>(context);
    String audioUrl = "https://cdn.equran.id/audio-partial/Misyari-Rasyid-Al-Afasi/${widget.surah.nomor.toString().padLeft(3, '0')}${ayat.nomorAyat.toString().padLeft(3, '0')}.mp3"; 
    bool isPlaying = _playingAyatIndex == index;
    bool isBookmarked = _currentBookmarkAyat == ayat.nomorAyat;
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? Colors.transparent : Colors.grey.shade200, 
            width: 1
          )
        ),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), 
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1B5E20).withOpacity(0.3), width: 1)
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${ayat.nomorAyat}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1B5E20),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _playAudio(audioUrl, index),
                        icon: _isAudioLoading && isPlaying
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1B5E20)))
                            : Icon(
                                isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_outline_rounded, 
                                color: isPlaying ? const Color(0xFF1B5E20) : Colors.grey.shade400
                              ),
                        tooltip: isPlaying ? 'Stop' : 'Putar Audio',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () => _saveBookmark(ayat.nomorAyat),
                        icon: Icon(
                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, 
                          color: isBookmarked ? const Color(0xFF1B5E20) : Colors.grey.shade400
                        ),
                        tooltip: 'Tandai Terakhir Baca',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: Text(
                  ayat.teksArab,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(
                    fontSize: settings.arabicFontSize,
                    height: 2.4, 
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                ayat.teksLatin,
                textAlign: TextAlign.left,
                style: GoogleFonts.inter(
                  fontSize: settings.latinFontSize,
                  color: const Color(0xFF1B5E20), 
                  fontWeight: FontWeight.w500, 
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                ayat.teksIndonesia,
                textAlign: TextAlign.left,
                style: GoogleFonts.inter(
                  fontSize: settings.latinFontSize,
                  color: isDark ? Colors.white70 : Colors.black54, 
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}