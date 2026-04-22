class CalendarEvent {
  final String id;
  final DateTime date;
  final String title;
  final String? outfitId;

  const CalendarEvent({
    required this.id,
    required this.date,
    required this.title,
    this.outfitId,
  });

  CalendarEvent copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? outfitId,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      outfitId: outfitId ?? this.outfitId,
    );
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'].toString(),
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      outfitId: json['outfit_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'outfit_id': outfitId,
    };
  }
}
