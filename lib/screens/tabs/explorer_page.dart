import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../database/database_helper.dart';
import '../../models/destination.dart';
import '../destination_detail_page.dart';
import '../add_edit_destination_page.dart';

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Emerald Theme Colors
  final Color _primaryColor = const Color(0xFF10B981); // Emerald 500
  final Color _backgroundColor = const Color(0xFFF0FDF4); // Background Light
  final Color _slate800 = const Color(0xFF1E293B);
  final Color _green100 = const Color(0xFFD1FAE5);

  @override
  void initState() {
    super.initState();
    _dbHelper.loadDestinations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditDestinationPage(),
            ),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header (Sticky-like)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              color: _backgroundColor.withValues(
                alpha: 0.95,
              ), // mimics backdrop
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button removed as requested
                      const SizedBox(width: 24),
                      Text(
                        "Jelajahi Destinasi",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF064E3B), // text-primary-light
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _green100),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _slate800,
                      ),
                      decoration: InputDecoration(
                        hintText: "Cari destinasi...",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.green.withValues(alpha: 0.4),
                        ), // simplified placeholder color
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF4ADE80),
                        ), // green-400
                        suffixIcon: Icon(Icons.tune, color: _primaryColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Category Chips (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _buildCategoryChip("Semua", true),
                  _buildCategoryChip("Pantai", false),
                  _buildCategoryChip("Pegunungan", false),
                  _buildCategoryChip("Sejarah", false),
                  _buildCategoryChip("Romantis", false),
                ],
              ),
            ),

            // 3. Main Grid Content
            Expanded(
              child: StreamBuilder<List<Destination>>(
                stream: _dbHelper.destinationsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allDestinations = snapshot.data!;
                  final filteredDestinations = allDestinations.where((dest) {
                    return dest.name.toLowerCase().contains(_searchQuery) ||
                        dest.address.toLowerCase().contains(_searchQuery);
                  }).toList();

                  return Column(
                    children: [
                      // Section Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tempat Populer",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF064E3B),
                              ),
                            ),
                            Text(
                              "Lihat Semua",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Grid
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            24,
                            0,
                            24,
                            100,
                          ), // padding bottom for tab bar
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75, // Taller cards
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: filteredDestinations.length,
                          itemBuilder: (context, index) {
                            return _buildDestinationCard(
                              filteredDestinations[index],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        // For ripple
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: isSelected ? _primaryColor : _green100),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF064E3B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Destination dest) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DestinationDetailPage(destinationId: dest.id!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0FDF4)), // green-50 equiv
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), // shadow-sm
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: dest.imagePath.isNotEmpty
                          ? (dest.imagePath.startsWith('assets')
                                ? Image.asset(dest.imagePath, fit: BoxFit.cover)
                                : Image.file(
                                    File(dest.imagePath),
                                    fit: BoxFit.cover,
                                  ))
                          : Container(color: Colors.grey[200]),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.2,
                        ), // backdrop blur equiv
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_border,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  if (dest
                      .isFavorite) // reuse favorite logic as visual tag? Or just random tag
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFACC15), // Yellow
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "POPULAR",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dest.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF064E3B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Color(0xFF4ADE80),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              // Added Expanded to prevent overflow
                              child: Text(
                                dest.address,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mulai dari",
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "Rp 10k",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
