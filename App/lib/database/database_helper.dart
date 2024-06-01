import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weekly_planner_sf_main/model/event.dart';
import 'package:weekly_planner_sf_main/model/tag.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('events.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);
  return await openDatabase(path, version: 1,
    onCreate: _createDB,
    onOpen: (db) {
      db.execute('PRAGMA foreign_keys = ON');
    },
  );
}

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE events(
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      title TEXT, 
      description TEXT, 
      "from" TEXT,
      "to" TEXT,
      backgroundColor TEXT,
      effortLevel TEXT, 
      isAllDay INTEGER
    )
  '''); // IMPORTANT! Note the "" around from and to, these are reserved keywords in SQL, so best practice would be to change them...

  // separate table for tags to utilize efficient SQL
    await db.execute('''
  CREATE TABLE tags(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    text TEXT UNIQUE,
    color INTEGER
  )
  ''');

  // separate table for many-to-many relationships between events and tags
  await db.execute('''
  CREATE TABLE event_tags(
    event_id INTEGER,
    tag_id INTEGER,
    FOREIGN KEY(event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY(tag_id) REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY(event_id, tag_id)
  )
  ''');
  
    // Create a settings table
    await db.execute('''
    CREATE TABLE settings(
      key TEXT PRIMARY KEY, 
      value TEXT
    )
  ''');
  }

  Future<Event> insertEvent(Event event) async {
    final db = await instance.database;
    final id = await db.insert('events', event.toMapForInsert());
    return event.copyWith(id: id);
  }

  Future<List<Event>> getEvents() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('events');

    return maps.map((map) => Event.fromMap(map)).toList();
  }

  Future<void> updateEvent(Event event) async {
    assert(event.id != null, 'Event must have an id to be updated');
    final db = await instance.database;
    await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
    //var result = await db.update('events', event.toMap(), where: 'id = ?', whereArgs: [event.id]);
    //print("Update result: $result");
  }

  // Method to delete specific event from database
  Future<void> deleteEvent(int id) async {
    final db = await instance.database;
    await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
    
  }

  // Method to delete all events from database
  Future<void> deleteAllEvents() async {
    final db = await database;
    await db.delete('events');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<List<Event>> getEventsForDate(DateTime date) async {
    final db = await instance.database;
    // Format the date as a string in yyyy-MM-dd format to match partial date strings in the database
    String dateString = DateFormat('yyyy-MM-dd').format(date);

    // Query the database for events on this date
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where:
          '"from" LIKE ? OR "to" LIKE ?', // Use LIKE operator for partial matching
      whereArgs: [
        '%$dateString%',
        '%$dateString%'
      ], // Match date in 'from' and 'to'
    );

    // Convert the List<Map<String, dynamic>> into a List<Event>
    return List.generate(maps.length, (i) {
      return Event(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        from: DateTime.parse(maps[i]['from']),
        to: DateTime.parse(maps[i]['to']),
        backgroundColor: Color(int.parse(maps[i]['backgroundColor'])),
        effortLevel: maps[i]['effortLevel'],
        isAllDay: maps[i]['isAllDay'] == 1,
        tags: maps[i]['tags'].split(',').where((tag) => tag.isNotEmpty).toList(),
      );
    });
  }


  /*---------------------------------------------------------------------------------------------------------------------------------------------------
  METHODS FOR STORING USER-SETTINGS
  ---------------------------------------------------------------------------------------------------------------------------------------------------*/
  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final maps = await db.query('settings',
        where: 'key = ?', whereArgs: [key], limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  Future<void> updateSetting(String key, String value) async {
    final db = await instance.database;
    await db.update('settings', {'value': value},
        where: 'key = ?', whereArgs: [key]);
  }

/*---------------------------------------------------------------------------------------------------------------------------------------------------
  METHODS FOR STORING TAGS
  ---------------------------------------------------------------------------------------------------------------------------------------------------*/
  // Method for storing the user created tags to enable quick selection
  Future<void> saveTags(List<Tag> tags) async {
      final db = await instance.database;
      // Convert the List<Tag> to a JSON string
      String tagsJson = jsonEncode(tags.map((tag) => {'text': tag.text, 'color': tag.color.value.toString()}).toList());
      await db.insert('settings', {'key': 'tags', 'value': tagsJson},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

  Future<void> insertTag(String text, Color color) async {
    final db = await database;
    // Attempt to insert the tag, ignoring if it already exists
    final id = await db.insert('tags', {
      'text': text,
      'color': color.value,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    //print("Inserted tag with id: $id");
  }

  Future<void> linkEventAndTags(int eventId, List<Tag> tags) async {
    final db = await database;
    for (final tag in tags) {
      final tagQueryResult = await db.query('tags', where: 'text = ?', whereArgs: [tag.text]);
      final tagRow = tagQueryResult.firstOrNull; // Use firstOrNull

      int tagId;
      if (tagRow != null) {
        // Tag exists, get its ID
        tagId = tagRow['id'] as int;
      } else {
        // Insert new tag and get its ID
        tagId = await db.insert('tags', {'text': tag.text, 'color': tag.color.value});
      }

      // Link the event and tag
      await db.insert('event_tags', {'event_id': eventId, 'tag_id': tagId}, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

    Future<List<Tag>> getTagsForEvent(int eventId) async {
      final db = await database;
      final List<Map<String, dynamic>> tagLinks = await db.query(
        'event_tags',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );

      List<Tag> tags = [];
      for (final link in tagLinks) {
        final tagData = (await db.query('tags', where: 'id = ?', whereArgs: [link['tag_id']])).first;
        // Explicit casting
        String text = tagData['text'] as String;
        int colorValue = tagData['color'] as int;
        tags.add(Tag(text: text, color: Color(colorValue)));
        //print('Loaded tag for event $eventId: $text with color $colorValue');
      }
    return tags;
  }

  
  // Method for storing the user created tags to enable quick selection
  Future<List<Tag>> loadTags() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tags');

    return List.generate(maps.length, (i) {
      return Tag(
        id: maps[i]['id'],
        text: maps[i]['text'],
        color: Color(maps[i]['color'] as int),
      );
    });
  }

  // Method to update tag
  Future<void> updateTag(Tag tag) async {
    final db = await database;
    
    int result = await db.update(
      'tags',
      {
        'text': tag.text,
        'color': tag.color.value,
      },
      where: 'id = ?',
      whereArgs: [tag.id],
    );
    
    //print('Updated tag with id ${tag.id}: $result');

    
  }

  // Method to remove a tag's association with a given event
  Future<void> removeTagAssociation(int eventId, int tagId) async {
    final db = await database;

    await db.delete(
      'event_tags',
      where: 'event_id = ? AND tag_id = ?',
      whereArgs: [eventId, tagId],
    );
  }

  // Method to delete tag completely from the database
  Future<void> deleteTag(int tagId) async {
    final db = await database;
    
    // First, delete the tag's associations with any events
    await db.delete(
      'event_tags',
      where: 'tag_id = ?',
      whereArgs: [tagId],
    );
    
    // Then, delete the tag itself from the 'tags' table
    int result = await db.delete(
      'tags',
      where: 'id = ?',
      whereArgs: [tagId],
    );
    
    //print('Deleted tag with id $tagId: $result');
  }

  // method to update tag color
  Future<void> updateTagColor(int tagId, Color color) async {
    final db = await database;
    await db.update(
      'tags',
      {'color': color.value},
      where: 'id = ?',
      whereArgs: [tagId],
    );
  }

}