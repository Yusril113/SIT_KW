// lib/screens/edit_report_screen.dart (Tugas Mhs 4)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import Model dan Provider
import '../models/report_model.dart';
import '../providers/report_provider.dart';

class EditReportScreen extends ConsumerStatefulWidget {
  final ReportModel report;

  const EditReportScreen({required this.report, super.key});

  @override
  ConsumerState<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends ConsumerState<EditReportScreen> {
  final _notesController = TextEditingController();
  File? _pickedOfficerImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi field dengan catatan yang sudah ada
    _notesController.text = widget.report.officerNotes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Metode untuk memilih foto hasil pengerjaan
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _pickedOfficerImage = File(pickedFile.path);
      });
    }
  }

  // Metode untuk menyimpan perubahan status
  Future<void> _submitCompletion() async {
    if (_pickedOfficerImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap tambahkan Foto Hasil Pengerjaan.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Buat objek ReportModel baru dengan data update
      final updatedReport = widget.report.copyWith(
        status: 'Selesai',
        officerNotes: _notesController.text.trim(),
        // Catatan: Karena kita menggunakan File.path, pastikan ReportModel.copyWith
        // dapat menangani tipe data string untuk officerImagePath.
        officerImagePath: _pickedOfficerImage!.path, 
      );

      // 2. Panggil metode updateReport di Notifier
      await ref.read(reportListProvider.notifier).updateReport(updatedReport);

      // 3. Tampilkan pesan sukses dan navigasi kembali
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil ditandai Selesai.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // KOREKSI NAVIGASI:
        // Cukup pop sekali dan kirim 'true' sebagai hasil.
        // Detail Screen (yang memanggil EditReportScreen) bertanggung jawab 
        // untuk menangani hasil 'true' ini, misalnya dengan pop sendiri ke Dashboard.
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyelesaikan laporan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Selesaikan Laporan: ${widget.report.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Laporan
            Text(
              'Judul: ${widget.report.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Input Catatan Petugas (Officer Notes)
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan Petugas (Opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_alt),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Preview & Tombol Pilih Foto Hasil Pengerjaan
            const Text('Foto Hasil Pengerjaan (Wajib):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: _pickedOfficerImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_pickedOfficerImage!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                            Text('Ambil Foto Hasil', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Submit
            ElevatedButton(
              onPressed: _isLoading ? null : _submitCompletion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text(
                      'Tandai Selesai & Simpan',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}