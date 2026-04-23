class TicketModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority; 
  final int attachmentCount;
  final int commentCount;
  final String date;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.attachmentCount,
    required this.commentCount,
    required this.date,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      priority: json['priority'],
      attachmentCount: json['attachment_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      date: json['date'],
    );
  }
}