import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../main.dart'; // Sesuaikan arah import ke main.dart
import '../models/notification_model.dart';

class NotificationRepository {
  
  // 1. Mengambil Notifikasi Milik User yang Sedang Login
  Future<List<NotificationModel>> fetchMyNotifications() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw "User belum login";

      final response = await supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false); // Yang paling baru di atas

      return (response as List).map((x) => NotificationModel.fromJson(x)).toList();
    } catch (e) {
      throw "Gagal mengambil notifikasi: $e";
    }
  }

  // 2. Mengubah Status Notifikasi Menjadi "Sudah Dibaca"
  Future<void> markAsRead(String notificationId) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print("Gagal update status read: $e");
    }
  }

  // 3. Menembak Notifikasi ke SATU Orang (Contoh: Notif ke User atau Helpdesk)
  Future<void> sendNotification({
    required String targetUserId, 
    required String ticketId, 
    required String title, 
    required String message
  }) async {
    try {
      await supabase.from('notifications').insert({
        'user_id': targetUserId,
        'ticket_id': ticketId,
        'title': title,
        'message': message,
      });
    } catch (e) {
      print("Gagal kirim notifikasi personal: $e");
    }
  }

  // 4. Menembak Notifikasi ke SEMUA ADMIN (Saat User Bikin Tiket Baru)
  Future<void> notifyAllAdmins({
    String? ticketId, 
    required String title, 
    required String message
  }) async {
    try {
      // Cari siapa saja yang punya role admin / isadmin / issuperadmin
      final admins = await supabase
          .from('profiles')
          .select('id')
          .inFilter('role', ['admin', 'isadmin', 'issuperadmin']); 

      // Jika ada admin, buatkan list data notifikasinya
      if ((admins as List).isNotEmpty) {
        final List<Map<String, dynamic>> notificationsToInsert = admins.map((admin) {
          return {
            'user_id': admin['id'],
            'ticket_id': ticketId,
            'title': title,
            'message': message,
          };
        }).toList();

        // Tembak massal ke database
        await supabase.from('notifications').insert(notificationsToInsert);
      }
    } catch (e) {
      print("Gagal kirim notifikasi ke admin: $e");
    }
  }
}