import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api_service.dart';
import '../models.dart';
import 'detail_doa_screen.dart';

class DoaScreen extends StatefulWidget {
  const DoaScreen({super.key});

  @override
  State<DoaScreen> createState() => _DoaScreenState();
}

class _DoaScreenState extends State<DoaScreen> {
  final ApiService api = ApiService();
  List<Doa> _allDoa = [];
  List<Doa> _filteredDoa = [];
  bool _isLoading = true;
  bool _isError = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await api.getDaftarDoa();
      if (mounted) {
        setState(() {
          _allDoa = data;
          _filteredDoa = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _isError = true; });
    }
  }

  void _filterDoa(String query) {
    if (query.isEmpty) {
      setState(() => _filteredDoa = _allDoa);
    } else {
      final lowerQuery = query.toLowerCase();
      setState(() {
        _filteredDoa = _allDoa.where((doa) {
          return doa.nama.toLowerCase().contains(lowerQuery) ||
                 doa.indo.toLowerCase().contains(lowerQuery) ||
                 doa.grup.toLowerCase().contains(lowerQuery);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kumpulan Doa'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
            child: TextField(
              controller: _searchController,
              onChanged: _filterDoa,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Cari Doa (ex: Tidur, Rezeki)...",
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1B5E20)),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () { _searchController.clear(); _filterDoa(''); FocusScope.of(context).unfocus(); })
                  : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
        : _isError 
          ? const Center(child: Text("Gagal memuat doa"))
          : _filteredDoa.isEmpty 
            ? const Center(child: Text("Doa tidak ditemukan"))
            : ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                itemCount: _filteredDoa.length,
                itemBuilder: (context, index) {
                  return _buildDoaItem(_filteredDoa[index]);
                },
              ),
    );
  }

  Widget _buildDoaItem(Doa doa) {
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailDoaScreen(id: doa.id, title: doa.nama),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Leading: Nomor ID
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), // Hijau sangat muda
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${doa.id}',
                    style: const TextStyle(
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info Doa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doa.nama,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doa.grup,
                        style: TextStyle(
                          color: Colors.grey[600], 
                          fontSize: 12,
                          fontWeight: FontWeight.w500
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Icon Removed Here for Cleaner Look
              ],
            ),
          ),
        ),
      ),
    );
  }
}