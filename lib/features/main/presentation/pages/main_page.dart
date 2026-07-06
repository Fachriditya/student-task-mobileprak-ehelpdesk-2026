import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../../ticket/presentation/pages/ticket_list_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../../dashboard/presentation/pages/helpdesk_dashboard_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Kita buat fungsi dinamis untuk menyortir halaman berdasarkan role
  List<Widget> _getPages(String role) {
    // Memastikan akses admin dan superadmin terbaca semua
    final hasAdminAccess = (role == 'admin' || role == 'isadmin' || role == 'issuperadmin');

    if (hasAdminAccess) {
      return [
        const AdminDashboardPage(), // 0. Dashboard Admin
        const TicketListPage(),     // 1. Ticket List (Mode Admin)
        const ProfilePage(),        // 2. Profil
      ];
    } else if (role == 'helpdesk') {
      return [
        const HelpdeskDashboardPage(), // <-- Ganti baris ini
        const TicketListPage(),     
        const ProfilePage(),        
      ];
    } else {
      return [
        const DashboardPage(),      // 0. Dashboard User
        const TicketListPage(),     // 1. Ticket List (Mode User)
        const ProfilePage(),        // 2. Profil
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil role yang sedang login
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.user?.role.toLowerCase() ?? 'pengguna';

    // Panggil daftar halaman sesuai role
    final pages = _getPages(role);

    // Pengaman: Jika index saat ini melebih jumlah halaman yang ada
    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      // MENGGUNAKAN INDEXEDSTACK AGAR STA[cite: 12]TE TAB TIDAK HILANG SAAT PINDAH TAB
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF4B39EF), // Ungu khas Figma-mu[cite: 12]
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: "Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}