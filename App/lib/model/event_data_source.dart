import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:weekly_planner_sf_main/model/event.dart';
import 'package:weekly_planner_sf_main/provider/settings_provider.dart';
import 'package:weekly_planner_sf_main/utils/setting_constants.dart';

// This is basically a "wrapper" around our list of events, which basically explains our SF_calendar how to work with our events.
class EventDataSource extends CalendarDataSource {
  final Map<String, Color> effortLevelColors;

  EventDataSource(List<Event> appointments, this.effortLevelColors){
    this.appointments = appointments; /* appointments are a part of SF calendar's package and they have the type "dynamic",
     we therefore need to convert between our type "Event" and this "dynamic" type. That's why we set up some methods below.*/
  }

  // Method to get the event back as an "Event"-type, when it is stored as an appointment "dynamic"-type
  Event getEvent(int index) => appointments![index] as Event; // provide the index in the appointment list of the event you want, then we retrieve it as an "Event"-type

  /* ----------------------------------------------------------------------------------------------------------------------------------
  Overriding the default way of interacting with CalendarDataSource using @override and our "getEvent"-method defined above
  See https://help.syncfusion.com/flutter/calendar/appointments for all the "methods", we need to change
  ----------------------------------------------------------------------------------------------------------------------------------*/

  // Method to get StartTime as our "from" defined in our "event.dart"-model
  @override
  DateTime getStartTime(int index) => getEvent(index).from; // notice how we use the ".from"

  // Method to get EndTime....
  @override
  DateTime getEndTime(int index) => getEvent(index).to;

  // Method to get Title
  @override
  String getSubject(int index) => getEvent(index).title;

  // Method to get description
  @override
  String getNotes(int index) => getEvent(index).description;

  // Method to get Color
  @override
  Color getColor(int index) {
    final Event event = getEvent(index);
    // Use the passed-in effort level colors instead of fetching from SettingsProvider
    return effortLevelColors[event.effortLevel] ?? event.backgroundColor;
  }

}