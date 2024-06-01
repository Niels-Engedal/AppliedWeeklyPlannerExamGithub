import 'package:flutter/material.dart';


  // Effortlevel colors
  final Color appColorsRechargeEffortColor = Color(0xFF69D6EB); 
  final Color appColorsLowEffortColor = Color(0xFF92F0B0);
  final Color appColorsMediumEffortColor = Color(0xFFE0DF8B);
  final Color appColorsHighEffortColor = Color(0xFFE0B48F);



// not currently used I don't think
class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      onPrimary: Colors.white,
      secondary: Colors.amber,
      onSecondary: Colors.black,
      tertiary: Colors.green,
      onTertiary: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      error: Colors.red,
    )
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
  );
}