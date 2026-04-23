import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final Function(String) onSelected;

  const PrioritySelector({super.key, required this.selectedPriority, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ["Low", "Medium", "High"].map((p) {
        bool isSelected = selectedPriority == p;
        Color color = p == "Low" ? Colors.teal : (p == "Medium" ? Colors.orange : Colors.red);
        
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(p),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                border: Border.all(color: color),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(p, style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}