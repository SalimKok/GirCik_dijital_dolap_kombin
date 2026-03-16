import 'package:flutter/material.dart';

enum LaundryStatus {
  needsWash,
  washing,
  clean,
}

class LaundryItem {
  final String id;
  final String name;
  final String category;
  final int wearCount;
  final int maxWear;
  final IconData icon;
  final LaundryStatus status;

  const LaundryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.wearCount,
    required this.maxWear,
    required this.icon,
    required this.status,
  });

  LaundryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? wearCount,
    int? maxWear,
    IconData? icon,
    LaundryStatus? status,
  }) {
    return LaundryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      wearCount: wearCount ?? this.wearCount,
      maxWear: maxWear ?? this.maxWear,
      icon: icon ?? this.icon,
      status: status ?? this.status,
    );
  }

  factory LaundryItem.fromJson(Map<String, dynamic> json) {
    // Determine status from string, defaulting to needsWash
    final statusStr = json['status'] as String?;
    LaundryStatus parsedStatus = LaundryStatus.needsWash;
    if (statusStr == 'washing') {
      parsedStatus = LaundryStatus.washing;
    } else if (statusStr == 'clean') {
      parsedStatus = LaundryStatus.clean;
    }

    return LaundryItem(
      id: json['id'].toString(),
      name: json['clothing_item']?['name'] as String? ?? 'Bilinmeyen Kıyafet',
      category: json['clothing_item']?['category'] as String? ?? 'Kategori Yok',
      wearCount: json['wear_count'] as int? ?? 0,
      maxWear: json['max_wear'] as int? ?? 3,
      icon: Icons.checkroom, // Can be mapped if needed
      status: parsedStatus,
    );
  }

  Map<String, dynamic> toJson() {
    String statusStr = 'needs_wash';
    if (status == LaundryStatus.washing) statusStr = 'washing';
    if (status == LaundryStatus.clean) statusStr = 'clean';

    return {
      'id': id,
      // name, category and icon aren't sent to backend directly (it's a relation), 
      // but we might need to send wear_count or status for updates
      'wear_count': wearCount,
      'max_wear': maxWear,
      'status': statusStr,
    };
  }
}
