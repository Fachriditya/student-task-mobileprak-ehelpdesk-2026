  class UserProfileModel {
    final String fullName;
    final String email;
    final String phone;
    final String joinDate;
    final int totalTickets;
    final int activeTickets;
    final int resolvedTickets;

    UserProfileModel({
      required this.fullName,
      required this.email,
      required this.phone,
      required this.joinDate,
      required this.totalTickets,
      required this.activeTickets,
      required this.resolvedTickets,
    });

    factory UserProfileModel.fromJson(Map<String, dynamic> json) {
      return UserProfileModel(
        fullName: json['full_name'],
        email: json['email'],
        phone: json['phone'],
        joinDate: json['join_date'],
        totalTickets: json['total_tickets'],
        activeTickets: json['active_tickets'],
        resolvedTickets: json['resolved_tickets'],
      );
    }
  }