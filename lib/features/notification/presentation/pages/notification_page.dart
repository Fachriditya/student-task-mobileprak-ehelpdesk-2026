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
      // 👇 Scaffold dilepas backgroundColor-nya agar otomatis ikut AppTheme
      appBar: AppBar(
        title: Text(
          'Notifications', 
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color, // 👈 Judul dinamis
            fontSize: 16, 
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: Colors.transparent, // 👈 Bikin transparan biar nge-blend
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
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
                      color: notif.isRead 
                          ? Theme.of(context).cardTheme.color 
                          : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        // 👇 Background ikon dibikin dinamis agar tidak nabrak di dark mode
                        backgroundColor: notif.isRead 
                            ? Theme.of(context).dividerColor.withValues(alpha: 0.1) 
                            : const Color(0xFF4B39EF).withValues(alpha: 0.1),
                        child: Icon(
                          Icons.notifications_active,
                          color: notif.isRead ? Colors.grey : const Color(0xFF4B39EF),
                        ),
                      ),
                      title: Text(
                        notif.title, 
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold, 
                          color: Theme.of(context).colorScheme.onSurface,
                        )
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notif.message, 
                            style: TextStyle(
                              fontSize: 13, 
                              // 👇 Warna pesan diubah jadi onSurface dengan opacity biar selalu kontras
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
                            )
                          ),
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
          // 👇 Menghindari error warning, pakai withValues
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text("No Notifications Yet", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("We'll let you know when something arrives.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}