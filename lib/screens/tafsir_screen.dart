import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../api_service.dart';
import '../models.dart';

class TafsirScreen extends StatefulWidget {
  final Surah surah;
  const TafsirScreen({super.key, required this.surah});

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  final ApiService api = ApiService();
  late Future<List<Tafsir>> futureTafsir;

  @override
  void initState() {
    super.initState();
    futureTafsir = api.getTafsirSurah(widget.surah.nomor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tafsir",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            Text(
              widget.surah.namaLatin,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Tafsir>>(
        future: futureTafsir,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1B5E20),
              ),
            );
          }
          
          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      "Gagal memuat data tafsir.\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
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
                      ),
                      child: const Text("Coba Lagi"),
                    )
                  ],
                ),
              ),
            );
          }

          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data Tafsir tidak tersedia"));
          }

          final List<Tafsir> tafsirList = snapshot.data!;

          // 4. Success State
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tafsirList.length,
            itemBuilder: (context, index) {
              final tafsir = tafsirList[index];
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
                            color: const Color(0xFFE8F5E9), // Hijau sangat muda
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
                    // Menggunakan HtmlWidget karena teks dari API kadang mengandung format,
                    // atau SelectableText jika teks biasa. HtmlWidget lebih aman untuk data API Quran.
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: HtmlWidget(
                        // Mengganti \n menjadi <br> agar baris baru terbaca di HTML widget
                        tafsir.teks.replaceAll('\n', '<br>'),
                        textStyle: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.8, // Line height agar nyaman dibaca
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