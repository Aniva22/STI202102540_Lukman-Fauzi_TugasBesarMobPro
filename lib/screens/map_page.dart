import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../database/database_helper.dart';
import '../models/destination.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final DatabaseHelper db = DatabaseHelper();
  final MapController _mapController = MapController();
  Destination? selectedDestination;
  final TextEditingController _searchController = TextEditingController();

  // Stream of markers (filtered or all)
  late StreamController<List<Destination>> _localStreamController;
  late StreamSubscription _globalSubscription;

  // Default center (Borobudur or Yogya)
  final LatLng _initialCenter = const LatLng(
    -7.4245,
    109.2305,
  ); // Alun-alun Purwokerto

  @override
  void initState() {
    super.initState();
    _localStreamController = StreamController<List<Destination>>.broadcast();

    // Listen to global stream and pipe to local if not searching
    _globalSubscription = db.destinationsStream.listen((data) {
      if (_searchController.text.isEmpty) {
        _localStreamController.add(data);
      }
    });

    db.loadDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _globalSubscription.cancel();
    _localStreamController.close();
    super.dispose();
  }

  void _onMarkerTap(Destination d) {
    setState(() {
      selectedDestination = d;
    });
    // Center map on tap? Optional.
    _mapController.move(LatLng(d.latitude, d.longitude), 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<List<Destination>>(
            stream: _localStreamController.stream,
            builder: (context, snapshot) {
              final destinations = snapshot.data ?? [];
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom:
                      10.0, // Zoom out to see both Borobudur and Parangtritis
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.travel_wisata_lokal',
                  ),
                  MarkerLayer(
                    markers: destinations.map((d) {
                      return Marker(
                        point: LatLng(d.latitude, d.longitude),
                        width: 80, // Increased width for text
                        height: 70, // Increased height for text + icon
                        child: GestureDetector(
                          onTap: () => _onMarkerTap(d),
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: d.isFavorite
                                    ? Colors.red
                                    : Colors.green.shade700,
                                size: 40,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.green.shade700,
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  d.name,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),

          /// SEARCH BAR
          Positioned(
            top: 40, // consistent with SafeArea
            left: 16,
            right: 16,
            child: _searchBar(),
          ),

          /// DESTINATION DETAIL
          if (selectedDestination != null)
            _destinationDetail(selectedDestination!),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Cari destinasi wisata...",
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) async {
          if (value.isEmpty) {
            await db.loadDestinations();
          } else {
            final results = await db.searchDestinations(value);
            _localStreamController.add(results);
          }
        },
      ),
    );
  }

  Widget _destinationDetail(Destination d) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: d.imagePath.startsWith('assets')
                    ? Image.asset(
                        d.imagePath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(d.imagePath),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(d.address, style: const TextStyle(fontSize: 11)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            d.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            await db.toggleFavorite(d.id!, !d.isFavorite);
                            // We don't close it, just update state (stream handles update)
                            setState(() {
                              // Update selected destination to reflect change if needed,
                              // but simpler: just close or keep.
                              // Since stream updates filters, d might become 'stale' object.
                              // Re-fetch or simplistic approach:
                              selectedDestination = null;
                            });
                          },
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedDestination = null;
                            });
                          },
                          child: const Text(
                            "Tutup",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
