import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../api_service.dart';
import '../models.dart';
import '../providers/settings_provider.dart';

class DetailDoaScreen extends StatefulWidget {
  final int id;
  final String title;

  const DetailDoaScreen({super.key, required this.id, required this.title});

  @override
  State<DetailDoaScreen> createState() => _DetailDoaScreenState();
}

class _DetailDoaScreenState extends State<DetailDoaScreen> {
  final ApiService api = ApiService();
  late Future<Doa> futureDetailDoa;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      futureDetailDoa = api.getDetailDoa(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Doa"),
        elevation: 0,
      ),
      body: FutureBuilder<Doa>(
        future: futureDetailDoa,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
          } 
          
          // --- TAMPILAN ERROR YANG SUDAH DISAMAKAN ---
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
                      "Pastikan internet kamu nyala untuk mengunduh doa ini pertama kali.",
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _fetchData,
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
          // -------------------------------------------

          else if (!snapshot.hasData) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final doa = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- HEADER DOA ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF1B5E20), Colors.green.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B5E20).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        doa.nama,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Text(
                          doa.grup,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),

                // --- ARAB ---
                Text(
                  doa.arab,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: settings.arabicFontSize,
                    fontWeight: FontWeight.bold,
                    height: 2.2,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                
                const SizedBox(height: 30),

                // --- LATIN ---
                Card(
                  elevation: 0,
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? Colors.transparent : Colors.green.shade100, 
                      width: 1
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.translate, size: 18, color: Color(0xFF1B5E20)),
                            const SizedBox(width: 8),
                            Text(
                              "Latin",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : const Color(0xFF1B5E20),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          doa.latin,
                          style: GoogleFonts.inter(
                            fontSize: settings.latinFontSize, 
                            color: const Color(0xFF1B5E20), 
                            fontStyle: FontStyle.italic,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- ARTI ---
                Card(
                  elevation: 0,
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? Colors.transparent : Colors.green.shade100, 
                      width: 1
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notes, size: 18, color: Color(0xFF1B5E20)),
                            const SizedBox(width: 8),
                            Text(
                              "Artinya",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : const Color(0xFF1B5E20),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          doa.indo,
                          style: GoogleFonts.inter(
                            fontSize: settings.latinFontSize, 
                            height: 1.6,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- RIWAYAT ---
                if (doa.tentang.isNotEmpty) ...[
                  Divider(color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    "Riwayat / Keterangan:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doa.tentang,
                    style: TextStyle(
                      fontSize: 13, 
                      color: Colors.grey[500],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}