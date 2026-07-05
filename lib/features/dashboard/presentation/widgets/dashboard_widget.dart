import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  final IconData icon;

  const StatCard({
    super.key, 
    required this.label, 
    required this.count, 
    required this.color, 
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

// --- INDICATOR (Keterangan Warna) ---
class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  const Indicator({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// --- TICKET OVERVIEW CHART ---
class TicketOverviewChart extends StatelessWidget {
  const TicketOverviewChart({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketData = context.watch<TicketProvider>();

    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(value: ticketData.openCount.toDouble(), color: Colors.blue, radius: 15, showTitle: false),
                  PieChartSectionData(value: ticketData.inProgressCount.toDouble(), color: Colors.orange, radius: 15, showTitle: false),
                  PieChartSectionData(value: ticketData.closedCount.toDouble(), color: Colors.green, radius: 15, showTitle: false),
                  if (ticketData.totalCount == 0)
                    PieChartSectionData(value: 1, color: Colors.grey.shade200, radius: 15, showTitle: false),
                ],
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Indicator(color: Colors.blue, text: "Open (${ticketData.openCount})"),
              const SizedBox(height: 8),
              Indicator(color: Colors.orange, text: "In Progress (${ticketData.inProgressCount})"),
              const SizedBox(height: 8),
              Indicator(color: Colors.green, text: "Closed (${ticketData.closedCount})"),
            ],
          ),
        ],
      ),
    );
  }
}