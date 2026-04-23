import 'package:flutter/material.dart';
import '../../data/models/ticket_model.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(ticket.title, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                _buildStatusBadge(ticket.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(ticket.description, 
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(ticket.id, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 8),
                _buildPriorityBadge(ticket.priority),
                const Spacer(),
                const Icon(Icons.attach_file, size: 14, color: Colors.grey),
                Text(" ${ticket.attachmentCount} ", style: const TextStyle(fontSize: 12)),
                const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                Text(" ${ticket.commentCount} ", style: const TextStyle(fontSize: 12)),
                Text(ticket.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == "Open" ? Colors.blue : (status == "In Progress" ? Colors.orange : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.red),
          const SizedBox(width: 4),
          Text(priority, style: const TextStyle(color: Colors.red, fontSize: 11)),
        ],
      ),
    );
  }
}