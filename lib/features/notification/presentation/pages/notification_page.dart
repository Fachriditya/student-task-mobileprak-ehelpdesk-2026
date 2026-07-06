import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    // Tarik data notifikasi terbaru saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      body: provider.isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4B39EF)))
        : provider.errorMessage != null 
          ? Center(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)))
          : provider.notifications.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notif = provider.notifications[index];
                  // Format waktu sederhana
                  final timeStr = "${notif.createdAt.day}/${notif.createdAt.month} • ${notif.createdAt.hour.toString().padLeft(2, '0')}:${notif.createdAt.minute.toString().padLeft(2, '0')}";

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      // Warna beda untuk yang belum dibaca (Unread)
                      color: notif.isRead ? Colors.white : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: notif.isRead ? Colors.grey.shade200 : const Color(0xFF4B39EF).withOpacity(0.1),
                        child: Icon(
                          Icons.notifications_active,
                          color: notif.isRead ? Colors.grey : const Color(0xFF4B39EF),
                        ),
                      ),
                      title: Text(
                        notif.title, 
                        style: TextStyle(fontSize: 14, fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold)
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notif.message, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                          const SizedBox(height: 8),
                          Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      onTap: () {
                        // Ubah status jadi 'Read' saat di-klik
                        if (!notif.isRead) {
                          context.read<NotificationProvider>().markAsRead(notif.id);
                        }
                      },
                    ),
                  );
                },
              )
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No Notifications Yet", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("We'll let you know when something arrives.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}