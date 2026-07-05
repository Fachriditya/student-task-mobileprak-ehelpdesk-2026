class UserProfileModel {
  final String id; // Tambahkan ini
  final String fullName;
  final String email;
  final String phone;
  final String joinDate;
  final int totalTickets;
  final int activeTickets;
  final int resolvedTickets;

  UserProfileModel({
    required this.id, // Tambahkan ini
    required this.fullName,
    required this.email,
    required this.phone,
    required this.joinDate,
    required this.totalTickets,
    required this.activeTickets,
    required this.resolvedTickets,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '', // Tambahkan ini, sesuaikan dengan key di Supabase
      fullName: json['name'] ?? 'User', 
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      joinDate: json['join_date'] ?? '',
      totalTickets: json['total_tickets'] ?? 0,
      activeTickets: json['active_tickets'] ?? 0,
      resolvedTickets: json['resolved_tickets'] ?? 0,
    );
  }
}