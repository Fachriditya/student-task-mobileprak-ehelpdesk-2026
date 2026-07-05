import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo = ProfileRepository();

  List<UserProfileModel> _helpdeskUsers = [];
  List<UserProfileModel> get helpdeskUsers => _helpdeskUsers;

  UserProfileModel? _userProfile;
  UserProfileModel? get userProfile => _userProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userProfile = await _repo.getUserProfile();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  // Tambahkan fungsi ini untuk update nama
  Future<bool> updateUsername(String newName) async {
    _isLoading = true;
    notifyListeners();

    // UBAH 'full_name' MENJADI 'name' SESUAI DATABASE
    bool success = await _repo.updateProfile({'name': newName}); 
    
    if (success) {
      await fetchProfile(); 
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> loadHelpdeskUsers() async {
    try {
      _helpdeskUsers = await _repo.fetchHelpdeskUsers();
      notifyListeners();
    } catch (e) {
      print("Error load helpdesk: $e");
    }
  }
}