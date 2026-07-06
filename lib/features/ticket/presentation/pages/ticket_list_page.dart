import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../main.dart'; // Import Supabase untuk keamanan fallback role
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_widget.dart';
import 'ticket_detail_page.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ambil role dengan tingkat keamanan ekstra (menggunakan metadata fallback)
      final authRole = context.read<AuthProvider>().user?.role.toLowerCase() ?? '';
      final role = authRole.isNotEmpty ? authRole : supabase.auth.currentUser?.userMetadata?['role']?.toString().toLowerCase() ?? '';
      
      final hasAdminAccess = (role == 'admin' || role == 'isadmin' || role == 'issuperadmin');
      final isHelpdesk = (role == 'helpdesk');

      // Tentukan data mana yang harus ditarik dari database!
      if (hasAdminAccess) {
        context.read<TicketProvider>().loadAllTickets(); // Admin: Tarik semua tiket
      } else if (isHelpdesk) {
        context.read<TicketProvider>().loadHelpdeskTickets(); // Helpdesk: Tarik tiket tugasnya
      } else {
        context.read<TicketProvider>().loadTickets(); // User: Tarik tiket buatannya sendiri
      }
    });
  }

  // --- WIDGET FILTER MODERN (Zero to Hero UI) ---
  Widget _buildFilterChips(TicketProvider provider) {
    final List<String> filters = ["All", "Open", "Assign", "In Progress", "Closed"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = provider.selectedFilter.toLowerCase() == filter.toLowerCase();

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => provider.setFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4B39EF) : Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4B39EF) : Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  ),
                  boxShadow: isSelected 
                      ? [BoxShadow(color: const Color(0xFF4B39EF).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] 
                      : [],
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    // Keamanan role ganda di UI
    final authRole = authProvider.user?.role.toLowerCase() ?? '';
    final role = authRole.isNotEmpty ? authRole : supabase.auth.currentUser?.userMetadata?['role']?.toString().toLowerCase() ?? 'pengguna';
    
    final hasAdminAccess = (role == 'admin' || role == 'isadmin' || role == 'issuperadmin');
    final isHelpdesk = (role == 'helpdesk');

    // 👇 PERBAIKAN KRUSIAL: Semua role HARUS menggunakan .tickets agar filternya bekerja!
    final displayTickets = ticketProvider.tickets;

    // Logic penentuan Teks UI
    String titleText = "My Tickets";
    String searchHint = "Search tickets...";
    
    if (hasAdminAccess) {
      titleText = "All Tickets";
      searchHint = "Search all tickets...";
    } else if (isHelpdesk) {
      titleText = "My Tasks"; 
      searchHint = "Search tasks...";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color,
        ),
        title: Text(titleText, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                // PERBAIKAN: withValues(alpha: ...)
                fillColor: Colors.grey.withValues(alpha: 0.1), 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          // --- Panggil Widget Filter ---
          _buildFilterChips(ticketProvider),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: ticketProvider.errorMessage != null 
            ? Center(child: Text(ticketProvider.errorMessage!, style: const TextStyle(color: Colors.red)))
            : ticketProvider.isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF4B39EF)))
              : displayTickets.isEmpty 
                ? _buildEmptyState() // Tampilan saat list kosong
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayTickets.length,
                    itemBuilder: (context, index) {
                      final currentTicket = displayTickets[index];
                      
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TicketDetailPage(ticket: currentTicket),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0), // Jarak antar tiket
                          child: TicketCard(ticket: currentTicket),
                        ), 
                      );
                    },
                  ),
          ),
        ],
      ),
      // Sembunyikan tombol Create (+) jika yang login adalah Helpdesk
      floatingActionButton: isHelpdesk 
        ? null 
        : FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
            backgroundColor: const Color(0xFF4B39EF),
            child: const Icon(Icons.add, color: Colors.white),
          ),
    );
  }

  // --- TAMPILAN JIKA LIST KOSONG ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Tidak ada tiket", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("Kategori ini masih kosong melompong.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}