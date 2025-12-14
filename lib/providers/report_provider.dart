// lib/providers/report_provider.dart 
//import 'package:flutter_riverpod/flutter_riverpod.dart';


// Import yang dibutuhkan:
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helpers/db_helper.dart';       // DatabaseHelper (Mhs 1)
import '../models/report_model.dart';    // ReportModel (Mhs 1) 
// Catatan: Asumsi path file adalah 'lib/models/report_model.dart'

// 1. Definisikan StateNotifierProvider
// Provider ini mengelola List<ReportModel> yang akan diakses oleh Dashboard (Mhs 3).
final reportListProvider = StateNotifierProvider<ReportNotifier, List<ReportModel>>((ref) {
  // ReportNotifier menerima instance dari DatabaseHelper.
  return ReportNotifier(DbHelper.instance);
});

class ReportNotifier extends StateNotifier<List<ReportModel>> {
  final DbHelper _dbHelper;

  ReportNotifier(this._dbHelper) : super([]) {
    // Dipanggil saat Notifier dibuat untuk pertama kalinya.
    loadReports();
  }

  // =======================================================
  // READ (Mahasiswa 3)
  // =======================================================
  
  // Memuat seluruh daftar laporan dari database
  Future<void> loadReports() async {
    // Memuat seluruh daftar laporan menggunakan DatabaseHelper
    final reports = await _dbHelper.readAllReports();
    // Memperbarui state Riverpod
    state = reports; 
  }

  // =======================================================
  // CREATE (Mahasiswa 2)
  // =======================================================

  // Menambahkan laporan baru ke database dan state lokal
  Future<void> addReport(ReportModel report) async {
    // 1. Insert ke database dan dapatkan ID baru
    final id = await _dbHelper.insertReport(report); 

    // 2. Buat objek ReportModel baru dengan ID yang sudah ada
    // Menggunakan copyWith yang didefinisikan di ReportModel
    final newReportWithId = report.copyWith(id: id);
    
    // 3. Update state Riverpod: Tambahkan laporan baru (di depan list agar terlihat)
    state = [newReportWithId, ...state]; 
  }

  // =======================================================
  // UPDATE (Mahasiswa 4)
  // =======================================================

  // Memperbarui laporan (misalnya, mengubah status menjadi 'Selesai')
  Future<void> updateReport(ReportModel updatedReport) async {
    // Pastikan ID ada sebelum update
    if (updatedReport.id == null) return;
    
    // 1. Update ke database
    await _dbHelper.updateReport(updatedReport); 
    
    // 2. Update state Riverpod
    state = [
      for (final report in state)
        // Cari berdasarkan ID. Jika cocok, ganti dengan updatedReport, jika tidak, pertahankan
        if (report.id == updatedReport.id) updatedReport else report,
    ];
  }

  // =======================================================
  // DELETE (Mahasiswa 4)
  // =======================================================

  // Menghapus laporan dari database dan state lokal
  Future<void> deleteReport(int id) async {
    // 1. Hapus dari database
    await _dbHelper.deleteReport(id);

    // 2. Update state Riverpod: Hapus item dari list
    state = state.where((report) => report.id != id).toList();
  }
}