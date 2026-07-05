import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:helpdesk_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:helpdesk_app/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:helpdesk_app/core/constants/app_constants.dart';
import '../widgets/dashboard_widget.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
// IMPORT DIPERBAIKI: Mengarah ke TicketListPage
import '../../../ticket/presentation/pages/ticket_list_page.dart'; 

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final ticketProvider = context.watch<TicketProvider>();

    final profileProvider = context.watch<ProfileProvider>();
    final String displayName = profileProvider.userProfile?.fullName ?? authProvider.user?.name ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(displayName),
              const SizedBox(height: 24),
              
              _buildStatGrid(ticketProvider),
              const SizedBox(height: 24),
              
              const Text(
                "Ticket Overview", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 12),
              const TicketOverviewChart(), 
              const SizedBox(height: 24),
              
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
                        // ROUTING DIPERBAIKI: Mengarah ke TicketListPage
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const TicketListPage())
                        );
                      }, 
                      child: const Text("See all tickets", style: TextStyle(color: Color(0xFF4B39EF), fontWeight: FontWeight.bold))
                    ),
                ],
              ),
              const SizedBox(height: 12),

              ticketProvider.tickets.isEmpty 
                ? _buildEmptyState() 
                : _buildRecentTicketsList(ticketProvider),
            ],
          ),
        ),
      ),
      floatingActionButton: user?.role == AppConstants.roleUser 
        ? FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
            backgroundColor: const Color(0xFF4B39EF),
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hello 👋", style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text(
              name, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF4B39EF),
          child: Text(
            _getInitials(name), 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
          ),
        )
      ],
    );
  }

  Widget _buildStatGrid(TicketProvider data) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: StatCard(
            label: "Total Tickets", 
            count: data.totalCount.toString(), 
            color: Colors.blue, 
            icon: Icons.assignment
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: "Open Tickets", 
                count: data.openCount.toString(), 
                color: Colors.indigo, 
                icon: Icons.confirmation_number
              )
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                label: "Assign Tickets", 
                count: data.assignCount.toString(), 
                color: Colors.purple, 
                icon: Icons.person_add_alt_1
              )
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: "In Progress", 
                count: data.inProgressCount.toString(), 
                color: Colors.orange, 
                icon: Icons.cached
              )
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                label: "Closed Tickets", 
                count: data.closedCount.toString(), 
                color: Colors.green, 
                icon: Icons.check_circle
              )
            ),
          ],
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
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No tickets found", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("Your recent ticket activity will appear here.", style: TextStyle(color: Colors.grey, fontSize: 12)),
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
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
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
              // Kosongkan sementara
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