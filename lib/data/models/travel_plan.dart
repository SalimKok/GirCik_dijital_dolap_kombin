class TravelPlan {
  final String id;
  final int userId;
  final String destination;
  final String startDate;
  final String endDate;
  final String purpose;
  final Map<String, dynamic> itinerary;
  final DateTime createdAt;

  TravelPlan({
    required this.id,
    required this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.purpose,
    required this.itinerary,
    required this.createdAt,
  });

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      id: json['id'],
      userId: json['user_id'],
      destination: json['destination'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      purpose: json['purpose'],
      itinerary: json['itinerary'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
