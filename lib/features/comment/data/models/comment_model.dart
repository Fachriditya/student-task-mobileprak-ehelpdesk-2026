class CommentModel {
  final String id;
  final String ticketId;
  final String userId;
  final String message;
  final DateTime createdAt;
  final String senderName;
  final String senderRole;
  final String? attachmentUrl; // 1. TAMBAH INI

  CommentModel({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.message,
    required this.createdAt,
    required this.senderName,
    required this.senderRole,
    this.attachmentUrl, // 2. TAMBAH INI
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] ?? {};
    return CommentModel(
      id: json['id'] ?? '',
      ticketId: json['ticket_id'] ?? '',
      userId: json['user_id'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      senderName: profile['name'] ?? 'User Unknown',
      senderRole: profile['role'] ?? 'pengguna',
      attachmentUrl: json['attachment_url'], // 3. TANGKAP DATANYA
    );
  }
}