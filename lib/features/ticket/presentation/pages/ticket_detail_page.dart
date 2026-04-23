import 'package:flutter/material.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/comment_model.dart';
import '../widgets/comment_bubble.dart';

class TicketDetailPage extends StatelessWidget {
  final TicketModel ticket;

  const TicketDetailPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final List<CommentModel> dummyComments = [
      CommentModel(
        id: "1",
        isMe: true,
        senderName: "You",
        senderRole: "User",
        timeAgo: "2h ago",
        message: "I've attached screenshots of the error.",
      ),
      CommentModel(
        id: "2",
        isMe: false,
        senderName: "Sarah",
        senderRole: "Agent",
        timeAgo: "1h ago",
        message: "Thank you for reaching out. We're looking into this right away. Can you tell us your device type?",
      ),
    ];

    return Scaffold(
      // Background abu-abu muda agar card warna putihnya menonjol seperti di desain
      backgroundColor: const Color(0xFFF8F9FA),
      
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 14, color: Colors.black87),
          label: const Text("Back", style: TextStyle(color: Colors.black87, fontSize: 14)),
        ),
        title: Text(ticket.id, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),

      // --- BODY ---
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SECTION: HEADER TICKET
                  _buildCardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ticket.title,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildStatusPill(ticket.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildTagPill(Icons.sell_outlined, "Account Access"),
                            const SizedBox(width: 8),
                            _buildPriorityPill(ticket.priority),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildProgressTracker(ticket.status), // Stepper UI
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ),
                        Row(
                          children: [
                            Text("Created: ${ticket.date}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(width: 16),
                            const Text("Updated: Apr 20, 2026", style: TextStyle(color: Colors.grey, fontSize: 12)), // Hardcoded mock
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. SECTION: DESCRIPTION
                  _buildCardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("DESCRIPTION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        Text(
                          ticket.description,
                          style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. SECTION: ATTACHMENTS
                  if (ticket.attachmentCount > 0)
                    _buildCardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ATTACHMENTS (${ticket.attachmentCount})", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildAttachmentPill("screenshot_1.png"),
                              _buildAttachmentPill("document_2.pdf"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 4. SECTION: COMMENTS
                  _buildCardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("COMMENTS (${dummyComments.length})", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                        const SizedBox(height: 16),
                        ...dummyComments.map((comment) => CommentBubble(comment: comment)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- BOTTOM CHAT INPUT ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Write a reply...",
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF), // Biru sangat muda
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.send, color: Color(0xFF4B39EF), size: 20),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildStatusPill(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEef2FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4B39EF).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFF4B39EF)),
          const SizedBox(width: 6),
          Text(status, style: const TextStyle(color: Color(0xFF4B39EF), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTagPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPriorityPill(String priority) {
    Color color = priority == "High" ? Colors.red : (priority == "Medium" ? Colors.orange : Colors.blue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(priority, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAttachmentPill(String filename) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 16, color: Color(0xFF4B39EF)),
          const SizedBox(width: 8),
          Text(filename, style: const TextStyle(color: Colors.black87, fontSize: 13)),
        ],
      ),
    );
  }

  // Visualisasi Tracker
  Widget _buildProgressTracker(String currentStatus) {
    return Row(
      children: [
        _buildStep("Open", isActive: true),
        Expanded(child: Container(height: 2, color: const Color(0xFFEEEEEE))),
        _buildStep("In Progress", isActive: currentStatus == "In Progress" || currentStatus == "Closed"),
        Expanded(child: Container(height: 2, color: const Color(0xFFEEEEEE))),
        _buildStep("Closed", isActive: currentStatus == "Closed"),
      ],
    );
  }

  Widget _buildStep(String label, {required bool isActive}) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? const Color(0xFF4B39EF) : Colors.grey.shade300, width: 2),
            color: Colors.white,
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? const Color(0xFF4B39EF) : Colors.transparent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.black87 : Colors.grey)),
      ],
    );
  }
}