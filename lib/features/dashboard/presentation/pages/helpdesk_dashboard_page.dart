import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../widgets/dashboard_widget.dart';
import '../../../ticket/presentation/pages/ticket_list_page.dart';
import '../../../notification/presentation/widgets/notification_bell.dart';

class HelpdeskDashboardPage extends StatefulWidget {
  const HelpdeskDashboardPage({super.key});

  @override
  State<HelpdeskDashboardPage> createState() => _HelpdeskDashboardPageState();
}

class _HelpdeskDashboardPageState extends State<HelpdeskDashboardPage> {
  @override
  void initState() {
    super.initState();
    // PENTING: Tarik hanya tiket yang ditugaskan ke helpdesk ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketProvider>().loadHelpdeskTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final ticketProvider = context.watch<TicketProvider>();

    final String displayName = profileProvider.userProfile?.fullName ?? authProvider.user?.name ?? "Helpdesk";

    return Scaffold(
      body: SafeArea(
        child: ticketProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4B39EF)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HEADER KHUSUS HELPDESK
                    _buildHeader(displayName),
                    const SizedBox(height: 24),
                    
                    // 2. GRID STATISTIK TUGAS
                    const Text(
                      "My Tasks Overview", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 12),
                    _buildStatGrid(ticketProvider),
                    const SizedBox(height: 24),
                    
                    // 3. TUGAS TERBARU
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Tasks", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        if (ticketProvider.tickets.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => const TicketListPage())
                              );
                            }, 
                            child: const Text("See all tasks", style: TextStyle(color: Color(0xFF4B39EF), fontWeight: FontWeight.bold))
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 4. LIST TUGAS (Atau kosong)
                    ticketProvider.tickets.isEmpty 
                      ? _buildEmptyState() 
                      : _buildRecentTicketsList(ticketProvider),
                  ],
                ),
              ),
      ),
      // Helpdesk tidak ada tombol tambah (add) tiket
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Helpdesk Workspace 👨‍💻", style: TextStyle(color: Colors.teal, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(
              name, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        Row(
          children: [
            const NotificationBell(), // Lonceng notifikasi
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.teal, 
              child: Icon(Icons.support_agent, color: Colors.white), // Kembali pakai Icon
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStatGrid(TicketProvider data) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: StatCard(label: "Total Assigned Tasks", count: data.totalCount.toString(), color: Colors.blue, icon: Icons.assignment),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: StatCard(label: "New Assign", count: data.assignCount.toString(), color: Colors.purple, icon: Icons.person_add_alt_1)),
            const SizedBox(width: 16),
            Expanded(child: StatCard(label: "In Progress", count: data.inProgressCount.toString(), color: Colors.orange, icon: Icons.cached)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: StatCard(label: "Completed (Closed)", count: data.closedCount.toString(), color: Colors.green, icon: Icons.check_circle),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(Icons.coffee, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No tasks assigned yet", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("Take a break or check back later.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecentTicketsList(TicketProvider data) {
    final recentTickets = data.tickets.length > 3 ? data.tickets.sublist(0, 3) : data.tickets;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentTickets.length,
      itemBuilder: (context, index) {
        final ticket = recentTickets[index];
        final shortDate = ticket.date.length >= 10 ? ticket.date.substring(0, 10) : ticket.date;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(ticket.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.sell_outlined, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text("${ticket.category.isNotEmpty ? ticket.category : 'General'} • $shortDate", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            trailing: _buildPriorityBadge(ticket.priority),
            onTap: () {
              // Navigasi ke detail tiket saat diklik
            },
          ),
        );
      },
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color = priority.toLowerCase() == 'high' ? Colors.red : (priority.toLowerCase() == 'medium' ? Colors.orange : Colors.teal);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        priority, 
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)
      ),
    );
  }
}