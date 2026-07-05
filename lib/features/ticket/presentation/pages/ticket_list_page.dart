import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      final role = context.read<AuthProvider>().user?.role.toLowerCase() ?? '';
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

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final role = authProvider.user?.role.toLowerCase() ?? 'pengguna';
    final hasAdminAccess = (role == 'admin' || role == 'isadmin' || role == 'issuperadmin');
    final isHelpdesk = (role == 'helpdesk');

    // Logic penentuan list data yang dipakai
    final displayTickets = hasAdminAccess ? ticketProvider.allTickets : ticketProvider.tickets;

    // Logic penentuan Teks UI
    String titleText = "My Tickets";
    String searchHint = "Search tickets...";
    
    if (hasAdminAccess) {
      titleText = "All Tickets";
      searchHint = "Search all tickets...";
    } else if (isHelpdesk) {
      titleText = "My Tasks"; // Teks khusus Helpdesk
      searchHint = "Search tasks...";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ["All", "Open", "Assign", "In Progress", "Closed"].map((filter) {
                bool isSelected = ticketProvider.selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => ticketProvider.setFilter(filter),
                    selectedColor: const Color(0xFF4B39EF),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: ticketProvider.errorMessage != null 
            ? Center(child: Text(ticketProvider.errorMessage!, style: const TextStyle(color: Colors.red)))
            : ticketProvider.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : displayTickets.isEmpty 
                ? const Center(child: Text("Belum ada tiket saat ini."))
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
                        child: TicketCard(ticket: currentTicket), 
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
}