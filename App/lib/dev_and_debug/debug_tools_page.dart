import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weekly_planner_sf_main/provider/event_provider.dart';

class DebugToolsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Tools'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<EventProvider>(context, listen: false);
              await provider.addSampleEvents();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sample events added successfully')),
              );
            },
            child: const Text('Add Sample Events'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<EventProvider>(context, listen: false);
              await provider.deleteAllEvents();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All events deleted successfully')),
              );
            },
            child: const Text('Delete All Events'),
          ),
        ],
      ),
    );
  }
}
