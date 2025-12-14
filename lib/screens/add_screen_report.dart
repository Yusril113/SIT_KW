// lib/screens/add_report_screen.dart

// Import yang dibutuhkan:
import 'package:flutter/material.dart';
//import 'package:flutter_project_uas/models/report_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Hardware Sensors: Kamera
import 'package:geolocator/geolocator.dart'; // Hardware Sensors: GPS
import 'dart:io'; // Untuk menampilkan Image.file
import '../models/report_model.dart';
import '../providers/report_provider.dart';

// Definisi Widget: Wajib ConsumerStatefulWidget karena ada State (pickedImage, position)
class AddReportScreen extends ConsumerStatefulWidget {
  const AddReportScreen({super.key});

  @override
  ConsumerState<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends ConsumerState<AddReportScreen> {
  // State untuk form
  final titleController = TextEditingController();
  final descController = TextEditingController();
  XFile? pickedImage; // Foto Bukti (Kamera) [cite: 31]
  Position? currentPosition; // Koordinat GPS [cite: 35]
  bool _isLoadingLocation = false;

  // Integrasi Kamera (ambil foto dari Kamera atau Galeri) [cite: 31]
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Secara default, kita asumsikan menggunakan kamera [cite: 31]
    final image = await picker.pickImage(source: ImageSource.camera); 
    if (image != null) {
      setState(() {
        pickedImage = image;
      });
    }
  }

  // Integrasi GPS (ambil koordinat Lat/Long) [cite: 33]
  Future<void> _tagLocation() async {
    setState(() {
      _isLoadingLocation = true;
      currentPosition = null; // Reset
    });

    try {
      // 1. Cek Service GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan Lokasi (GPS) dinonaktifkan.');
      }

      // 2. Cek Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          throw Exception('Akses lokasi ditolak.');
        }
      }

      // 3. Ambil posisi
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        currentPosition = position;
      });

    } catch (e) {
      // Tampilkan error ke user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan lokasi: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }
  
  // Create Logic (Insert) [cite: 36, 37]
  void _submitReport() {
    if (titleController.text.isEmpty || descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan Deskripsi wajib diisi.')),
      );
      return;
    }
    
    if (pickedImage == null || currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto bukti dan lokasi wajib ditandai.')),
      );
      return;
    }

    final newReport = ReportModel(
      title: titleController.text,
      description: descController.text,
      imagePath: pickedImage!.path, // Path foto lokal
      latitude: currentPosition!.latitude,
      longitude: currentPosition!.longitude,
      status: 'Pending', // Status default saat insert
    );

    // Menyimpan data laporan ke database menggunakan Riverpod Provider [cite: 37]
    ref.read(reportListProvider.notifier).addReport(newReport); 
    
    // Kembali ke Dashboard
    Navigator.pop(context);
  }
  
  // =======================================================
  // BUILD METHOD (UI)
  // =======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form Input: Judul Laporan [cite: 29]
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Laporan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Form Input: Deskripsi [cite: 29]
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Detail Masalah',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Bagian Foto Bukti (Kamera) [cite: 32]
            const Text('Foto Bukti (Wajib):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Menampilkan preview foto [cite: 32]
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: pickedImage == null
                  ? const Center(child: Text('Belum ada foto bukti'))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(pickedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Ambil Foto'),
            ),
            const SizedBox(height: 24),

            // Bagian Lokasi (GPS) [cite: 34, 35]
            const Text('Lokasi Akurat (Wajib):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // Menampilkan koordinat yang sudah ditag
            Text(
              currentPosition == null
                  ? 'Lokasi belum ditandai.'
                  : 'Lat: ${currentPosition!.latitude.toStringAsFixed(4)}, Lon: ${currentPosition!.longitude.toStringAsFixed(4)}',
              style: const TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _tagLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.location_on),
              label: _isLoadingLocation
                  ? const Text('Mengambil Lokasi...')
                  : const Text('Tag Lokasi Terkini (GPS)'), // Tombol "Tag Lokasi Terkini" [cite: 34]
            ),
            const SizedBox(height: 40),

            // Tombol Submit [cite: 36]
            ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Kirim Laporan', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}