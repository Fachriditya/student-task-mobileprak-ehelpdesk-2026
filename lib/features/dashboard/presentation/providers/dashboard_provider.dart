import 'package:flutter/material.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repo = DashboardRepository();

  DashboardModel? _data;
  DashboardModel? get data => _data;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      _data = await _repo.getDashboardData();
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}