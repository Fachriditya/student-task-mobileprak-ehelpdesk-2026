import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final DioClient _dioClient = DioClient();

  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await _dioClient.dio.get('/profile');
      
      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw "Gagal memuat profil";
      }
    } catch (e) {
      throw "Terjadi kesalahan pada server";
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.put('/profile/update', data: data);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}