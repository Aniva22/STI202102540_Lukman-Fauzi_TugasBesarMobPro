import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:quickalert/quickalert.dart';
import '../database/database_helper.dart';
import '../models/destination.dart';
import 'map_picker_page.dart';

class AddEditDestinationPage extends StatefulWidget {
  final Destination? destination;

  const AddEditDestinationPage({super.key, this.destination});

  @override
  State<AddEditDestinationPage> createState() => _AddEditDestinationPageState();
}

class _AddEditDestinationPageState extends State<AddEditDestinationPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _longController;

  String _imagePath = '';
  TimeOfDay _openTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 17, minute: 0);

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.destination?.name ?? '',
    );
    _descController = TextEditingController(
      text: widget.destination?.description ?? '',
    );
    _addressController = TextEditingController(
      text: widget.destination?.address ?? '',
    );
    _latController = TextEditingController(
      text: widget.destination?.latitude.toString() ?? '',
    );
    _longController = TextEditingController(
      text: widget.destination?.longitude.toString() ?? '',
    );

    if (widget.destination != null) {
      _imagePath = widget.destination!.imagePath;
      // Parse time strings back to TimeOfDay if needed, assumes "HH:mm" format
      _openTime = _parseTime(widget.destination!.openingTime);
      _closeTime = _parseTime(widget.destination!.closingTime);
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(":");
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _openTime : _closeTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  Future<void> _saveDestination() async {
    if (_formKey.currentState!.validate()) {
      final newDest = Destination(
        id: widget.destination?.id,
        name: _nameController.text,
        description: _descController.text,
        address: _addressController.text,
        latitude: double.tryParse(_latController.text) ?? 0.0,
        longitude: double.tryParse(_longController.text) ?? 0.0,
        openingTime: _formatTime(_openTime),
        closingTime: _formatTime(_closeTime),
        imagePath: _imagePath,
        isFavorite:
            widget.destination?.isFavorite ?? false, // Preserve favorite status
      );

      if (widget.destination == null) {
        await _dbHelper.insertDestination(newDest);
      } else {
        await _dbHelper.updateDestination(newDest);
      }

      if (!mounted) return;

      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Destinasi berhasil disimpan',
        autoCloseDuration: const Duration(seconds: 2),
        showConfirmBtn: false,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.destination == null ? 'Tambah Destinasi' : 'Edit Destinasi',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imagePath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: File(_imagePath).existsSync()
                              ? Image.file(File(_imagePath), fit: BoxFit.cover)
                              : Image.asset(
                                  _imagePath.trim(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.broken_image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        Text('Gambar tidak ditemukan'),
                                      ],
                                    );
                                  },
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text('Ketuk untuk upload foto'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Destinasi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              // Replace Lat/Long manual input with Map Picker
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Lokasi Peta:",
                          style: TextStyle(fontSize: 16),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final LatLng? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPickerPage(
                                  initialPosition:
                                      _latController.text.isNotEmpty
                                      ? LatLng(
                                          double.parse(_latController.text),
                                          double.parse(_longController.text),
                                        )
                                      : null,
                                ),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                _latController.text = result.latitude
                                    .toString();
                                _longController.text = result.longitude
                                    .toString();
                              });
                            }
                          },
                          icon: const Icon(Icons.map),
                          label: const Text("Pilih di Peta"),
                        ),
                      ],
                    ),
                    if (_latController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Koordinat: ${_latController.text}, ${_longController.text}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                  ],
                ),
              ),
              // Hidden fields to keep validation logic simply working
              Visibility(
                visible: false,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _latController,
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    TextFormField(
                      controller: _longController,
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Jam Buka',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_formatTime(_openTime)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Jam Tutup',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_formatTime(_closeTime)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveDestination,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'SIMPAN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
