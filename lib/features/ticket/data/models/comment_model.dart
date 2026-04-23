class CommentModel {
  final String id;
  final String senderName;
  final String senderRole;
  final String message;
  final String timeAgo;
  final bool isMe;

  CommentModel({
    required this.id,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timeAgo,
    required this.isMe,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    return CommentModel(
      id: json['id'],
      senderName: json['sender_name'],
      senderRole: json['sender_role'],
      message: json['message'],
      timeAgo: json['time_ago'],
      isMe: json['sender_id'] == currentUserId,
    );
  }
}