import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../main.dart'; // Sesuaikan dengan letak inisialisasi supabase global-mu
import '../models/comment_model.dart';

class CommentRepository {
  
  // Mengambil daftar komentar berdasarkan ID tiket
  Future<List<CommentModel>> getComments(String ticketId) async {
    try {
      // Query relasi (JOIN) untuk mengambil isi komentar sekaligus nama & role profilnya
      final response = await supabase
          .from('comments')
          .select('*, profiles(name, role)')
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true); // Urut dari terlama ke terbaru

      return (response as List)
          .map((json) => CommentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw "Gagal memuat komentar: ${e.toString()}";
    }
  }

  // Mengirim komentar baru ke tiket tertentu
  // MENGIRIM KOMENTAR BARU (BESERTA FOTO)
  Future<bool> sendComment({
    required String ticketId, 
    required String message,
    dynamic fileBytes, // Penampung file foto
    String? fileName,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw "Sesi login habis, silakan login ulang.";

      String? attachmentUrl;

      // PROSES UPLOAD JIKA ADA FOTO
      if (fileBytes != null && fileName != null) {
        final uniquePath = 'comment_uploads/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        await supabase.storage.from('attachments').uploadBinary(uniquePath, fileBytes);
        attachmentUrl = supabase.storage.from('attachments').getPublicUrl(uniquePath);
      }

      // INSERT KE TABEL COMMENTS
      await supabase.from('comments').insert({
        'ticket_id': ticketId,
        'user_id': userId,
        'message': message,
        'attachment_url': attachmentUrl, // Masukkan URL fotonya
      });

      return true;
    } catch (e) {
      throw "Gagal mengirim komentar: ${e.toString()}";
    }
  }
}