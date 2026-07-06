import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../main.dart'; // 👇 IMPORT SAKTI SUPABASE DITAMBAHKAN
import '../../../auth/presentation/providers/auth_provider.dart'; 
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/preference_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();
    
    final displayName = profile.userProfile?.fullName ?? auth.user?.name ?? "User";
    
    // 👇 PERBAIKAN BUG EMAIL: Tarik paksa dari inti Supabase!
    final displayEmail = supabase.auth.currentUser?.email ?? "No Email Found";

    return Scaffold(
      // 👇 PERBAIKAN TOMBOL KEMBALI BIAR PASTI MUNCUL
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)), 
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: profile.isLoading && profile.userProfile == null 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4B39EF))) 
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            buildProfileHeader(displayName, profile.userProfile?.joinDate ?? "2026"), 
            const SizedBox(height: 24),
            
            const Text("ACCOUNT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            
            ListTile(
              contentPadding: EdgeInsets.zero, // Biar rata kiri
              leading: const Icon(Icons.person_outline), 
              title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)), 
              subtitle: const Text("Full Name"),
              trailing: const Icon(Icons.edit, size: 20, color: Color(0xFF4B39EF)),
              onTap: () {
                _showEditNameDialog(context, displayName);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email_outlined), 
              title: Text(displayEmail, style: const TextStyle(fontWeight: FontWeight.bold)), 
              subtitle: const Text("Email")
            ),
            
            const SizedBox(height: 24),
            const Text("PREFERENCES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            buildPreferenceTile("Dark Mode", Icons.dark_mode_outlined, profile.isDarkMode, (val) {
              profile.toggleDarkMode(val);
            }),
            buildPreferenceTile("Notifications", Icons.notifications_none, profile.notificationsEnabled, (val) {
              profile.toggleNotifications(val);
            }),
            
            const SizedBox(height: 32),
            
            // 👇 PERBAIKAN TOMBOL LOGOUT: Biar cakep & profesional
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout(); 
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                }, 
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  final success = await context.read<ProfileProvider>().updateUsername(nameController.text.trim());
                  
                  if (context.mounted) {
                    Navigator.pop(context); 
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