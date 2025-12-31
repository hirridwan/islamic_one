import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart'; 
import '../api_service.dart';
import '../models.dart';

class TafsirScreen extends StatefulWidget {
  final Surah surah;
  final int? initialAyat; // Jika ini diisi, maka hanya tampilkan ayat ini saja

  const TafsirScreen({super.key, required this.surah, this.initialAyat});

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  final ApiService api = ApiService();
  
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  late Future<List<Tafsir>> futureTafsir;

  @override
  void initState() {
    super.initState();
    futureTafsir = api.getTafsirSurah(widget.surah.nomor);
  }

  @override
  Widget build(BuildContext context) {
    // Judul AppBar dinamis: Jika per ayat, tampilkan nomor ayatnya
    String titleText = "Tafsir";
    if (widget.initialAyat != null) {
      titleText = "Tafsir Ayat ${widget.initialAyat}";
    }

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
              titleText, // Judul berubah sesuai konteks
              style: GoogleFonts.inter(
                fontSize: 14, 
                fontWeight: FontWeight.w400,
                color: Colors.white70
              ),
            ),
            Text(
              widget.surah.namaLatin,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, 
                fontSize: 18,
                color: Colors.white
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Tafsir>>(
        future: futureTafsir,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      "Gagal memuat data tafsir.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          futureTafsir = api.getTafsirSurah(widget.surah.nomor);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                      ),
                      child: const Text("Coba Lagi"),
                    )
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data Tafsir tidak tersedia"));
          }

          final List<Tafsir> allTafsir = snapshot.data!;
          List<Tafsir> displayedTafsir;

          // --- LOGIKA FILTERING ---
          if (widget.initialAyat != null) {
            // Jika user memilih "Lihat Tafsir Ayat Ini", filter list hanya untuk ayat tersebut
            displayedTafsir = allTafsir.where((t) => t.ayat == widget.initialAyat).toList();
          } else {
            // Jika user memilih "Lihat Semua", tampilkan semua
            displayedTafsir = allTafsir;
          }

          if (displayedTafsir.isEmpty) {
             return const Center(child: Text("Tafsir untuk ayat ini belum tersedia."));
          }

          return ScrollablePositionedList.builder(
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            padding: const EdgeInsets.all(16),
            itemCount: displayedTafsir.length,
            // Jika difilter (cuma 1 ayat), scroll index pasti 0.
            // Jika semua ayat, scroll ke posisi yang dituju (kalau ada logic scroll spesifik, tp disini kita mulai dari 0 karena list sudah difilter atau full)
            initialScrollIndex: 0, 
            itemBuilder: (context, index) {
              final tafsir = displayedTafsir[index];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Ayat
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF1B5E20), width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.menu_book, size: 16, color: Color(0xFF1B5E20)),
                              const SizedBox(width: 8),
                              Text(
                                "Tafsir Ayat ${tafsir.ayat}",
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF1B5E20),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Isi Tafsir
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade100)
                      ),
                      child: HtmlWidget(
                        tafsir.teks.replaceAll('\n', '<br>'),
                        textStyle: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.8, 
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}