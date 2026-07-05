import 'package:flutter/material.dart';
import '../../data/models/comment_model.dart'; 

class CommentBubble extends StatelessWidget {
  final CommentModel comment;
  
  // Ganti boolean isMe menjadi role pengguna yang sedang melihat aplikasi
  final String currentUserRole; 

  const CommentBubble({
    super.key, 
    required this.comment,
    required this.currentUserRole, // Wajib diisi dari TicketDetailPage
  });

  // --- LOGIKA POV KANAN-KIRI (Zero to Hero Edition) ---
  bool get isRightSide {
    final viewer = currentUserRole.toLowerCase();
    final sender = comment.senderRole.toLowerCase();

    // Cek apakah mereka berada di kubu Helpdesk
    final isViewerHelpdesk = viewer == 'helpdesk';
    final isSenderHelpdesk = sender == 'helpdesk';

    if (isViewerHelpdesk) {
      // POV Helpdesk: Jika yang ngirim adalah Helpdesk juga, taruh KANAN. 
      // (User & Admin akan ada di Kiri)
      return isSenderHelpdesk; 
    } else {
      // POV Admin/User: Jika yang ngirim BUKAN Helpdesk (artinya Admin/User), taruh KANAN.
      // (Helpdesk akan ada di Kiri)
      return !isSenderHelpdesk; 
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format waktu (contoh: 14:30)
    final timeString = "${comment.createdAt.hour.toString().padLeft(2, '0')}:${comment.createdAt.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        // Gunakan isRightSide pengganti isMe[cite: 11]
        mainAxisAlignment: isRightSide ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isRightSide) _buildAvatar(comment.senderName), 
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isRightSide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  "${comment.senderName} (${comment.senderRole}) • $timeString",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isRightSide ? const Color(0xFF4B39EF) : Colors.grey[200], 
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isRightSide ? const Radius.circular(0) : const Radius.circular(16),
                      bottomLeft: !isRightSide ? const Radius.circular(0) : const Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: isRightSide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      // JIKA ADA FOTO[cite: 11]
                      if (comment.attachmentUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            comment.attachmentUrl!,
                            width: 200, 
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (comment.message.isNotEmpty) const SizedBox(height: 8),
                      ],
                      // TAMPILKAN TEKS[cite: 11]
                      if (comment.message.isNotEmpty)
                        Text(
                          comment.message,
                          style: TextStyle(
                            color: isRightSide ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isRightSide) _buildAvatar(comment.senderName), 
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    String initial = name.isNotEmpty ? name[0].toUpperCase() : "?";
    
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.blueGrey[100],
      child: Text(
        initial,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}