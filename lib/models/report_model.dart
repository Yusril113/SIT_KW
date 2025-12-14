// lib/models/report_model.dart
class ReportModel {
  final int? id; // Primary Key
  final String title;
  final String description;
  final String imagePath; // Path lokal foto laporan
  final double latitude; // Koordinat GPS
  final double longitude;
  final String status; // 'Pending' atau 'Selesai'
  final String? officerNotes; // Catatan Mhs 4 saat menyelesaikan laporan
  final String? officerImagePath; // Foto hasil pekerjaan (Mhs 4)

  // KOREKSI 1: Gunakan const constructor karena semua properti adalah final
  const ReportModel({
    this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    this.status = 'Pending',
    this.officerNotes,
    this.officerImagePath,
  });

  // Metode untuk konversi ke Map (untuk penyimpanan DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'officerNotes': officerNotes,
      'officerImagePath': officerImagePath,
    };
  }

  ReportModel copyWith({
    final int? id,
    final String? title,
    final String? description,
    final double? latitude,
    final double? longitude,
    final String? imagePath,
    final String? status,
    final String? officerNotes,
    final String? officerImagePath,
    
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      officerNotes: officerNotes ?? this.officerNotes,
      officerImagePath: officerImagePath ?? this.officerImagePath,
    );
  }

  // Metode untuk membuat objek dari Map (dari DB)
  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      // KOREKSI 2: Cast id ke int?
      id: map['id'] as int?,
      // Cast String dan pastikan tidak null (sesuai skema DB)
      title: map['title'] as String,
      description: map['description'] as String,
      imagePath: map['imagePath'] as String,

      // KOREKSI 3: Pastikan latitude dan longitude diubah ke double,
      // menangani jika SQFlite mengembalikan int (sebagai num)
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),

      status: map['status'] as String,
      // Cast nullable String
      officerNotes: map['officerNotes'] as String?,
      officerImagePath: map['officerImagePath'] as String?,
    );
  }
}
