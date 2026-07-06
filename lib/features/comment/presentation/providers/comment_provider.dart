import 'package:flutter/material.dart';
import '../../../../main.dart'; // Untuk memanggil Supabase auth
import '../../data/models/comment_model.dart';
import '../../data/repositories/comment_repository.dart';
import '../../../notification/data/repositories/notification_repository.dart';
import '../../../ticket/data/models/ticket_model.dart'; // Import Model Tiket

class CommentProvider extends ChangeNotifier {
  final CommentRepository _repository = CommentRepository();
  
  // ---> INI DIA SENJATA NOTIFIKASINYA WAK! <---
  final NotificationRepository _notificationRepo = NotificationRepository(); 

  List<CommentModel> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. Ambil daftar komentar berdasarkan tiket
  Future<void> fetchComments(String ticketId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await _repository.getComments(ticketId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Kirim komentar baru
  // PERBAIKAN: Tambahkan "String senderRole" di sini
  Future<bool> sendComment(TicketModel ticket, String message, String senderRole, {dynamic fileBytes, String? fileName}) async {
    if (message.trim().isEmpty && fileBytes == null) return false;

    try {
      final success = await _repository.sendComment(
        ticketId: ticket.id, 
        message: message,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      
      if (success) {
        await fetchComments(ticket.id); 

        final notifMessage = message.trim().isNotEmpty ? message : 'Mengirim sebuah lampiran/foto 📎';

        // A. ADMIN SELALU PANTAU (Ini yang bikin admin dapet terus)
        await _notificationRepo.notifyAllAdmins(
          ticketId: ticket.id,
          title: 'Pesan Baru di Tiket: ${ticket.title} 💬',
          message: notifMessage,
        );

        // B. LOGIKA SILANG BERDASARKAN "senderRole" YANG PASTI BENAR
        if (senderRole == 'user') {
          // User nge-chat -> Tembak ke Helpdesk
          if (ticket.helpdeskId != null && ticket.helpdeskId!.isNotEmpty) {
            await _notificationRepo.sendNotification(
              targetUserId: ticket.helpdeskId!,
              ticketId: ticket.id,
              title: 'Balasan dari User 💬',
              message: notifMessage,
            );
          }
        } 
        else if (senderRole == 'helpdesk') {
          // Helpdesk nge-chat -> Tembak ke User
          if (ticket.userId.isNotEmpty) {
            await _notificationRepo.sendNotification(
              targetUserId: ticket.userId,
              ticketId: ticket.id,
              title: 'Teknisi membalas pesanmu 💬',
              message: notifMessage,
            );
          }
        } 
        // C. LOGIKA ADMIN 
        else if (senderRole == 'admin' || senderRole == 'isadmin' || senderRole == 'issuperadmin') {
          await _notificationRepo.sendNotification(
            targetUserId: ticket.userId,
            ticketId: ticket.id,
            title: 'Admin membalas tiketmu 💬',
            message: notifMessage,
          );
          if (ticket.helpdeskId != null && ticket.helpdeskId!.isNotEmpty) {
            await _notificationRepo.sendNotification(
              targetUserId: ticket.helpdeskId!,
              ticketId: ticket.id,
              title: 'Instruksi Admin 💬',
              message: notifMessage,
            );
          }
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}