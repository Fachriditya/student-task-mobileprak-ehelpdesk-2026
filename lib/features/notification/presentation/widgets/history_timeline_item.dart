import 'package:flutter/material.dart';
import '../../data/models/history_model.dart';

class HistoryTimelineItem extends StatelessWidget {
  final HistoryModel history;
  final bool isLast;

  const HistoryTimelineItem({super.key, required this.history, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const CircleAvatar(radius: 6, backgroundColor: Color(0xFF4B39EF)),
            if (!isLast) Container(width: 2, height: 50, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(history.action, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                history.createdAt.toString().substring(0, 16), 
                style: const TextStyle(fontSize: 12, color: Colors.grey)
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}