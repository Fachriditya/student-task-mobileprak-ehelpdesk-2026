import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';

class TicketHistoryPage extends StatefulWidget {
  final String ticketId;
  final String ticketTitle;

  const TicketHistoryPage({super.key, required this.ticketId, required this.ticketTitle});

  @override
  State<TicketHistoryPage> createState() => _TicketHistoryPageState();
}

class _TicketHistoryPageState extends State<TicketHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Tarik data history saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistories(widget.ticketId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          children: [
            const Text("Ticket Journey", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text(widget.ticketTitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
      body: historyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyProvider.errorMessage != null
              ? Center(child: Text(historyProvider.errorMessage!, style: const TextStyle(color: Colors.red)))
              : historyProvider.histories.isEmpty
                  ? const Center(child: Text("Belum ada riwayat untuk tiket ini."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: historyProvider.histories.length,
                      itemBuilder: (context, index) {
                        final history = historyProvider.histories[index];
                        final isLast = index == historyProvider.histories.length - 1;
                        
                        // Format waktu
                        final dateStr = "${history.createdAt.day}/${history.createdAt.month}/${history.createdAt.year}";
                        final timeStr = "${history.createdAt.hour.toString().padLeft(2, '0')}:${history.createdAt.minute.toString().padLeft(2, '0')}";

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // KIRI: Waktu
                            SizedBox(
                              width: 70,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(dateStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                                  Text(timeStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // TENGAH: Garis & Titik Timeline
                            Column(
                              children: [
                                Container(
                                  width: 16, height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4B39EF),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFEef2FF), width: 3),
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 2,
                                    height: 50, // Tinggi garis penghubung
                                    color: Colors.grey.shade300,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            
                            // KANAN: Isi Aksi
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(history.action, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  Text("Oleh: ${history.changerName}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 32), // Jarak ke item berikutnya
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
    );
  }
}