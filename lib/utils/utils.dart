import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weekly_planner_sf_main/provider/settings_provider.dart';

class Utils {
  static String toDateTime(DateTime dateTime) {
    final date = DateFormat.yMMMEd().format(dateTime);
    final time = DateFormat.Hm().format(dateTime);

    return '$date $time';
  }

  static String toDate(DateTime dateTime) {
    final date = DateFormat.yMMMEd().format(dateTime);

    return '$date';
  }

  static String toTime(DateTime dateTime) {
    final time = DateFormat.Hm().format(dateTime);

    return '$time';
  }

  // Method to check if two dates are the same
  static bool isSameDay(DateTime date1, DateTime date2) {
    String formattedDate1 = DateFormat('yyyy-MM-dd').format(date1);
    String formattedDate2 = DateFormat('yyyy-MM-dd').format(date2);
    return formattedDate1 == formattedDate2;
  }

  // Add methods to update other settings similarly
  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }
}

class SettingsUtil {
  static Map<String, Color> getEffortLevelColors(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    return {
      'Recharge': settingsProvider.rechargeEffortColor,
      'Low': settingsProvider.lowEffortColor,
      'Medium': settingsProvider.mediumEffortColor,
      'High': settingsProvider.highEffortColor,
    };
  }
}