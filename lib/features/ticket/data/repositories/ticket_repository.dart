import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/ticket_model.dart';

class TicketRepository {
  final DioClient _dioClient = DioClient();

  Future<List<TicketModel>> fetchTickets() async {
    try {
      final response = await _dioClient.dio.get('/tickets');
      return (response.data['data'] as List)
          .map((json) => TicketModel.fromJson(json))
          .toList();
    } catch (e) {
      throw "Gagal mengambil daftar tiket";
    }
  }

  Future<bool> createTicket({
    required String title,
    required String category,
    required String priority,
    required String description,
    String? filePath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "title": title,
        "category": category,
        "priority": priority,
        "description": description,
        if (filePath != null)
          "file": await MultipartFile.fromFile(filePath),
      });

      final response = await _dioClient.dio.post('/tickets', data: formData);
      
      // Status 201 biasanya berarti 'Created' sukses
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      throw "Gagal membuat tiket baru";
    }
  }
}