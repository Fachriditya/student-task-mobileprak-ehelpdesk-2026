import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart'; 
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/preference_tile.dart';

// 1. Ubah jadi StatefulWidget agar bisa memanggil fetchProfile() saat halaman dibuka
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  @override
  void initState() {
    super.initState();
    // 2. Ambil data profil terbaru dari Supabase tepat saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();
    
    // 3. LOGIKA KUNCI: Prioritaskan nama dari ProfileProvider yang up-to-date.
    // Jika masih null (karena lagi loading), baru pakai data cadangan dari AuthProvider.
    final displayName = profile.userProfile?.fullName ?? auth.user?.name ?? "User";
    final displayEmail = profile.userProfile?.email ?? "${displayName.toLowerCase().replaceAll(' ', '.')}@email.com";

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: false),
      
      // Beri efek loading di tengah layar jika data sedang diambil
      body: profile.isLoading && profile.userProfile == null 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4B39EF))) 
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Masukkan variabel displayName ke Header
            buildProfileHeader(displayName, profile.userProfile?.joinDate ?? "January 2026"), 
            const SizedBox(height: 24),
            
            const Text("ACCOUNT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            
            // Masukkan variabel displayName ke ListTile
            ListTile(
              leading: const Icon(Icons.person_outline), 
              title: Text(displayName), 
              subtitle: const Text("Full Name"),
              trailing: const Icon(Icons.edit, size: 20, color: Color(0xFF4B39EF)),
              onTap: () {
                // Panggil Pop-up Edit
                _showEditNameDialog(context, displayName);
              },
            ),
            ListTile(leading: const Icon(Icons.email_outlined), title: Text(displayEmail), subtitle: const Text("Email")),
            
            const SizedBox(height: 24),
            const Text("PREFERENCES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            buildPreferenceTile("Dark Mode", Icons.dark_mode_outlined, profile.isDarkMode, (val) {
              profile.toggleDarkMode(val);
            }),
            buildPreferenceTile("Notifications", Icons.notifications_none, profile.notificationsEnabled, (val) {
              profile.toggleNotifications(val);
            }),
            
            const SizedBox(height: 24),
            
            TextButton(
              onPressed: () async {
                await context.read<AuthProvider>().logout(); 
                if (context.mounted) {
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

  // --- WIDGET POP-UP EDIT ---
  void _showEditNameDialog(BuildContext context, String currentName) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Username", style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Full Name",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  // Jalankan fungsi update
                  final success = await context.read<ProfileProvider>().updateUsername(nameController.text.trim());
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Tutup pop-up
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? "Profile updated successfully!" : "Failed to update profile."),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B39EF)),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}