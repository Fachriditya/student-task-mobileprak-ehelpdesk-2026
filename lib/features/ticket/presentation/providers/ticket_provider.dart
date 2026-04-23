import 'package:flutter/material.dart';
import '../../data/models/ticket_model.dart';

class TicketProvider extends ChangeNotifier {
  // 1. DATA DUMMY AWAL (Ini akan langsung muncul di UI)
  final List<TicketModel> _allTickets = [
    TicketModel(
      id: "TKT-001",
      title: "Unable to login to the portal",
      description: "I have been trying to login since yesterday but I keep getting an error message saying 'Invalid credentials'.",
      status: "Open",
      priority: "High",
      attachmentCount: 2,
      commentCount: 2,
      date: "Apr 20, 2026",
    ),
    TicketModel(
      id: "TKT-002",
      title: "Payment not reflected after checkout",
      description: "Made a payment of \$120 on April 18th but the ticket still shows unpaid.",
      status: "In Progress",
      priority: "Medium",
      attachmentCount: 1,
      commentCount: 1,
      date: "Apr 18, 2026",
    ),
    TicketModel(
      id: "TKT-003",
      title: "Request for event ticket refund",
      description: "I need a refund for event TKT-CON-2026 as the event was cancelled.",
      status: "Closed",
      priority: "Medium",
      attachmentCount: 0,
      commentCount: 1,
      date: "Apr 10, 2026",
    ),
    TicketModel(
      id: "TKT-004",
      title: "App crashes on Android 14",
      description: "The mobile app crashes every time I try to open a ticket.",
      status: "Open",
      priority: "High",
      attachmentCount: 3,
      commentCount: 0,
      date: "Apr 22, 2026",
    ),
  ];

  String _selectedFilter = "All";
  bool _isLoading = false;

  // 2. GETTERS UNTUK LIST TIKET & FILTER
  List<TicketModel> get tickets {
    if (_selectedFilter == "All") return _allTickets;
    return _allTickets.where((t) => t.status == _selectedFilter).toList();
  }

  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;

  // 3. GETTERS UNTUK DASHBOARD (Ini yang tadi bikin Dashboard merah)
  int get totalCount => _allTickets.length;
  int get openCount => _allTickets.where((t) => t.status == "Open").length;
  int get inProgressCount => _allTickets.where((t) => t.status == "In Progress").length;
  int get closedCount => _allTickets.where((t) => t.status == "Closed").length;

  // --- FUNGSI-FUNGSI LOGIKA ---

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // MOCK: Fungsi Tambah Tiket (Tanpa API Backend)
  Future<bool> addTicket(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    // Simulasi loading 1 detik (biar kelihatan realistis)
    await Future.delayed(const Duration(seconds: 1));

    // Buat ID baru secara otomatis
    final newId = "TKT-00${_allTickets.length + 1}";
    
    // Rakit tiket baru dari inputan form Create Ticket
    final newTicket = TicketModel(
      id: newId,
      title: data['title'] ?? "New Support Ticket",
      description: data['description'] ?? "No description provided.",
      status: "Open", // Tiket baru selalu Open
      priority: data['priority'] ?? "Medium",
      attachmentCount: data['filePath'] != null ? 1 : 0,
      commentCount: 0,
      date: "Apr 22, 2026",
    );

    // Masukkan tiket baru ke urutan paling atas
    _allTickets.insert(0, newTicket);

    _isLoading = false;
    notifyListeners();
    return true; // Berhasil
  }

  // MOCK: Fungsi Load Tiket
  Future<void> loadTickets() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulasi loading aja, datanya kan udah ada di _allTickets
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    notifyListeners();
  }
}