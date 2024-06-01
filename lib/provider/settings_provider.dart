import 'package:flutter/material.dart';
import 'package:weekly_planner_sf_main/database/database_helper.dart';
import 'package:weekly_planner_sf_main/utils/app_colors.dart';


class SettingsProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper;
  late bool _isDarkTheme = true;
  late Color _rechargeEffortColor,
      _lowEffortColor,
      _mediumEffortColor,
      _highEffortColor;
  late int _startHour, _endHour;
  int _planningEvaluationDay = DateTime.monday; // Default to Monday
  int get planningEvaluationDay => _planningEvaluationDay;

  SettingsProvider(this._dbHelper) {
    loadSettings();
    initDefaultEffortLevelColors();
  }

  // Initialize default effort level colors
  void initDefaultEffortLevelColors() {
    _rechargeEffortColor = appColorsRechargeEffortColor;
    _lowEffortColor = appColorsLowEffortColor;
    _mediumEffortColor = appColorsMediumEffortColor;
    _highEffortColor = appColorsHighEffortColor;
    // Notify listeners about the changes
    notifyListeners();
  }

  // Getters
  bool get isDarkTheme => _isDarkTheme;
  Color get rechargeEffortColor => _rechargeEffortColor;
  Color get lowEffortColor => _lowEffortColor;
  Color get mediumEffortColor => _mediumEffortColor;
  Color get highEffortColor => _highEffortColor;

  // Getter for all the effortLevelColors as a Map
  Map<String, Color> get effortLevelColors => {
    'Recharge': _rechargeEffortColor,
    'Low': _lowEffortColor,
    'Medium': _mediumEffortColor,
    'High': _highEffortColor,
  };


  // Method to load settings from database
  Future<void> loadSettings() async {
    // Loading the dark theme setting
    String? darkThemeValue = await _dbHelper.getSetting('isDarkTheme');
    _isDarkTheme = darkThemeValue == 'true';

    // Loading colors
    String? rechargeEffortColorHex =
        await _dbHelper.getSetting('rechargeEffortColor');
    _rechargeEffortColor = rechargeEffortColorHex != null
        ? _colorFromHex(rechargeEffortColorHex)
        : appColorsRechargeEffortColor; // Default to color set in appcolors

    String? lowEffortColorHex = await _dbHelper.getSetting('lowEffortColor');
    _lowEffortColor = lowEffortColorHex != null
        ? _colorFromHex(lowEffortColorHex)
        : appColorsLowEffortColor; // Default to color set in appcolors

    String? mediumEffortColorHex =
        await _dbHelper.getSetting('mediumEffortColor');
    _mediumEffortColor = mediumEffortColorHex != null
        ? _colorFromHex(mediumEffortColorHex)
        : appColorsMediumEffortColor; // Default to color set in appcolors

    String? highEffortColorHex = await _dbHelper.getSetting('highEffortColor');
    _highEffortColor = highEffortColorHex != null
        ? _colorFromHex(highEffortColorHex)
        : appColorsHighEffortColor; // Default to color set in appcolors

    String? planningDayString = await _dbHelper.getSetting('planningEvaluationDay');
    _planningEvaluationDay = int.parse(planningDayString ?? '1'); // Default to Monday if not set

    // Don't forget to notify listeners about the changes so that any listening widgets can rebuild themselves
    notifyListeners();
  }

// Helper method to convert a hex string to a Color object
  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  // Method to save individual setting
  Future<void> setDarkTheme(bool value) async {
    _isDarkTheme = value;
    await _dbHelper.saveSetting('isDarkTheme', value.toString());
    notifyListeners();
  }

  // Method to actually save the color to the database
  Future<void> saveColorSetting(String key, Color color) async {
    // Convert color to hex string
    String colorValue = _colorToHex(color);
    await _dbHelper.saveSetting(key, colorValue);
    loadSettings();
    notifyListeners();
  }

  // Method to convert color to hexdecimal string, so we can store it in database
  String _colorToHex(Color color) {
    return color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
  }

// Assuming you have a similar method for saving the dark theme setting
  Future<void> saveThemeSetting(bool isDarkTheme) async {
    await _dbHelper.saveSetting('isDarkTheme', isDarkTheme ? 'true' : 'false');
    loadSettings();
    notifyListeners();
  }

  // Method to set planning and evaluation day
  void setPlanningEvaluationDay(int day) async {
    _planningEvaluationDay = day;
    await _dbHelper.saveSetting('planningEvaluationDay', day.toString());
    notifyListeners();
  }
  

}
