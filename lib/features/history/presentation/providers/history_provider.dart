import 'package:flutter/material.dart';
import '../../data/models/history_model.dart';
import '../../data/repositories/history_repository.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryRepository _historyRepository = HistoryRepository();

  List<HistoryModel> _histories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<HistoryModel> get histories => _histories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fungsi untuk menarik data ke UI
  Future<void> loadHistories(String ticketId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _histories = await _historyRepository.fetchHistories(ticketId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi jembatan untuk mencatat riwayat baru dari mana saja
  Future<void> addHistoryLog(String ticketId, String action) async {
    await _historyRepository.recordHistory(ticketId: ticketId, action: action);
    // Setelah mencatat log baru, perbarui list history di UI
    await loadHistories(ticketId);
  }
}