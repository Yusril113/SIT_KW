// lib/widgets/summary_card.dart
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final int total;
  final int completed;
  final int pending; // Tambahkan properti pending untuk kemudahan display

  const SummaryCard({
    required this.total,
    required this.completed,
    // Kita juga bisa mengambil pending, atau menghitungnya di sini.
    required this.pending, 
    super.key
  });
  
  // Helper method untuk menampilkan satu item statistik
  Widget _buildStatItem(BuildContext context, String title, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Angka Total/Selesai/Pending
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        // Label
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // Margin agar tidak terlalu mepet dengan edge screen
      margin: const EdgeInsets.all(16.0), 
      elevation: 4, // Efek bayangan
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Total Laporan (Warna Netral/Biru)
            _buildStatItem(context, 'Total Laporan', total, Colors.blue),
            
            // Laporan Selesai (Warna Hijau)
            _buildStatItem(context, 'Selesai', completed, Colors.green),
            
            // Laporan Pending (Warna Merah)
            _buildStatItem(context, 'Pending', pending, Colors.red),
          ],
        ),
      ),
    );
  }
}