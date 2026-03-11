import 'package:flutter/material.dart';

class OutfitItemData {
  final String name;
  final IconData icon;

  const OutfitItemData({
    required this.name,
    required this.icon,
  });
}

class OutfitItem {
  final String id;
  final String title;
  final String style;
  final String season;
  final bool isFavorite;
  final List<OutfitItemData> items;

  const OutfitItem({
    required this.id,
    required this.title,
    required this.style,
    required this.season,
    this.isFavorite = false,
    required this.items,
  });

  OutfitItem copyWith({
    String? id,
    String? title,
    String? style,
    String? season,
    bool? isFavorite,
    List<OutfitItemData>? items,
  }) {
    return OutfitItem(
      id: id ?? this.id,
      title: title ?? this.title,
      style: style ?? this.style,
      season: season ?? this.season,
      isFavorite: isFavorite ?? this.isFavorite,
      items: items ?? this.items,
    );
  }
}
