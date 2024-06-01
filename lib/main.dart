import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weekly_planner_sf_main/database/database_helper.dart';
import 'package:weekly_planner_sf_main/dev_and_debug/debug_tools_page.dart';
import 'package:weekly_planner_sf_main/pages/event_editing_page.dart';
import 'package:weekly_planner_sf_main/pages/settings_page.dart';
import 'package:weekly_planner_sf_main/pages/statistics_page.dart';
import 'package:weekly_planner_sf_main/provider/event_provider.dart';
import 'package:weekly_planner_sf_main/provider/settings_provider.dart';
import 'package:weekly_planner_sf_main/provider/tag_provider.dart';
import 'package:weekly_planner_sf_main/utils/setting_constants.dart';
import 'package:weekly_planner_sf_main/widgets/calendar_widget.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => EventProvider(DatabaseHelper.instance)),
        ChangeNotifierProvider(
            create: (context) => SettingsProvider(DatabaseHelper.instance)),
        ChangeNotifierProvider(
            create: (context) => TagProvider(DatabaseHelper.instance)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static const String title = 'Weekly Planner';

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: title,
          themeMode:
              settingsProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            hintColor: Colors.white,
            primaryColor: Colors.red,
          ),
          theme: ThemeData.light(), // Define your light theme as well
          home: MainPage(),
        );
      },
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(MyApp.title),
          centerTitle: true,
          toolbarHeight: appBarHeight,
          actions: [
            // dev_button to go to debug_tools_page
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DebugToolsPage()));
              },
              child: const Text('Open Debug Tools'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              },
              child: const Text('Settings'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => StatisticsPage()),
                );
              },
              child: const Text('Statistics'),
            ),
          ],
        ),
        body: CalendarWidget(),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.red,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const EventEditingPage()),
          ),
        ),
      );
}
