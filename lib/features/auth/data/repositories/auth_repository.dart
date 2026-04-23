import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/local_storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient();

  Future<UserModel?> login(String username, String password) async {
    // 1. Tambahkan delay seolah-olah lagi nunggu internet
    await Future.delayed(const Duration(seconds: 2));

    try {
      // --- LOGIKA SIMULASI (MOCKING) ---
      // Kita "hardcode" dulu agar kamu bisa masuk ke Dashboard
      if (username == "admin" && password == "123456") {
        return UserModel(id: "1", username: "Admin", role: "Admin");
      } else if (username == "user" && password == "123456") {
        return UserModel(id: "2", username: "Fachri Ditya", role: "User");
      } else if (username == "helpdesk" && password == "123456") {
        return UserModel(id: "3", username: "Helpdesk", role: "Helpdesk");
      } else {
        // Jika username/password salah, lempar error manual
        throw "Username atau password salah (Simulasi)";
      }
      
      /* Komentari dulu bagian Dio ini sampai Backend kamu siap:
      final response = await _dioClient.dio.post('/login', data: {
        'username': username,
        'password': password,
      });
      ...
      */
      
    } catch (e) {
      // Menangkap pesan error agar bisa tampil di UI
      throw e.toString();
    }
  }

  Future<void> logout() async {
    await LocalStorageService.clearAuthData();
  }
}