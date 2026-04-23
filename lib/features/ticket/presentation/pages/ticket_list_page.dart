import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_widget.dart';
import 'ticket_detail_page.dart'; // WAJIB ADA BIAR GAK ERROR HALAMANNYA

class TicketListPage extends StatelessWidget {
  const TicketListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tickets", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search tickets...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ["All", "Open", "In Progress", "Closed"].map((filter) {
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
          
          // Tiket List 
          Expanded(
            child: ticketProvider.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: ticketProvider.tickets.length,
                  itemBuilder: (context, index) {
                    final currentTicket = ticketProvider.tickets[index];
                    
                    // JURUS PAMUNGKAS: Pindahkan navigasi ke sini pakai GestureDetector
                    return GestureDetector(
                      onTap: () {
                        // Kalau ini dipencet, paksa pindah ke TicketDetailPage
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
        backgroundColor: const Color(0xFF4B39EF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}