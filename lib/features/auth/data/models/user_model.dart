// file: lib/features/auth/data/models/user_model.dart
class UserModel {
  final String id;
  final String name; // Diubah dari username menjadi name agar cocok dengan tabel 'profiles'
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: json['role'],
    );
  }
}