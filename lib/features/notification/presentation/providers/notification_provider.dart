import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // GETTERS
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fitur sakti untuk menghitung badge merah di ikon lonceng
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // 1. Mengambil Notifikasi untuk ditampilkan di UI
  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _repository.fetchMyNotifications();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Mengubah status menjadi terbaca saat notifikasi di-klik
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      // Panggil ulang loadNotifications agar UI (termasuk angka badge) ter-update
      await loadNotifications(); 
    } catch (e) {
      print("Gagal read notifikasi: $e");
    }
  }

  // --- FUNGSI TRIGGER (Dipanggil oleh TicketProvider) ---

  // Tembak Notifikasi Personal (Ke User / Helpdesk)
  Future<void> sendPersonalNotification({
    required String targetUserId, 
    required String ticketId, 
    required String title, 
    required String message
  }) async {
    await _repository.sendNotification(
      targetUserId: targetUserId, 
      ticketId: ticketId, 
      title: title, 
      message: message
    );
  }

  // Tembak Notifikasi Massal (Ke Semua Admin)
  Future<void> sendAdminNotification({
    required String ticketId, 
    required String title, 
    required String message
  }) async {
    await _repository.notifyAllAdmins(
      ticketId: ticketId, 
      title: title, 
      message: message
    );
  }
}