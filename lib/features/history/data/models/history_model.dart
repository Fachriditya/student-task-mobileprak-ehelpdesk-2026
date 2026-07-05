class HistoryModel {
  final String id;
  final String ticketId;
  final String changedBy;
  final String changerName; // Hasil join dengan tabel profiles
  final String action;
  final DateTime createdAt;

  HistoryModel({
    required this.id,
    required this.ticketId,
    required this.changedBy,
    required this.changerName,
    required this.action,
    required this.createdAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] ?? '',
      ticketId: json['ticket_id'] ?? '',
      changedBy: json['changed_by'] ?? '',
      // Menarik nama dari relasi tabel profiles
      changerName: json['profiles']?['name'] ?? 'System',
      action: json['action'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']).toLocal() 
          : DateTime.now(),
    );
  }
}