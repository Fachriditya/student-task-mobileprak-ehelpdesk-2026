import '../../../../main.dart'; // Sesuaikan jumlah '../' agar pas mengarah ke main.dart
import 'package:flutter/material.dart';
// import supabase_flutter SUDAH DIHAPUS DARI SINI
import '../../data/models/ticket_model.dart';
import '../../data/repositories/ticket_repository.dart'; 
import '../../../notification/data/repositories/notification_repository.dart';

class TicketProvider extends ChangeNotifier {
  final TicketRepository _ticketRepository = TicketRepository();
  final NotificationRepository _notificationRepo = NotificationRepository();

  List<TicketModel> _allTickets = []; 

  String _selectedFilter = "All";
  bool _isLoading = false;
  String? _errorMessage; 

  // GETTERS UNTUK UI
  List<TicketModel> get tickets {
    if (_selectedFilter == "All") return _allTickets;
    return _allTickets.where((t) {
      return t.status.trim().toLowerCase() == _selectedFilter.trim().toLowerCase();
    }).toList();
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
      final title = data['title'] ?? "New Support Ticket";
      
      final success = await _ticketRepository.createTicket(
        title: title,
        category: data['category'] ?? "General",
        priority: data['priority'] ?? "Medium",
        description: data['description'] ?? "",
        fileBytes: data['fileBytes'],
        fileName: data['fileName'],
      );

      if (success) {
        // TEMBAK NOTIFIKASI KE SEMUA ADMIN
        await _notificationRepo.notifyAllAdmins(
          ticketId: null, 
          title: 'Tiket Baru Masuk! 🚨',
          message: 'Ada tiket baru: "$title". Segera cek dan tugaskan ke teknisi.',
        );

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
        // Cari data tiket menggunakan _allTickets
        final ticket = _allTickets.firstWhere((t) => t.id == ticketId);

        // TEMBAK NOTIFIKASI KE HELPDESK
        await _notificationRepo.sendNotification(
          targetUserId: helpdeskId,
          ticketId: ticketId,
          title: 'Tugas Baru: ${ticket.title}',
          message: 'Admin menugaskan tiket ini kepadamu. Segera cek dan proses!',
        );

        // TEMBAK NOTIFIKASI KE USER (PEMILIK TIKET)
        await _notificationRepo.sendNotification(
          targetUserId: ticket.userId, 
          ticketId: ticketId,
          title: 'Tiket Diproses 🚀',
          message: 'Tiket "${ticket.title}" sedang ditangani oleh tim teknisi kami.',
        );

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
      final success = await _ticketRepository.updateTicketStatus(ticketId, 'closed');
      
      if (success) {
        // Cari data tiket menggunakan _allTickets
        final ticket = _allTickets.firstWhere((t) => t.id == ticketId);

        // TEMBAK NOTIFIKASI KE USER
        await _notificationRepo.sendNotification(
          targetUserId: ticket.userId,
          ticketId: ticketId,
          title: 'Tiket Selesai ✅',
          message: 'Masalah pada tiket "${ticket.title}" telah diselesaikan dan ditutup. Terima kasih!',
        );

        // Logika refresh list sesuai role pengguna yang login
        final role = supabase.auth.currentUser?.userMetadata?['role']?.toString().toLowerCase() ?? '';
        
        // --- PERBAIKAN ROLE ADMIN DI SINI ---
        if (role == 'isadmin' || role == 'issuperadmin') {
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