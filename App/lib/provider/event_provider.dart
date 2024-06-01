// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weekly_planner_sf_main/database/database_helper.dart';
import 'package:weekly_planner_sf_main/dev_and_debug/example_schedule_events.dart';
import 'package:weekly_planner_sf_main/model/event.dart';
import 'package:weekly_planner_sf_main/model/tag.dart';
import 'package:weekly_planner_sf_main/utils/utils.dart';

class EventProvider extends ChangeNotifier{
  final List<Event> _events = [];
  final DatabaseHelper _dbHelper;

  EventProvider(this._dbHelper){
    loadEvents();
  }

  List<Event> get events => _events;

  // to achieve constant knowledge of where we have clicked in the grid we use the following
  DateTime _selectedDate = DateTime.now();

  // Method to get the selected date
  DateTime get selectedDate => _selectedDate;

  // Method to set the selected date
  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
    loadEventsForSelectedDate();
  }

  // Method to load all events
  Future<void> loadEvents() async {
    final List<Event> loadedEvents = await _dbHelper.getEvents();
    final List<Event> updatedEvents = [];

    for (Event event in loadedEvents) {
      List<Tag> tags = await _dbHelper.getTagsForEvent(event.id!);
      // Create a new updated event with the tags
      final updatedEvent = event.copyWith(tags: tags);
      //print("loadEvents() after copyWith: $updatedEvent");
      updatedEvents.add(updatedEvent); // Add the updated event to a new list
    }

    _events.clear();
    _events.addAll(updatedEvents); // Use the updated list
    //print("Event Provider loadEvents updated events: ${_events}");
    notifyListeners();
  }

  // Method to load events for selected date
  Future<void> loadEventsForSelectedDate() async {
    final List<Event> loadedEvents = await _dbHelper.getEventsForDate(_selectedDate);
    _events.clear();
    _events.addAll(loadedEvents);
    notifyListeners();
  }

  // Method / Getter to retrieve events for the selected date synchronously
  List<Event> get eventsOfSelectedDate {
    return _events.where((event) => Utils.isSameDay(event.from, _selectedDate)).toList();
  }

  // Method for getting all Tags
  Future<List<Tag>> getAllTags() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> tagRecords = await db.query('tags');

    return tagRecords.map((record) => Tag.fromMap(record)).toList();
  }

  // Method to add event
  Future<void> addEvent(Event event) async {
    // Insert the event and get its new ID
    final Event createdEvent = await _dbHelper.insertEvent(event);
    
    // Insert tags and link them to the event
    await _dbHelper.linkEventAndTags(createdEvent.id!, event.tags);

    _events.add(createdEvent);
    notifyListeners();
    loadEvents(); // Reload events to ensure the list is up-to-date
  }

  // Method to update the events list with the edited event
  Future<void> editEvent(Event newEvent, Event oldEvent) async {
    // Update the event in the database
    if (newEvent.id != null){
      await _dbHelper.updateEvent(newEvent);
      
      // Find the index of the old event in the _events list
      int index = _events.indexWhere((event) => event.id == oldEvent.id);
      if (index != -1) {
        // Replace the old event with the new one in the _events list
        _events[index] = newEvent;
        
        // Notify listeners about the update
        notifyListeners();
      } else {
        // If for some reason the event isn't found in the list (which shouldn't normally happen),
        // reload all events from the database to ensure synchronization
        await loadEvents();
      }
    } else {
      print("Error: Attempted to update an event without an id");
    }
    notifyListeners();
  }


  // Method to update Event with new tags
  Future<void> updateEventWithTags(Event event, List<Tag> updatedTags) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Update event details
      await txn.update(
        'events',
        event.toMapForInsert(),
        where: 'id = ?',
        whereArgs: [event.id],
      );

      // Remove old tag associations
      await txn.delete(
        'event_tags',
        where: 'event_id = ?',
        whereArgs: [event.id],
      );

      // Update tags and associations
      for (Tag tag in updatedTags) {
        var existingTag = await txn.query(
          'tags',
          where: 'text = ?',
          whereArgs: [tag.text],
        );

        int tagId;
        if (existingTag.isEmpty) {
          tagId = await txn.insert('tags', {'text': tag.text, 'color': tag.color.value});
        } else {
          tagId = existingTag.first['id'] as int; // Explicitly cast to int
        }

        await txn.insert('event_tags', {
          'event_id': event.id,
          'tag_id': tagId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
    loadEvents();
    notifyListeners();
  }


  // Method to delete specific event
  Future<void> deleteEvent(int eventId) async {
    //print("Provider: Deleting Event id: $eventId");
    final db = await _dbHelper.database;
    // Delete event
    await db.delete('events', where: 'id = ?', whereArgs: [eventId]);
    await db.delete('event_tags', where: 'event_id = ?', whereArgs: [eventId]);
    loadEvents();
    notifyListeners();
  } 

  // Method to delete all events
  Future<void> deleteAllEvents() async {
    await _dbHelper.deleteAllEvents();
    _events.clear();
    notifyListeners();
  }

  // Method to call the database to remove the association between a tag and an event
  Future<void> removeTagFromEvent(int eventId, int tagId) async {
    await _dbHelper.removeTagAssociation(eventId, tagId);
    notifyListeners();
  }

  // Get tags for a specific event
  Future<List<Tag>> fetchTagsForEvent(int eventId) async {
    return await _dbHelper.getTagsForEvent(eventId);
    // This could also update some local state if necessary
  }

  // Method used for statistics page to get events int the range of our weekly planning and evaluation days
  List<Event> getEventsInRange(DateTime start, DateTime end) {
    return _events.where((event) {
      return event.from.isAfter(start.subtract(Duration(days: 1))) && event.to.isBefore(end.add(Duration(days: 1)));
    }).toList();
  }

  // Method to add sample events for easier presentation and debugging
  Future<void> addSampleEvents() async {
    final sampleEvents = getSampleEvents();
    for (Event event in sampleEvents) {
      _dbHelper.insertEvent(event); 
    }
    await loadEvents();
  }


}


