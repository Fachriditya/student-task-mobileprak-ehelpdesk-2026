import 'package:flutter/material.dart';

class StatusTracker extends StatelessWidget {
  final String currentStatus;
  const StatusTracker({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep("Open", true),
        _buildLine(currentStatus != "Open"),
        _buildStep("In Progress", currentStatus == "In Progress" || currentStatus == "Closed"),
        _buildLine(currentStatus == "Closed"),
        _buildStep("Closed", currentStatus == "Closed"),
      ],
    );
  }

  Widget _buildStep(String title, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? const Color(0xFF4B39EF) : Colors.grey[300],
          child: Icon(Icons.check, size: 14, color: isActive ? Colors.white : Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 10, color: isActive ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _buildLine(bool isActive) => Expanded(
    child: Container(height: 2, color: isActive ? const Color(0xFF4B39EF) : Colors.grey[300]),
  );
}