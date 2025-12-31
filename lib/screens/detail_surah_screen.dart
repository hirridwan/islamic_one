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

  late Future<List<Ayat>> futureAyat;
  
  int? _playingAyatIndex;
  bool _isAudioLoading = false;
  int? _currentBookmarkAyat; 

  @override
  void initState() {
    super.initState();
    _fetchData();
    _checkBookmark();
    
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _playingAyatIndex = null;
        });
      }
    });
  }

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
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ditandai: ${widget.surah.namaLatin} Ayat $ayatNum"),
          backgroundColor: const Color(0xFF1B5E20),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showSurahInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.surah.namaLatin,
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20)),
                  ),
                  Text(
                    widget.surah.nama,
                    style: GoogleFonts.amiri(fontSize: 28, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Chip(label: Text(widget.surah.tempatTurun), backgroundColor: const Color(0xFFE8F5E9)),
                      const SizedBox(width: 8),
                      Chip(label: Text("${widget.surah.jumlahAyat} Ayat"), backgroundColor: const Color(0xFFE8F5E9)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("Deskripsi", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  HtmlWidget(
                    widget.surah.deskripsi,
                    textStyle: GoogleFonts.inter(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAyatOptionMenu(Ayat ayat, int index) {
    String audioUrl = "https://cdn.equran.id/audio-partial/Misyari-Rasyid-Al-Afasi/${widget.surah.nomor.toString().padLeft(3, '0')}${ayat.nomorAyat.toString().padLeft(3, '0')}.mp3";
    bool isPlaying = _playingAyatIndex == index;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Ayat ${ayat.nomorAyat}",
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Divider(),
              
              // 1. Putar Audio
              ListTile(
                leading: Icon(
                  isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline, 
                  color: const Color(0xFF1B5E20), size: 28
                ),
                title: Text(isPlaying ? "Hentikan Audio" : "Putar Audio"),
                onTap: () {
                  Navigator.pop(context);
                  _playAudio(audioUrl, index);
                },
              ),

              // 2. Tandai Terakhir Baca
              ListTile(
                leading: const Icon(Icons.bookmark_border, color: Color(0xFF1B5E20), size: 28),
                title: const Text("Tandai Terakhir Baca"),
                onTap: () => _saveBookmark(ayat.nomorAyat),
              ),

              // 3. Lihat Tafsir Ayat Ini
              ListTile(
                leading: const Icon(Icons.description_outlined, color: Color(0xFF1B5E20), size: 28),
                title: const Text("Lihat Tafsir Ayat Ini"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TafsirScreen(
                        surah: widget.surah, 
                        initialAyat: ayat.nomorAyat 
                      ),
                    ),
                  );
                },
              ),

              // 4. Lihat Tafsir Semua Ayat
              ListTile(
                leading: const Icon(Icons.library_books_outlined, color: Color(0xFF1B5E20), size: 28),
                title: const Text("Lihat Tafsir Semua Ayat"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TafsirScreen(surah: widget.surah),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1B5E20), 
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.surah.namaLatin,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            Text(
              "${widget.surah.arti} • ${widget.surah.jumlahAyat} Ayat",
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showSurahInfo,
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
            tooltip: "Info Surat",
          )
        ],
      ),
      body: FutureBuilder<List<Ayat>>(
        future: futureAyat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
          } else if (snapshot.hasError) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text("Gagal memuat data", style: GoogleFonts.inter()),
                  TextButton(onPressed: _fetchData, child: const Text("Coba Lagi"))
                ],
              ),
            );
          }

          final List<Ayat> ayatList = snapshot.data!;

          return ScrollablePositionedList.builder(
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            itemCount: ayatList.length, 
            initialScrollIndex: widget.initialAyat != null ? (widget.initialAyat! - 1).clamp(0, ayatList.length - 1) : 0,
            itemBuilder: (context, index) {
              final ayat = ayatList[index];
              return _buildContinuousAyatItem(ayat, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildContinuousAyatItem(Ayat ayat, int index) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    bool isPlaying = _playingAyatIndex == index;
    bool isBookmarked = _currentBookmarkAyat == ayat.nomorAyat;

    return InkWell(
      // --- PERUBAHAN DI SINI: Menggunakan onTap menggantikan onLongPress ---
      onTap: () => _showAyatOptionMenu(ayat, index), 
      // -------------------------------------------------------------------
      child: Container(
        color: isPlaying 
            ? const Color(0xFF1B5E20).withOpacity(0.1) 
            : (isDark ? Colors.black : Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1B5E20), width: 1.5)
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${ayat.nomorAyat}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, 
                          fontSize: 14,
                          color: const Color(0xFF1B5E20)
                        ),
                      ),
                    ),
                    if (isBookmarked) 
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.bookmark, color: Color(0xFF1B5E20), size: 20),
                      ),
                  ],
                ),
                if (_isAudioLoading && isPlaying)
                   const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1B5E20))),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              ayat.teksArab,
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                fontSize: settings.arabicFontSize,
                height: 2.2,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              ayat.teksLatin,
              textAlign: TextAlign.left,
              style: GoogleFonts.inter(
                fontSize: settings.latinFontSize,
                color: const Color(0xFF1B5E20),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              ayat.teksIndonesia,
              textAlign: TextAlign.left,
              style: GoogleFonts.inter(
                fontSize: settings.latinFontSize,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 10),
            Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),
          ],
        ),
      ),
    );
  }
}