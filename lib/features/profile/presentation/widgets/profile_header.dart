import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';

Widget buildProfileHeader(String name, String joinDate) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF4B39EF),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const CircleAvatar(radius: 30, child: Text("AM")),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Member since $joinDate", style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        )
      ],
    ),
  );
}