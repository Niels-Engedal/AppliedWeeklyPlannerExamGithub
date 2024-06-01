import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:weekly_planner_sf_main/database/database_helper.dart';
import 'package:weekly_planner_sf_main/model/tag.dart';

class TagProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper;
  List<Tag> _tags = [];

  TagProvider(this._dbHelper) {
    loadTagsFromDatabase();
  }

  List<Tag> get tags => _tags;

  // Load tags from the database
  Future<void> loadTagsFromDatabase() async {
    _tags = await _dbHelper.loadTags();
    notifyListeners();
  }

  // Save a single tag to the database
  Future<void> addTag(String text, Color color) async {
    await _dbHelper.insertTag(text, color);
    // Reload tags to update the list after adding a new tag
    await loadTagsFromDatabase();
    notifyListeners();
  }

  // Link tags with an event
  Future<void> linkTagsToEvent(int eventId, List<Tag> tags) async {
    await _dbHelper.linkEventAndTags(eventId, tags);
    // You might want to reload tags or perform other updates here
    notifyListeners();
  }

  // Get tags for a specific event
  Future<List<Tag>> fetchTagsForEvent(int eventId) async {
    return await _dbHelper.getTagsForEvent(eventId);
    // This could also update some local state if necessary
  }

  // Update a tag in the database
  // This method assumes you have a corresponding updateTag method in DatabaseHelper
  Future<void> updateTag(Tag tagToUpdate) async {
    // Your DatabaseHelper will need an update method for tags
    await _dbHelper.updateTag(tagToUpdate);
    // Reload or update the local tags list as needed
    await loadTagsFromDatabase();
    notifyListeners();
  }

  // Delete a tag from the database
  Future<void> deleteTag(int tagId) async {
    // Your DatabaseHelper will need a delete method for tags
    await _dbHelper.deleteTag(tagId);
    // Reload or update the local tags list as needed
    await loadTagsFromDatabase();
    notifyListeners();
  }


  // Method to update only TagColor
  Future<void> updateTagColor(int tagId, Color newColor) async {
    await _dbHelper.updateTagColor(tagId, newColor);
    // After updating the tag's color, refresh the tags list
    await loadTagsFromDatabase();
    notifyListeners();
  }

  // Method to save tag color
  Future<void> saveColorSetting(String key, Color color) async {
    // Convert color to hex string
    String colorValue = colorToHex(color);
    await _dbHelper.saveSetting(key, colorValue);
    notifyListeners();
  }


}
