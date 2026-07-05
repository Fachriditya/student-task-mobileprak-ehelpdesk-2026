class TicketModel {
  final String id;
  final String title;
  final String description;
  final String category; // <-- INI YANG TADI KETINGGALAN
  final String status;
  final String priority; 
  final int attachmentCount;
  final int commentCount;
  final String date;
  
  // Variabel penampung URL foto
  final String? attachmentUrl; 

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category, // <-- TAMBAH DI SINI
    required this.status,
    required this.priority,
    required this.attachmentCount,
    required this.commentCount,
    required this.date,
    this.attachmentUrl,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General', // <-- TANGKAP DATA DARI DATABASE
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'Medium', 
      
      attachmentCount: json['attachment_url'] != null ? 1 : 0, 
      commentCount: 0, 
      date: json['created_at'] ?? '', 
      attachmentUrl: json['attachment_url'], 
    );
  }
}