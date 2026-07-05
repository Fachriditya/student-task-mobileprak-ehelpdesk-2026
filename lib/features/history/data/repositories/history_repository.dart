import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../main.dart'; // Pastikan path ini benar mengarah ke inisialisasi supabase-mu
import '../models/history_model.dart';

class HistoryRepository {
  
  // 1. Mengambil riwayat perjalanan sebuah tiket 
  Future<List<HistoryModel>> fetchHistories(String ticketId) async {
    try {
      final response = await supabase
          .from('ticket_histories')
          .select('*, profiles(name)') 
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true); // Urut dari awal dibuat sampai sekarang

      return (response as List).map((x) => HistoryModel.fromJson(x)).toList();
    } catch (e) {
      throw "Gagal mengambil riwayat tiket: $e";
    }
  }

  // 2. Fungsi untuk mencatat riwayat (Dipanggil ketika ada aksi)
  Future<void> recordHistory({required String ticketId, required String action}) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      await supabase.from('ticket_histories').insert({
        'ticket_id': ticketId,
        'changed_by': userId,
        'action': action,
      });
    } catch (e) {
      print("Gagal mencatat riwayat: $e");
    }
  }
}