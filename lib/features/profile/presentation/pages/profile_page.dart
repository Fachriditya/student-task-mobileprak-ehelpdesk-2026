import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// WAJIB IMPORT AUTH PROVIDER UNTUK AMBIL DATA USER & LOGOUT
import '../../../auth/presentation/providers/auth_provider.dart'; 
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/preference_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Pantau ProfileProvider (untuk switch Dark Mode & Notif)
    final profile = context.watch<ProfileProvider>();
    
    // 2. Pantau AuthProvider (untuk data User)
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    
    // 3. Buat nama dinamis (Fallback ke "User" kalau null)
    final userName = user?.username ?? "User";
    // Bikin email bohongan berdasarkan username (Misal: Fachri Admin -> fachri.admin@email.com)
    final userEmail = "${userName.toLowerCase().replaceAll(' ', '.')}@email.com";

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gunakan variabel userName di sini
            buildProfileHeader(userName, "January 2026"), 
            const SizedBox(height: 24),
            
            const Text("ACCOUNT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            // Gunakan variabel userName dan userEmail di sini
            ListTile(leading: const Icon(Icons.person_outline), title: Text(userName), subtitle: const Text("Full Name")),
            ListTile(leading: const Icon(Icons.email_outlined), title: Text(userEmail), subtitle: const Text("Email")),
            
            const SizedBox(height: 24),
            const Text("PREFERENCES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            buildPreferenceTile("Dark Mode", Icons.dark_mode_outlined, profile.isDarkMode, (val) {
              profile.toggleDarkMode(val);
            }),
            buildPreferenceTile("Notifications", Icons.notifications_none, profile.notificationsEnabled, (val) {
              profile.toggleNotifications(val);
            }),
            
            const SizedBox(height: 24),
            // --- LOGIKA SIGN OUT ---
            TextButton(
              onPressed: () async {
                await context.read<AuthProvider>().logout(); // Hapus token/sesi
                
                if (context.mounted) {
                  // Lempar kembali ke halaman login dan hapus semua history layar sebelumnya
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              }, 
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Row(
                children: [Icon(Icons.logout), SizedBox(width: 8), Text("Sign Out")],
              ),
            ),
          ],
        ),
      ),
    );
  }
}