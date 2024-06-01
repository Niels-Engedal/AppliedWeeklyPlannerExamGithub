import 'package:flutter/material.dart';
import 'package:weekly_planner_sf_main/model/tag.dart';

class Event {
  final int? id;
  final String title;
  final String description;
  final DateTime from;
  final DateTime to;
  final Color backgroundColor;
  final String effortLevel;
  final bool isAllDay;
  final List<Tag> tags;

  const Event({
    this.id,
    required this.title,
    required this.description,
    required this.from,
    required this.to,
    this.backgroundColor = Colors.lightGreen,
    this.effortLevel = "Recharge",
    this.isAllDay = false,
    this.tags = const [],
  });

  // CopyWith method remains the same
  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? from,
    DateTime? to,
    Color? backgroundColor,
    String? effortLevel,
    bool? isAllDay,
    List<Tag>? tags,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      from: from ?? this.from,
      to: to ?? this.to,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      effortLevel: effortLevel ?? this.effortLevel,
      isAllDay: isAllDay ?? this.isAllDay,
      tags: tags ?? this.tags,
    );
  }

  // Adjust toMap methods to remove tag serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'backgroundColor': backgroundColor.value.toString(),
      'effortLevel': effortLevel,
      'isAllDay': isAllDay ? 1 : 0,
    };
  }

  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id'); // Remove 'id' for insertion
    return map;
  }

  // Adjust factory constructor to not deal with tag serialization
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      from: DateTime.parse(map['from'] as String),
      to: DateTime.parse(map['to'] as String),
      backgroundColor: Color(int.parse(map['backgroundColor'] as String)),
      effortLevel: map['effortLevel'] as String,
      isAllDay: (map['isAllDay'] as int) == 1,
      tags: [], // Initially empty, tags will be loaded separately
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, title: $title, description: $description, from: $from, to: $to, backgroundColor: $backgroundColor, effortLevel: $effortLevel, isAllDay: $isAllDay, tags: $tags}';
  }
}
