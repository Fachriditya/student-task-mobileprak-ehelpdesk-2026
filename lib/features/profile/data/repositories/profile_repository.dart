import '../../../../main.dart'; // Memanggil kurir Supabase
import '../models/profile_model.dart';

class ProfileRepository {
  
  // 1. Fungsi Ambil Data Profil (Pakai Supabase)
  Future<UserProfileModel> getUserProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw "User tidak terautentikasi";

      // Minta data ke tabel 'profiles' di Supabase
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .single(); // Ambil 1 baris saja
      
      return UserProfileModel.fromJson(response);
    } catch (e) {
      throw "Gagal memuat profil: $e";
    }
  }

  // 2. Fungsi Update Nama Profil (Pakai Supabase)
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Kirim data update ke tabel 'profiles' di Supabase
      await supabase
          .from('profiles')
          .update(data)
          .eq('id', userId);
          
      return true; // Berhasil!
    } catch (e) {
      print("Error Update Profile Supabase: $e");
      return false; // Gagal
    }
  }

  // Pastikan namanya sesuai dengan yang ada di file model.dart-mu!
  Future<List<UserProfileModel>> fetchHelpdeskUsers() async { 
    try {
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('role', 'helpdesk');
          
      // Ganti UserModel dengan UserProfileModel
      return (response as List).map((x) => UserProfileModel.fromJson(x)).toList();
    } catch (e) {
      throw "Gagal ambil list helpdesk: $e";
    }
  }
}