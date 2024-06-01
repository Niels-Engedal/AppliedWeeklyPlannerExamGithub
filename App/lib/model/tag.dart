
import 'package:flutter/material.dart';

class Tag {
  final int? id;
  final String text;
  final Color color;

  Tag({this.id, required this.text, required this.color});

  // Method to convert a Tag instance into a map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'color': color.value, // Storing the color as an integer.
    };
  }

  // A factory constructor to create a Tag instance from a map (e.g., from database query results).
  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int?,
      text: map['text'] as String,
      color: Color(map['color'] as int),
    );
  }

  @override
  String toString() => 'Tag(id: $id, text: $text, color: $color)';
}
