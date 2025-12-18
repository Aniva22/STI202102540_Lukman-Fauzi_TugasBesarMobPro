import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import '../../database/database_helper.dart';
import '../../models/destination.dart';
import '../../models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Static theme colors
  static const Color primary = Color(0xFF10B981);
  static const Color bgLight = Colors.white;
  static const Color cardLight = Colors.white;

  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Determine which user is logged in.
    // In a real app, this would be stored in SharedPreferences/SecureStorage.
    // For this MVP, we'll fetch the first user (the admin we seeded).
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    if (maps.isNotEmpty) {
      if (mounted) {
        setState(() {
          _currentUser = User.fromMap(maps.first);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    _dbHelper.loadDestinations();
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && _currentUser != null) {
      // Create updated user object
      final updatedUser = User(
        id: _currentUser!.id,
        username: _currentUser!.username,
        email: _currentUser!.email,
        password: _currentUser!.password,
        fullName: _currentUser!.fullName,
        phone: _currentUser!.phone,
        avatarPath: image.path,
      );

      // Save to DB
      await _dbHelper.updateUser(updatedUser);

      // Refresh UI
      setState(() {
        _currentUser = updatedUser;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto profil diperbarui!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _header(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                      child: StreamBuilder<List<Destination>>(
                        stream: _dbHelper.destinationsStream,
                        builder: (context, snapshot) {
                          int total = 0;
                          int favorites = 0;
                          if (snapshot.hasData) {
                            final destinations = snapshot.data!;
                            total = destinations.length;
                            favorites = destinations
                                .where((d) => d.isFavorite)
                                .length;
                          }

                          return Column(
                            children: [
                              _profileSection(),
                              const SizedBox(height: 32),
                              _statsSection(total, favorites),
                              const SizedBox(height: 32),
                              _settingsSection(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Text(
            'Profil & Statistik',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ===== PROFILE =====
  Widget _profileSection() {
    // Logic to determine image provider
    ImageProvider? backgroundImage;
    if (_currentUser?.avatarPath != null &&
        _currentUser!.avatarPath.isNotEmpty) {
      if (_currentUser!.avatarPath.startsWith('http')) {
        backgroundImage = NetworkImage(_currentUser!.avatarPath);
      } else if (_currentUser!.avatarPath.startsWith('assets')) {
        backgroundImage = AssetImage(_currentUser!.avatarPath);
      } else {
        backgroundImage = FileImage(File(_currentUser!.avatarPath));
      }
    }

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 112,
              height: 112,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [primary, Color(0xFF6EE7B7)]),
              ),
              child: GestureDetector(
                onTap: _updateProfileImage,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: backgroundImage,
                  child: backgroundImage == null
                      ? Text(
                          _currentUser?.fullName.isNotEmpty == true
                              ? _currentUser!.fullName[0].toUpperCase()
                              : "U",
                          style: GoogleFonts.poppins(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: _updateProfileImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _currentUser?.fullName ?? "Pengguna",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _currentUser?.email ?? "email@example.com",
          style: GoogleFonts.inter(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Text(
            'NIM: 202300000', // Hardcoded as requested or could also be in DB
            style: GoogleFonts.inter(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ===== PERFORMANCE / STATS =====
  Widget _statsSection(int total, int favorites) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Aplikasi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _performanceTile(
          icon: Icons.map,
          title: 'Total Destinasi',
          subtitle: 'Jumlah tempat wisata tersimpan',
          value: '$total',
          progress: total > 0 ? 1.0 : 0.0,
        ),
        _performanceTile(
          icon: Icons.favorite,
          title: 'Favorit',
          subtitle: 'Destinasi yang Anda sukai',
          value: '$favorites',
          progress: (total > 0) ? (favorites / total) : 0.0,
        ),
      ],
    );
  }

  Widget _performanceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    double? progress,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              if (progress != null)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== SETTINGS =====
  Widget _settingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengaturan & Aksi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _settingsTile(
          icon: Icons.info_outline,
          label: 'Tentang Aplikasi',
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: "Travel Wisata Lokal",
              applicationVersion: "1.0.0",
              applicationLegalese: "© 2025 Lukman Fauzi",
            );
          },
        ),
        _settingsTile(
          icon: Icons.delete_outline,
          label: 'Hapus Semua Data',
          iconColor: Colors.red,
          onTap: () => _confirmClearData(),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          },
          icon: const Icon(Icons.logout, color: primary),
          label: Text('Keluar', style: GoogleFonts.inter(color: primary)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: primary),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Versi 1.1.0 (Build 101)',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _confirmClearData() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Hapus Semua Data',
      text: 'Yakin ingin menghapus semua data destinasi?',
      confirmBtnText: 'Hapus',
      cancelBtnText: 'Batal',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.of(context).pop(); // Close QuickAlert
        await _dbHelper.clearTable('destinations');
        await _dbHelper.loadDestinations();

        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Semua data telah dihapus',
            autoCloseDuration: const Duration(seconds: 2),
            showConfirmBtn: false,
          );
        }
      },
    );
  }
}
