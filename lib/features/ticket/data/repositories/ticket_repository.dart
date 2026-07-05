import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../main.dart'; 
import '../models/ticket_model.dart';

class TicketRepository {
  
  // --- 1. FUNGSI USER (Melihat tiket buatannya sendiri) ---
  Future<List<TicketModel>> fetchTickets() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw "User belum login!";

      final response = await supabase
          .from('tickets')
          .select()
          .eq('user_id', userId) // <-- PERBAIKAN: Filter khusus tiket miliknya
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TicketModel.fromJson(json))
          .toList();
    } catch (e) {
      throw "Gagal mengambil daftar tiket: ${e.toString()}";
    }
  }

  // --- 2. FUNGSI HELPDESK (Melihat tiket yang ditugaskan ke dia) ---
  Future<List<TicketModel>> fetchHelpdeskTickets() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw "User belum login!";

      final response = await supabase
          .from('tickets')
          .select()
          .eq('assigned_to', userId) // <-- FILTER: Hanya tiket tugas dia
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TicketModel.fromJson(json))
          .toList();
    } catch (e) {
      throw "Gagal mengambil tiket tugas: ${e.toString()}";
    }
  }

  // --- 3. FUNGSI ADMIN (Melihat semua tiket) ---
  Future<List<TicketModel>> fetchAllTickets() async {
    try {
      final response = await supabase
          .from('tickets')
          .select('*')
          .order('created_at', ascending: false); 
          
      return (response as List).map((x) => TicketModel.fromJson(x)).toList();
    } catch (e) {
      throw "Gagal mengambil semua tiket: $e";
    }
  }

  // --- FUNGSI CREATE TICKET ---
  Future<bool> createTicket({
    required String title,
    required String category, 
    required String priority, 
    required String description,
    final dynamic fileBytes, 
    String? fileName,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw "User belum login!";

      String? attachmentUrl;

      if (fileBytes != null && fileName != null) {
        final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
        final filePath = 'ticket_uploads/$uniqueFileName';

        await supabase.storage
            .from('attachments')
            .uploadBinary(filePath, fileBytes);

        attachmentUrl = supabase.storage
            .from('attachments')
            .getPublicUrl(filePath);
      }

      await supabase.from('tickets').insert({
        'user_id': userId,
        'title': title,
        'description': description, 
        'category': category,       
        'priority': priority,       
        'status': 'open',
        'attachment_url': attachmentUrl, 
      });
      
      return true; 
    } catch (e) {
      throw "Gagal membuat tiket: ${e.toString()}";
    }
  }

  // --- FUNGSI UPDATE STATUS TIKET ---
  Future<bool> updateTicketStatus(String ticketId, String newStatus) async {
    try {
      await supabase
          .from('tickets')
          .update({'status': newStatus})
          .eq('id', ticketId);
      return true;
    } catch (e) {
      throw "Gagal mengubah status: $e";
    }
  }

  // --- FUNGSI ASSIGN TIKET KE HELPDESK ---
  Future<bool> assignHelpdesk(String ticketId, String helpdeskId) async {
    try {
      await supabase
          .from('tickets')
          .update({
            'assigned_to': helpdeskId,
            'status': 'in progress' 
          })
          .eq('id', ticketId);
      return true;
    } catch (e) {
      throw "Gagal menugaskan helpdesk: $e";
    }
  }
}