import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'screens/quran_screen.dart';
import 'screens/doa_screen.dart';
import 'screens/settings_screen.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const SimpleQuranApp(),
    ),
  );
}

class SimpleQuranApp extends StatelessWidget {
  const SimpleQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'Islamic One',
      debugShowCheckedModeBanner: false,
      
      // --- KONFIGURASI TEMA LIGHT & DARK ---
      themeMode: settings.themeMode,
      
      // TEMA TERANG (LIGHT)
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F9F5),
        cardColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          toolbarHeight: 80,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF1B5E20),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),

      // TEMA GELAP (DARK)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF121212), // Hitam pekat
        cardColor: const Color(0xFF1E1E1E), // Abu gelap
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1B5E20), // Tetap hijau
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          toolbarHeight: 80,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF81C784), // Hijau muda di mode gelap
          unselectedItemColor: Colors.grey,
          backgroundColor: Color(0xFF1E1E1E),
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),

      // --- PERUBAHAN DI SINI: LANGSUNG KE MAIN SCREEN ---
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const QuranScreen(),
    const DoaScreen(),
    const SettingsScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      // Menggunakan IndexedStack agar halaman tidak reload saat pindah tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_rounded),
                label: 'Al-Quran',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.volunteer_activism), // Ikon hati di tangan
                label: 'Doa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings), 
                label: 'Pengaturan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}