import '../../../../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final DioClient _dioClient = DioClient();

  Future<DashboardModel> getDashboardData() async {
    try {
      final response = await _dioClient.dio.get('/dashboard-stats');
      return DashboardModel.fromJson(response.data);
    } catch (e) {
      throw "Gagal memuat data dashboard";
    }
  }
}