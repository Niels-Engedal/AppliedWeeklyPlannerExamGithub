// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:weekly_planner_sf_main/model/event_data_source.dart';
import 'package:weekly_planner_sf_main/pages/event_viewing_page.dart';
import 'package:weekly_planner_sf_main/provider/event_provider.dart';
import 'package:weekly_planner_sf_main/utils/setting_constants.dart';
import 'package:weekly_planner_sf_main/utils/utils.dart';

class TasksWidget extends StatefulWidget {
  @override
  _TasksWidgetState createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final selectedEvents = provider.eventsOfSelectedDate; // get all the events from the selected date from the provider
    Map<String, Color> effortLevelColors = SettingsUtil.getEffortLevelColors(context);

    if (selectedEvents.isEmpty){
      return const Center(
        child: Text(
          "No Events For This Day Found!",
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
      );
    }
    return SfCalendar(
        view: CalendarView.timelineDay,
        dataSource: EventDataSource(provider.events, effortLevelColors),
        initialDisplayDate: provider.selectedDate,
        appointmentBuilder: appointmentBuilder,

        // if we click on the event then we want to see it's details:
        onTap: (details) {
          if (details.appointments == null) return;
          final event = details.appointments!.first;

          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EventViewingPage(event: event),
          ));
        }, // should call description etc I think
        selectionDecoration: BoxDecoration( // what color it should have when I clicked on an event
          color: Colors.red.withOpacity(0.3),
          ),
      );
  }
  
  Widget appointmentBuilder(
  BuildContext context,
  CalendarAppointmentDetails details,
  ){
    final event = details.appointments.first;
    return Container(
      width: details.bounds.width,
      height: details.bounds.height,
      decoration: BoxDecoration(color: effortLevelColorMap[event.effortLevel],
      borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Text(
          event.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          )
        
        ),
      )
    );
  }
}