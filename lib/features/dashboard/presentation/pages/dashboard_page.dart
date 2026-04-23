import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:helpdesk_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:helpdesk_app/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:helpdesk_app/core/constants/app_constants.dart';
import '../widgets/dashboard_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Fungsi helper untuk Inisial Nama (Fachri Admin -> FA)
  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 2 ? 2 : names.length;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0].toUpperCase();
      }
    }
    return initials;
  }

  @override
  Widget build(BuildContext context) {
    // Memantau AuthProvider untuk data User (Nama & Role)
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    // Memantau TicketProvider sebagai "Single Source of Truth" data tiket
    final ticketProvider = context.watch<TicketProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header dengan Nama dan Inisial Dinamis
              _buildHeader(user?.username ?? "User"),
              const SizedBox(height: 24),
              
              // 2. Grid Statistik (Mengambil angka asli dari TicketProvider)
              _buildStatGrid(ticketProvider),
              const SizedBox(height: 24),
              
              // 3. Ticket Overview (Donut Chart dengan Legend)
              const Text(
                "Ticket Overview", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 12),
              const TicketOverviewChart(), 
              const SizedBox(height: 24),
              
              // 4. Section Recent Tickets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Tickets", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  if (ticketProvider.tickets.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Logika untuk pindah ke tab Ticket (index 1 di MainPage)
                        // Kamu bisa tambahkan logic ini nanti
                      }, 
                      child: const Text("See all")
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // CEK: Jika data kosong tampilkan Empty State, jika ada tampilkan List
              ticketProvider.tickets.isEmpty 
                ? _buildEmptyState() 
                : _buildRecentTicketsList(ticketProvider),
            ],
          ),
        ),
      ),
      // Floating Action Button hanya muncul untuk role User
      floatingActionButton: user?.role == AppConstants.roleUser 
        ? FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
            backgroundColor: const Color(0xFF4B39EF),
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
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
            const Text("Good afternoon 👋", style: TextStyle(color: Colors.grey)),
            Text(
              name, 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF4B39EF),
          child: Text(
            _getInitials(name), 
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )
          ),
        )
      ],
    );
  }

  Widget _buildStatGrid(TicketProvider data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          label: "Total Tickets", 
          count: data.totalCount.toString(), 
          color: Colors.blue, 
          icon: Icons.assignment
        ),
        StatCard(
          label: "Open Tickets", 
          count: data.openCount.toString(), 
          color: Colors.indigo, 
          icon: Icons.confirmation_number
        ),
        StatCard(
          label: "In Progress", 
          count: data.inProgressCount.toString(), 
          color: Colors.orange, 
          icon: Icons.cached
        ),
        StatCard(
          label: "Closed Tickets", 
          count: data.closedCount.toString(), 
          color: Colors.green, 
          icon: Icons.check_circle
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No tickets found", 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)
          ),
          const Text(
            "Your recent ticket activity will appear here.", 
            style: TextStyle(color: Colors.grey, fontSize: 12)
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTicketsList(TicketProvider data) {
    // Kita ambil maksimal 3 tiket terbaru untuk ditampilkan di dashboard
    final recentTickets = data.tickets.length > 3 
        ? data.tickets.sublist(0, 3) 
        : data.tickets;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentTickets.length,
      itemBuilder: (context, index) {
        final ticket = recentTickets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              ticket.title, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text("${ticket.id} • ${ticket.date}"),
            ),
            trailing: _buildStatusBadge(ticket.status),
            onTap: () {
              // Navigasi ke Detail Tiket bisa ditambahkan di sini
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case "Open":
        color = Colors.blue;
        break;
      case "In Progress":
        color = Colors.orange;
        break;
      case "Closed":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(8)
      ),
      child: Text(
        status, 
        style: TextStyle(
          color: color, 
          fontSize: 11, 
          fontWeight: FontWeight.bold
        )
      ),
    );
  }
}