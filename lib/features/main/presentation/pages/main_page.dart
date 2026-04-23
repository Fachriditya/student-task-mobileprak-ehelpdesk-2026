import 'package:flutter/material.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../ticket/presentation/pages/ticket_list_page.dart'; // Import ini
import '../../../profile/presentation/pages/profile_page.dart';     // Import ini

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Sekarang halamannya beneran ada, bukan cuma Text lagi
  final List<Widget> _pages = [
    const DashboardPage(),
    const TicketListPage(), 
    const ProfilePage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pakai IndexedStack supaya state halaman nggak ilang pas pindah tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF4B39EF),
        type: BottomNavigationBarType.fixed, // Biar stabil kalau itemnya nambah
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined), 
            activeIcon: Icon(Icons.dashboard),
            label: "Dashboard"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined), 
            activeIcon: Icon(Icons.confirmation_number),
            label: "Tickets"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            activeIcon: Icon(Icons.person),
            label: "Profile"
          ),
        ],
      ),
    );
  }
}