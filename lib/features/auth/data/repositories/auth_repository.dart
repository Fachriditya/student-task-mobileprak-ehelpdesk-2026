// file: lib/features/auth/data/repositories/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
// Import main.dart untuk memanggil variabel 'supabase' global yang sudah kita buat
import '../../../../main.dart'; 
import '../models/user_model.dart';

class AuthRepository {
  // DioClient tidak dipakai lagi karena Supabase sudah punya HTTP client sendiri bawaan package-nya

  Future<UserModel?> login(String email, String password) async {
    try {
      // 1. Tembak API Supabase Auth untuk Login
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      final User? user = res.user;
      if (user == null) throw "Gagal login, data kredensial salah.";

      // 2. Ambil data role dan name dari tabel 'profiles'
      // eq('id', user.id) artinya kita cari profil yang id-nya sama dengan id auth yang login
      // 1. Gunakan maybeSingle()
      final profileData = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // 2. Cek apakah null
      if (profileData == null) {
        // Kalau null, berarti user belum punya profil.
        // Kamu bisa throw error yang lebih bersahabat atau buatkan profil default
        throw "User profile not found in database!"; 
      }

      // 3. Lanjut proses
      return UserModel.fromJson(profileData);
      
    } on AuthException catch (e) {
      // Menangkap error bawaan Supabase (Misal: Password salah, Email tidak ditemukan)
      throw e.message; 
    } catch (e) {
      throw "Terjadi kesalahan sistem: ${e.toString()}";
    }
  }

  Future<UserModel?> register(String email, String password, String name, String role) async {
    try {
      // 1. Daftarkan akun ke sistem Auth Supabase
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      final User? user = res.user;
      if (user == null) throw "Gagal mendaftar. Silakan coba lagi.";

      // 2. Simpan data tambahan (name, role) ke tabel 'profiles' public kita
      await supabase.from('profiles').insert({
        'id': user.id, // ID ini harus sama persis dengan ID Auth Supabase
        'name': name,
        'role': role,
      });

      // 3. Kembalikan data sebagai object UserModel
      return UserModel(id: user.id, name: name, role: role);
      
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw "Terjadi kesalahan sistem: ${e.toString()}";
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      // Supabase akan otomatis mengirimkan email berisi link reset password
      await supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw "Terjadi kesalahan sistem: ${e.toString()}";
    }
  }

  Future<void> logout() async {
    try {
      // Menghapus sesi login di Supabase
      await supabase.auth.signOut();
    } catch (e) {
      throw e.toString();
    }
  }
}