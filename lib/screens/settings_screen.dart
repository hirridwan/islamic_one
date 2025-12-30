import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
// import 'about_screen.dart'; // Uncomment jika ingin mengaktifkan menu About

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    // Variabel helper untuk styling agar kodenya tidak berulang
    // Cek apakah mode gelap aktif
    final isDark = settings.isDarkMode;
    
    // Style Kartu: Putih bersih di light mode, gelap di dark mode
    final cardColor = isDark ? Theme.of(context).cardColor : Colors.white;
    
    // Style Border: Garis halus di light mode, transparan di dark mode
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: isDark ? Colors.transparent : Colors.grey.shade200,
        width: 1,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan"),
        elevation: 0, // Hilangkan bayangan di AppBar juga biar lebih clean
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- KARTU TEMA ---
          Card(
            elevation: 0, // Flat (Tidak ada bayangan)
            color: cardColor,
            shape: cardShape,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: const Color(0xFF1B5E20),
                ),
              ),
              title: const Text("Mode Gelap", style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Switch(
                value: settings.isDarkMode,
                activeTrackColor: const Color(0xFF1B5E20).withOpacity(0.5),
                activeThumbColor: const Color(0xFF1B5E20),
                onChanged: (value) => settings.toggleTheme(value),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              "Tampilan Teks", 
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600], 
                fontWeight: FontWeight.bold,
                fontSize: 14
              )
            ),
          ),

          // --- KARTU FONT ARAB (SKALA 1-10) ---
          Card(
            elevation: 0, // Flat
            color: cardColor,
            shape: cardShape,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Ukuran Arab", style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(
                          "Level ${settings.arabicLevel.round()}", 
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF1B5E20)
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4.0,
                    ),
                    child: Slider(
                      value: settings.arabicLevel,
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      label: settings.arabicLevel.round().toString(),
                      activeColor: const Color(0xFF1B5E20),
                      onChanged: (value) => settings.setArabicLevel(value),
                    ),
                  ),
                  const Divider(height: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiri(
                        fontSize: settings.arabicFontSize, 
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        height: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- KARTU FONT LATIN (SKALA 1-10) ---
          Card(
            elevation: 0, // Flat
            color: cardColor,
            shape: cardShape,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Ukuran Terjemahan", style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(
                          "Level ${settings.latinLevel.round()}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF1B5E20)
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4.0,
                    ),
                    child: Slider(
                      value: settings.latinLevel,
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      label: settings.latinLevel.round().toString(),
                      activeColor: const Color(0xFF1B5E20),
                      onChanged: (value) => settings.setLatinLevel(value),
                    ),
                  ),
                  const Divider(height: 30),
                  Text(
                    "Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang.",
                    style: GoogleFonts.inter(
                      fontSize: settings.latinFontSize,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),

          // --- TOMBOL RESET ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: OutlinedButton.icon(
              onPressed: () {
                settings.resetSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pengaturan dikembalikan ke awal")),
                );
              },
              icon: const Icon(Icons.refresh, color: Colors.red),
              label: const Text("Reset Pengaturan Default", style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                backgroundColor: isDark ? Colors.transparent : Colors.white,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),

          const SizedBox(height: 20),
          
          Center(
            child: Text(
              "Simple Quran v1.0.0",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}