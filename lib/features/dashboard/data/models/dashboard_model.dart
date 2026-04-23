import '../../../../features/ticket/data/models/ticket_model.dart';

class DashboardModel {
  final int totalTickets;
  final int openTickets;
  final int inProgressTickets;
  final int closedTickets;
  final List<TicketModel> recentTickets;

  DashboardModel({
    required this.totalTickets,
    required this.openTickets,
    required this.inProgressTickets,
    required this.closedTickets,
    required this.recentTickets,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalTickets: json['total_tickets'],
      openTickets: json['open_tickets'],
      inProgressTickets: json['in_progress_tickets'],
      closedTickets: json['closed_tickets'],
      recentTickets: (json['recent_tickets'] as List)
          .map((t) => TicketModel.fromJson(t))
          .toList(),
    );
  }
}