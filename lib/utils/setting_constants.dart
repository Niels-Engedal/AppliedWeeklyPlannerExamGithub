import 'package:flutter/material.dart';
import 'package:weekly_planner_sf_main/utils/app_colors.dart';


// Effort Levels
List<String> effortLevelsList = ["Recharge", "Low", "Medium", "High"];
Map<String, Color?> effortLevelColorMap = {
  'Recharge': appColorsRechargeEffortColor,
  'Low': appColorsLowEffortColor,
  'Medium': appColorsMediumEffortColor,
  'High': appColorsHighEffortColor,
};

// Time settings
const double settings_startHour = 0;
const double settings_endHour = 24;
const int settings_interval_duration = 30;


// UI elements

  // APPBAR
  const double appBarHeight = 20.0;

  // SF calendar
  const String settings_TimeFormat = 'HH:mm';
  const Duration settings_TimeInterval = Duration(minutes: settings_interval_duration);
  const int settings_firstDayOfWeek = 1; // 0 is Sunday, so 1 = Monday

