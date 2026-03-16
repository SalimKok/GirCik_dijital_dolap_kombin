class CalendarEvent {
  final String id;
  final DateTime date;
  final String title;

  const CalendarEvent({
    required this.id,
    required this.date,
    required this.title,
  });

  CalendarEvent copyWith({
    String? id,
    DateTime? date,
    String? title,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
    );
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'].toString(),
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
    };
  }
}
