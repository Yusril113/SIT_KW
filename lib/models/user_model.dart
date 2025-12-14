class UserModel {
  final int? id;
  final String username;
  final String? email; // Ditambahkan: Email kini diperlukan
  final String password;
  final String role; // Ditambahkan: Role (misalnya 'Admin', 'Officer')

  UserModel({
    this.id,
    required this.username,
    this.email, // Dibuat opsional di konstruktor
    required this.password,
    required this.role, // Dibuat wajib di konstruktor
  });

  // Digunakan untuk menyimpan data ke database (saat register/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    };
  }
  
  // Digunakan untuk membaca data dari database (saat login/fetch)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      // Karena kolom 'email' di DB Anda NOT NULL, kita bisa mengasumsikannya ada.
      // Gunakan null check untuk keamanan, meskipun DB sudah menjamin.
      email: map['email'] as String?, 
      password: map['password'] as String,
      role: map['role'] as String,
    );
  }
}