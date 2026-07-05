import 'package:flutter/material.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/comment_repository.dart';

class CommentProvider extends ChangeNotifier {
  final CommentRepository _repository = CommentRepository();

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
  // 2. Kirim komentar baru
  Future<bool> sendComment(String ticketId, String message, {dynamic fileBytes, String? fileName}) async {
    // Boleh kosong pesannya ASALKAN ada fotonya
    if (message.trim().isEmpty && fileBytes == null) return false;

    try {
      final success = await _repository.sendComment(
        ticketId: ticketId, 
        message: message,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      if (success) {
        await fetchComments(ticketId); // Refresh daftar komentar
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}