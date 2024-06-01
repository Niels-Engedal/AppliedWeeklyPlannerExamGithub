import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weekly_planner_sf_main/model/event.dart';
import 'package:weekly_planner_sf_main/pages/event_editing_page.dart';
import 'package:weekly_planner_sf_main/provider/event_provider.dart';
import 'package:weekly_planner_sf_main/utils/utils.dart';

class EventViewingPage extends StatelessWidget {
  final Event event;

  const EventViewingPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: const CloseButton(),
          title: Text(
            event.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: buildViewingActions(context, event),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildViewDetails(context),
              buildTagChips(context), // Add this line
            ],
          ),
        ),
      );

  List<Widget> buildViewingActions(BuildContext context, Event event) {
    return [
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventEditingPage(event: event),
          ),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          final provider = Provider.of<EventProvider>(context, listen: false);
          if (event.id != null) {
            provider.deleteEvent(event.id!);
            Navigator.of(context).pop();
          } else {
            print("Error: Event ID is null");
          }
        },
      ),
    ];
  }

  Widget buildViewDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Event Begins", style: Theme.of(context).textTheme.headlineMedium),
          Text(Utils.toDateTime(event.from)),
          const SizedBox(height: 20),
          Text("Event Ends", style: Theme.of(context).textTheme.headlineMedium),
          Text(Utils.toDateTime(event.to)),
          const SizedBox(height: 20),
          Text("Effort Level", style: Theme.of(context).textTheme.headlineMedium),
          Text(event.effortLevel),
          const SizedBox(height: 20),
          Text("Description", style: Theme.of(context).textTheme.headlineMedium),
          Text(event.description),
          const SizedBox(height: 20),
          Text("Tags", style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }

  // Complete the buildTagChips method to generate chips for each tag
  Widget buildTagChips(BuildContext context) {
    final tags = event.tags;

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags.map((tag) => Chip(
        label: Text(tag.text),
        backgroundColor: tag.color,
      )).toList(),
    );
  }
}





