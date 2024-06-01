import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:weekly_planner_sf_main/model/tag.dart';
import 'package:weekly_planner_sf_main/provider/event_provider.dart';
import 'package:weekly_planner_sf_main/provider/settings_provider.dart';
import 'package:weekly_planner_sf_main/provider/tag_provider.dart';
import 'package:weekly_planner_sf_main/utils/app_colors.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color rechargeEffortColor = appColorsRechargeEffortColor;
  Color lowEffortColor = appColorsLowEffortColor;
  Color mediumEffortColor = appColorsMediumEffortColor;
  Color highEffortColor = appColorsHighEffortColor;
  TextEditingController _startHourController = TextEditingController();
  TextEditingController _endHourController = TextEditingController();

  void changeColor(Color color, String whichColor) {
    setState(() {
      switch (whichColor) {
        case 'recharge':
          rechargeEffortColor = color;
          break;
        case 'low':
          lowEffortColor = color;
          break;
        case 'medium':
          mediumEffortColor = color;
          break;
        case 'high':
          highEffortColor = color;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tagProvider = Provider.of<TagProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
        return ListView(
          children: <Widget>[
            SwitchListTile(
              title: Text('Dark Theme'),
              value: settingsProvider.isDarkTheme,
              onChanged: (bool value) {
                // Update the settingsProvider's state
                settingsProvider.setDarkTheme(value);
              },
            ),
            ListTile(
              title: Text('Recharge Effort Color'),
              trailing: Icon(Icons.circle,
                  color: settingsProvider.rechargeEffortColor),
              onTap: () {
                pickColor(context, settingsProvider.rechargeEffortColor,
                    (color) {
                  settingsProvider.saveColorSetting(
                      'rechargeEffortColor', color);
                });
              },
            ),
            ListTile(
              title: Text('Low Effort Color'),
              trailing:
                  Icon(Icons.circle, color: settingsProvider.lowEffortColor),
              onTap: () {
                pickColor(context, settingsProvider.lowEffortColor, (color) {
                  settingsProvider.saveColorSetting('lowEffortColor', color);
                });
              },
            ),
            ListTile(
              title: Text('Medium Effort Color'),
              trailing:
                  Icon(Icons.circle, color: settingsProvider.mediumEffortColor),
              onTap: () {
                pickColor(context, settingsProvider.mediumEffortColor, (color) {
                  settingsProvider.saveColorSetting('mediumEffortColor', color);
                });
              },
            ),
            ListTile(
              title: Text('High Effort Color'),
              trailing:
                  Icon(Icons.circle, color: settingsProvider.highEffortColor),
              onTap: () {
                pickColor(context, settingsProvider.highEffortColor, (color) {
                  settingsProvider.saveColorSetting('highEffortColor', color);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _startHourController,
                decoration: InputDecoration(
                  labelText: 'Start Hour',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _endHourController,
                decoration: InputDecoration(
                  labelText: 'End Hour',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Manage Tags'),
              trailing: Icon(Icons.edit),
              onTap: () => _showEditTagsDialog(context),
            ),
            ...tagProvider.tags.map((tag) => ListTile(
                  title: Text(tag.text,
                      style: const TextStyle(color: Colors.black)),
                  trailing: Icon(Icons.circle, color: tag.color),
                  onTap: () => _pickColor(context, tag),
                )),
            ListTile(
              title: Text('Planning and Evaluation Day'),
              trailing: DropdownButton<int>(
                value: settingsProvider.planningEvaluationDay,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    settingsProvider.setPlanningEvaluationDay(newValue);
                  }
                },
                items: List.generate(
                    7,
                    (index) => DropdownMenuItem<int>(
                          value: index +
                              1, // Assuming 1 = Monday, 2 = Tuesday, etc.
                          child: Text([
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday',
                            'Sunday'
                          ][index]),
                        )),
              ),
            ),
          ],
        );
      }),
    );
  }

  void pickColor(BuildContext context, Color initialColor,
      Function(Color) onColorSelected) {
    // Temporary variable to keep track of the selected color.
    Color currentColor = initialColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor, // Use the temporary variable
              onColorChanged: (Color color) {
                // Update the temporary variable instead of the state directly.
                currentColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                // Execute the callback with the selected color.
                onColorSelected(currentColor);
                Navigator.of(context).pop(); // Close the dialog.
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditTagsDialog(BuildContext context) async {
    final tagProvider = Provider.of<TagProvider>(context, listen: false);
    final tags = tagProvider
        .tags; // Assuming you have a getter in your TagProvider for all tags

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Tags'),
          content: SingleChildScrollView(
            child: Column(
              children: tags.map((tag) {
                return ListTile(
                  title: Text(tag.text),
                  trailing: Icon(Icons.circle, color: tag.color),
                  onTap: () => _pickColor(context, tag),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _pickColor(BuildContext parentContext, Tag tag) {
    Color currentColor = tag.color; // Start with the tag's current color

    showDialog(
      context:
          parentContext, // This is the context of the page/widget that opens the dialog
      builder: (BuildContext dialogContext) {
        // 'dialogContext' is the context specific to the dialog
        return AlertDialog(
          title: Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                currentColor =
                    color; // Update the temporary variable with the new color
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Done'),
              onPressed: () {
                // Use dialogContext to specifically close the dialog
                Navigator.pop(dialogContext); // This closes the dialog only

                // Update the tag's color in the provider or wherever necessary
                final tagProvider =
                    Provider.of<TagProvider>(parentContext, listen: false);
                tagProvider.updateTagColor(tag.id!, currentColor);
                final eventProvider =
                    Provider.of<EventProvider>(context, listen: false);
                eventProvider.loadEvents();
              },
            ),
          ],
        );
      },
    );
  }
}
