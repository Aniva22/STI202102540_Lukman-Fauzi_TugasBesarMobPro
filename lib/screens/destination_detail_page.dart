import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../database/database_helper.dart';
import '../models/destination.dart';
import 'add_edit_destination_page.dart';

class DestinationDetailPage extends StatefulWidget {
  final int destinationId;

  const DestinationDetailPage({super.key, required this.destinationId});

  @override
  State<DestinationDetailPage> createState() => _DestinationDetailPageState();
}

class _DestinationDetailPageState extends State<DestinationDetailPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _dbHelper.loadDestinations();
  }

  Future<void> _toggleFavorite(Destination dest) async {
    final newState = !dest.isFavorite;
    await _dbHelper.toggleFavorite(dest.id!, newState);

    if (mounted) {
      QuickAlert.show(
        context: context,
        type: newState ? QuickAlertType.success : QuickAlertType.info,
        title: newState ? 'Favorit' : 'Unfavorit',
        text: newState ? "Ditambahkan ke Favorit" : "Dihapus dari Favorit",
        autoCloseDuration: const Duration(seconds: 1),
        showConfirmBtn: false,
      );
    }
  }

  Future<void> _deleteDestination() async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Hapus Destinasi',
      text: 'Apakah Anda yakin ingin menghapus destinasi ini?',
      confirmBtnText: 'Hapus',
      cancelBtnText: 'Batal',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        await _dbHelper.deleteDestination(widget.destinationId);
        if (context.mounted) {
          Navigator.of(context).pop(); // Close QuickAlert
          Navigator.of(context).pop(); // Close detail page
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Destination>>(
        stream: _dbHelper.destinationsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Find specific destination from stream
          Destination? destination;
          try {
            destination = snapshot.data!.firstWhere(
              (d) => d.id == widget.destinationId,
            );
          } catch (e) {
            // Destination might have been deleted
            return const Center(
              child: Text("Destinasi tidak ditemukan (mungkin telah dihapus)"),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildCircleAction(
                    icon: Icons.arrow_back,
                    color: Colors.black,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  _buildCircleAction(
                    icon: destination.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                    onTap: () => _toggleFavorite(destination!),
                  ),
                  const SizedBox(width: 8),
                  _buildCircleAction(
                    icon: Icons.edit,
                    color: Colors.blue,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditDestinationPage(destination: destination),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildCircleAction(
                    icon: Icons.delete,
                    color: Colors.grey,
                    onTap: _deleteDestination,
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    destination.name,
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    ),
                  ),
                  background: destination.imagePath.isNotEmpty
                      ? (File(destination.imagePath).existsSync()
                            ? Image.file(
                                File(destination.imagePath),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                destination.imagePath.trim(),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: Colors.grey),
                              ))
                      : Container(color: Colors.grey),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                destination.address,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                Icons.access_time,
                                "Buka",
                                destination.openingTime,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInfoCard(
                                Icons.access_time_filled,
                                "Tutup",
                                destination.closingTime,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Deskripsi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          destination.description,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.purple),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
