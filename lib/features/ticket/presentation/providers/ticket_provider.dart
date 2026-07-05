import '../../../../main.dart'; // Sesuaikan jumlah '../' agar pas mengarah ke main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/ticket_model.dart';
import '../../data/repositories/ticket_repository.dart'; 

class TicketProvider extends ChangeNotifier {
  final TicketRepository _ticketRepository = TicketRepository();

  List<TicketModel> _allTickets = []; 

  String _selectedFilter = "All";
  bool _isLoading = false;
  String? _errorMessage; 

  // GETTERS UNTUK UI
  List<TicketModel> get tickets {
    if (_selectedFilter == "All") return _allTickets;
    return _allTickets.where((t) => t.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }
  List<TicketModel> get allTickets => _allTickets;

  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;
  String? get errorMessage => _errorMessage;

  // GETTERS UNTUK DASHBOARD 
  int get totalCount => _allTickets.length;
  int get openCount => _allTickets.where((t) => t.status.toLowerCase() == "open").length;
  int get assignCount => _allTickets.where((t) => t.status.toLowerCase() == "assign").length;
  int get inProgressCount => _allTickets.where((t) => t.status.toLowerCase() == "in progress").length;
  int get closedCount => _allTickets.where((t) => t.status.toLowerCase() == "closed").length;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
  
  // --- FUNGSI UTAMA USER (Melihat tiket buatannya sendiri) ---
  Future<void> loadTickets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); 
    
    try {
      _allTickets = await _ticketRepository.fetchTickets();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  // --- FUNGSI UTAMA HELPDESK (Melihat tiket yang di-assign ke dia) ---
  Future<void> loadHelpdeskTickets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); 
    
    try {
      // Kita panggil fungsi khusus dari repository
      _allTickets = await _ticketRepository.fetchHelpdeskTickets();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  // Mengirim tiket baru ke Supabase
  Future<bool> addTicket(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _ticketRepository.createTicket(
        title: data['title'] ?? "New Support Ticket",
        category: data['category'] ?? "General",
        priority: data['priority'] ?? "Medium",
        description: data['description'] ?? "",
        fileBytes: data['fileBytes'],
        fileName: data['fileName'],
      );

      if (success) {
        await loadTickets(); 
      }
      
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- LOGIKA KHUSUS ADMIN ---

  // Admin melihat semua tiket di sistem
  Future<void> loadAllTickets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); 
    
    try {
      _allTickets = await _ticketRepository.fetchAllTickets();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  // Admin menerima tiket (Status: Open -> Assign)
  Future<bool> acknowledgeTicket(String ticketId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _ticketRepository.updateTicketStatus(ticketId, 'assign');
      if (success) {
        await loadAllTickets(); 
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Admin menugaskan tiket ke Helpdesk tertentu
  Future<bool> assignTicketToHelpdesk(String ticketId, String helpdeskId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _ticketRepository.assignHelpdesk(ticketId, helpdeskId);
      if (success) {
        await loadAllTickets(); 
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fungsi untuk Menutup Tiket (Bisa dipakai Admin atau Helpdesk)
  Future<bool> closeTicket(String ticketId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Kita pakai fungsi updateTicketStatus dari repository yang sudah ada
      final success = await _ticketRepository.updateTicketStatus(ticketId, 'closed');
      
      if (success) {
        // Tarik ulang data sesuai role agar list di depan ikut ter-update
        final role = supabase.auth.currentUser?.userMetadata?['role']?.toString().toLowerCase() ?? '';
        if (role == 'admin' || role == 'isadmin' || role == 'issuperadmin') {
          await loadAllTickets();
        } else if (role == 'helpdesk') {
          await loadHelpdeskTickets();
        } else {
          await loadTickets();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}