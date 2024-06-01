import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weekly_planner_sf_main/model/event.dart';
import 'package:weekly_planner_sf_main/provider/event_provider.dart';
import 'package:weekly_planner_sf_main/provider/settings_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final now = DateTime.now();
    final startOfWeek = _calculateStartOfWeek(now, settingsProvider.planningEvaluationDay);
    final endOfWeek = startOfWeek.add(Duration(days: 7));
    final weeklyEvents = eventProvider.getEventsInRange(startOfWeek, endOfWeek);
    final effortHours = _calculateHoursByEffortLevel(weeklyEvents, settingsProvider);
    final effortColors = settingsProvider.effortLevelColors;

    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Statistics'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Week of ${DateFormat('MMMM dd').format(startOfWeek)} to ${DateFormat('MMMM dd').format(endOfWeek)}', style: const TextStyle(fontSize: 24),),
            SizedBox(height: 80,),
            _buildEffortLevelChart(effortHours, effortColors),
            SizedBox(height: 20),
            _buildEffortAndTagStats(weeklyEvents, effortHours, settingsProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildEffortAndTagStats(List<Event> events, Map<String, double> effortHours, SettingsProvider settingsProvider) {
    // Build tiles for effort level stats
    var effortLevelTiles = effortHours.entries.map((entry) => ListTile(
      title: Text('${entry.key} Effort Hours'),
      subtitle: Text('${entry.value.toStringAsFixed(2)} hours'),
      tileColor: settingsProvider.effortLevelColors[entry.key]?.withOpacity(0.2),
    )).toList();

    // Calculate and build tiles for tag stats
    var tagHours = _calculateHoursByTag(events);
    var tagTiles = tagHours.entries.map((entry) => ListTile(
      title: Text('Tag: ${entry.key}'),
      subtitle: Text('${entry.value.toStringAsFixed(2)} hours'),
      tileColor: _findTagColor(entry.key, events).withOpacity(0.2),
    )).toList();

    return Column(
      children: [
        ExpansionTile(
          title: Text('Effort Level Statistics'),
          children: effortLevelTiles,
        ),
        ExpansionTile(
          title: Text('Tag Statistics'),
          children: tagTiles,
        ),
      ],
    );
  }

  Widget _buildEffortLevelChart(Map<String, double> effortHours, Map<String, Color> effortColors) {
    List<BarChartGroupData> barGroups = [];
    int i = 0;
    effortHours.forEach((key, value) {
      final barGroup = BarChartGroupData(
        x: i++,
        barRods: [
          BarChartRodData(
            y: value,
            colors: [effortColors[key] ?? Colors.grey],
            width: 16,
          ),
        ],
        showingTooltipIndicators: [0],
      );
      barGroups.add(barGroup);
    });

    return Container(
      height: 200,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
              getTitles: (double value) => effortHours.keys.elementAt(value.toInt()),
              rotateAngle: 45,
              margin: 8,
            ),
            leftTitles: SideTitles(showTitles: false),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  Color _findTagColor(String tagName, List<Event> events) {
    for (var event in events) {
      for (var tag in event.tags) {
        if (tag.text == tagName) return tag.color;
      }
    }
    return Colors.grey;
  }

  // Updated method to include effort levels from SettingsProvider
  Map<String, double> _calculateHoursByEffortLevel(List<Event> events, SettingsProvider settingsProvider) {
    Map<String, double> hoursByEffort = Map.fromIterable(
      settingsProvider.effortLevelColors.keys,
      key: (e) => e as String,
      value: (e) => 0.0,
    );

    for (var event in events) {
      final duration = event.to.difference(event.from).inHours.toDouble();
      if (hoursByEffort.containsKey(event.effortLevel)) {
        hoursByEffort[event.effortLevel] = (hoursByEffort[event.effortLevel] ?? 0) + duration;
      }
    }

    return hoursByEffort;
  }


  Map<String, double> _calculateHoursByTag(List<Event> events) {
    Map<String, double> hoursByTag = {};
    events.forEach((event) {
      event.tags.forEach((tag) {
        final hours = event.to.difference(event.from).inHours.toDouble();
        hoursByTag.update(tag.text, (value) => value + hours,
            ifAbsent: () => hours);
      });
    });
    return hoursByTag;
  }

  Map<String, double> getEffortLevelData(
      List<Event> events, SettingsProvider settingsProvider) {
    // Initialize the data map with effort levels set to 0 hours
    Map<String, double> data = {
      'Recharge': 0.0,
      'Low': 0.0,
      'Medium': 0.0,
      'High': 0.0,
    };

    for (Event event in events) {
      // Calculate duration in hours
      double duration = event.to.difference(event.from).inHours.toDouble();

      // Accumulate hours based on effort level
      if (data.containsKey(event.effortLevel)) {
        data[event.effortLevel] = (data[event.effortLevel] ?? 0.0) + duration;
      }
    }

    return data;
  }

  DateTime _calculateStartOfWeek(DateTime currentDate, int planningDay) {
    int currentWeekday = currentDate.weekday;

    // Find the most recent planning day. If today is the planning day, start from today.
    int daysToSubtract = (currentWeekday - planningDay + 7) % 7;
    DateTime startOfWeek = currentDate.subtract(Duration(days: daysToSubtract));

    // Adjust to the start of the day (midnight) for consistency
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return startOfWeek;
  }

}
