// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Impor yang Dibutuhkan:
import '/providers/report_provider.dart';
//import '/models/report_models.dart';
//import '/widget/summary_card.dart'; // Diperlukan untuk Mhs 3 Header Ringkasan
import 'setting_screen.dart'; // Diperlukan untuk Navigasi Settings (Mhs 1)
import 'add_screen_report.dart'; // Diperlukan untuk FAB (Mhs 2)
import 'detail_report_screen.dart'; // Diperlukan untuk ListTile onTap (Mhs 4)
//import '/screens/edit_report_screen.dart';


class DashboardScreen extends ConsumerWidget { // Wajib menggunakan ConsumerWidget [cite: 44]
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Menggunakan ref.watch agar list update otomatis saat Mhs 2 menambah data [cite: 44]
    final reports = ref.watch(reportListProvider);
    final totalReports = reports.length;
    final completedReports = reports.where((r) => r.status == 'Selesai').length;
    final pendingReports = totalReports - completedReports;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoPatrol Dashboard'),
        actions: [
          // Aksi: Navigasi ke Settings Screen (Tugas Mhs 1)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()), );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Ringkasan (Menampilkan widget jumlah laporan) [cite: 47, 48]
          SummaryCard(
            total: totalReports, 
            completed: completedReports,
            pending: pendingReports, // Tambahkan pending untuk UI Summary Card
          ), 
          
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Daftar Laporan:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          Expanded(
            // Menampilkan seluruh daftar laporan dalam bentuk ListView [cite: 43]
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final isPending = report.status == 'Pending';
                
                // Status Badge: Merah (Pending) dan Hijau (Selesai) [cite: 45, 46]
                final color = isPending ? Colors.red : Colors.green; 
                
                return ListTile(
                  leading: Icon(Icons.circle, color: color, size: 12),
                  title: Text(report.title),
                  subtitle: Text(
                    '${report.description.substring(0, report.description.length > 50 ? 50 : report.description.length)}...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(report.status),
                  onTap: () {
                    // Navigasi ke Halaman Detail (Tugas Mhs 4) [cite: 52]
                    if (report.id != null) {
                       Navigator.push(
                         context, 
                         MaterialPageRoute(
                           builder: (ctx) => EditReportScreen(report: report),
                         ),
                       );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Tombol FAB untuk Mhs 2 (Create Report)
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          // Navigasi ke AddReportScreen (Tugas Mhs 2)
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const AddReportScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =======================================================
// WIDGET PENDUKUNG (SummaryCard, Area Kerja Mhs 3)
// Dibuat sebagai placeholder di file yang seharusnya: lib/widgets/summary_card.dart
// =======================================================

class SummaryCard extends StatelessWidget {
  final int total;
  final int completed;
  final int pending;

  const SummaryCard({
    super.key,
    required this.total,
    required this.completed,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', total, Colors.blue),
            _buildStatItem('Selesai', completed, Colors.green),
            _buildStatItem('Pending', pending, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// =======================================================
// PLACEHOLDER SCREENS (Untuk Navigasi)
// Asumsikan screen ini sudah dibuat atau akan dibuat oleh Mhs 2 & Mhs 4.
// =======================================================

// Placeholder untuk Mhs 4
// class DetailReportScreen extends StatelessWidget {
//   final int reportId;
//   const DetailReportScreen({super.key, required this.reportId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Detail Laporan #$reportId')),
//       body: Center(
//         child: Text('Halaman Detail Laporan (Tugas Mhs 4)'),
//       ),
//     );
//   }
// }

// Placeholder untuk Mhs 2
// Catatan: AddReportScreen yang fungsional sudah dibuat di langkah sebelumnya.
// Kita hanya perlu memastikan class-nya terdefinisi.
// class AddReportScreen extends StatelessWidget { 
//   const AddReportScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(title: const Text('Add Report (Mhs 2)')), body: const Center(child: Text('Placeholder')),);
//   }
// }

// Placeholder untuk Mhs 1 (SettingsScreen sudah dibuat di langkah sebelumnya)
// class SettingsScreen extends StatelessWidget { /* ... */ }