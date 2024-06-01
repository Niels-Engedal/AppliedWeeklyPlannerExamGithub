import 'package:flutter/material.dart';
import 'package:weekly_planner_sf_main/model/event.dart';

// Define the reference date
DateTime referenceDate = DateTime(2024, 4, 1);

// Utility function to add days to the reference date
DateTime getDate(String dayCode) {
  Map<String, int> dayCodes = {
    "Mon": 0,
    "Tue": 1,
    "Wed": 2,
    "Thu": 3,
    "Fri": 4,
    "Sat": 5,
    "Sun": 6,
  };
  
  // Calculate the date
  final daysToAdd = dayCodes[dayCode] ?? 0;
  return referenceDate.add(Duration(days: daysToAdd));
}

List<Event> getSampleEvents() {
  return [
    Event(
      title: 'Team Meeting',
      description: 'Weekly team meeting on Google Meet.',
      from: getDate("Mon").add(const Duration(hours: 9)),
      to: getDate("Mon").add(const Duration(hours: 10)),
      backgroundColor: Colors.blue,
      effortLevel: 'Medium',
      isAllDay: false,
    ),
     Event(
    title: 'Philosophy of Mind Lecture',
    description: 'Lecture on consciousness and the mind-body problem.',
    from: getDate("Mon").add(const Duration(hours: 9)), // Monday, 9:00 AM
    to: getDate("Mon").add(const Duration(hours: 10, minutes: 30)), // Monday, 10:30 AM
    backgroundColor: Colors.blue,
    effortLevel: 'High',
    isAllDay: false,
  ),
    Event(
      title: 'Doctor Appointment',
      description: 'Routine check-up.',
      from: getDate("Wed").add(const Duration(hours: 15)),
      to: getDate("Wed").add(const Duration(hours: 16)),
      backgroundColor: Colors.red,
      effortLevel: 'Low',
      isAllDay: false,
    ),
    Event(
    title: 'Neuroscience Study Group',
    description: 'Study group meeting for the upcoming neuroscience midterm.',
    from: getDate("Tue").add(const Duration(days: 1, hours: 14)), // Tuesday, 2:00 PM
    to: getDate("Tue").add(const Duration(days: 1, hours: 16)), // Tuesday, 4:00 PM
    backgroundColor: Colors.green,
    effortLevel: 'Medium',
    isAllDay: false,
  ),
  Event(
    title: 'AI in Cognitive Science Guest Lecture',
    description: 'Special lecture on the role of artificial intelligence in studying cognition.',
    from: getDate("Wed").add(const Duration(days: 2, hours: 11)), // Wednesday, 11:00 AM
    to: getDate("Wed").add(const Duration(days: 2, hours: 12, minutes: 30)), // Wednesday, 12:30 PM
    backgroundColor: Colors.red,
    effortLevel: 'Medium',
    isAllDay: false,
  ),
  Event(
    title: 'Cognitive Psychology Lab',
    description: 'Lab session on cognitive psychology experiments.',
    from: getDate("Thu").add(const Duration(days: 3, hours: 13)), // Thursday, 1:00 PM
    to: getDate("Thu").add(const Duration(days: 3, hours: 15)), // Thursday, 3:00 PM
    backgroundColor: Colors.purple,
    effortLevel: 'High',
    isAllDay: false,
  ),
  Event(
    title: 'Study Session at the Library',
    description: 'General study session at the university library.',
    from: getDate("Fri").add(const Duration(days: 4, hours: 15)), // Friday, 3:00 PM
    to: getDate("Fri").add(const Duration(days: 4, hours: 18)), // Friday, 6:00 PM
    backgroundColor: Colors.orange,
    effortLevel: 'Low',
    isAllDay: false,
  ),
  Event(
    title: 'Cognitive Science Department Mixer',
    description: 'Networking event with faculty and students from the Cognitive Science department.',
    from: getDate("Sat").add(const Duration(days: 5, hours: 17)), // Saturday, 5:00 PM
    to: getDate("Sat").add(const Duration(days: 5, hours: 20)), // Saturday, 8:00 PM
    backgroundColor: Colors.teal,
    effortLevel: 'Low',
    isAllDay: false,
  ),
  Event(
    title: 'Relaxation and Mindfulness Session',
    description: 'Campus wellness center session on relaxation and mindfulness.',
    from: getDate("Sun").add(const Duration(days: 6, hours: 10)), // Sunday, 10:00 AM
    to: getDate("Sun").add(const Duration(days: 6, hours: 11)), // Sunday, 11:00 AM
    backgroundColor: Colors.lightBlue,
    effortLevel: 'Low',
    isAllDay: false,
  ),
Event(
  title: 'Grocery Shopping',
  description: 'Weekly grocery shopping at the local market.',
  from: getDate("Mon").add(const Duration(hours: 16)),
  to: getDate("Mon").add(const Duration(hours: 17)),
  backgroundColor: Colors.green,
  effortLevel: 'Low',
  isAllDay: false,
),
Event(
  title: 'Study Group Session',
  description: 'Group study session for Cognitive Psychology exam.',
  from: getDate("Tue").add(const Duration(hours: 14)),
  to: getDate("Tue").add(const Duration(hours: 16)),
  backgroundColor: Colors.orange,
  effortLevel: 'Medium',
  isAllDay: false,
),
Event(
  title: 'Cook Dinner with Friends',
  description: 'Cooking a healthy dinner with friends.',
  from: getDate("Tue").add(const Duration(hours: 18)),
  to: getDate("Tue").add(const Duration(hours: 20)),
  backgroundColor: Colors.purple,
  effortLevel: 'Medium',
  isAllDay: false,
),
Event(
  title: 'Cognitive Neuroscience Lecture',
  description: 'Lecture covering the neural mechanisms underlying cognition.',
  from: getDate("Wed").add(const Duration(hours: 10)),
  to: getDate("Wed").add(const Duration(hours: 11, minutes: 30)),
  backgroundColor: Colors.blue,
  effortLevel: 'High',
  isAllDay: false,
),
Event(
  title: 'Laundry',
  description: 'Doing the weekly laundry.',
  from: getDate("Wed").add(const Duration(hours: 17)),
  to: getDate("Wed").add(const Duration(hours: 18, minutes: 30)),
  backgroundColor: Colors.green,
  effortLevel: 'Low',
  isAllDay: false,
),
Event(
  title: 'AI and Machine Learning Seminar',
  description: 'Seminar on the intersection of cognitive science and artificial intelligence.',
  from: getDate("Thu").add(const Duration(hours: 11)),
  to: getDate("Thu").add(const Duration(hours: 12, minutes: 30)),
  backgroundColor: Colors.blue,
  effortLevel: 'High',
  isAllDay: false,
),
Event(
  title: 'Movie Night',
  description: 'Watching a new sci-fi movie with roommates.',
  from: getDate("Fri").add(const Duration(hours: 20)),
  to: getDate("Fri").add(const Duration(hours: 22)),
  backgroundColor: Colors.purple,
  effortLevel: 'Low',
  isAllDay: false,
),
Event(
  title: 'Weekend Getaway',
  description: 'A short trip with friends to relax and explore nature.',
  from: getDate("Sat").add(const Duration(hours: 8)),
  to: getDate("Sun").add(const Duration(hours: 20)),
  backgroundColor: Colors.red,
  effortLevel: 'Medium',
  isAllDay: true,
),
Event(
  title: 'Prepare Weekly Meals',
  description: 'Prepping meals for the upcoming week.',
  from: getDate("Sun").add(const Duration(hours: 16)),
  to: getDate("Sun").add(const Duration(hours: 19)),
  backgroundColor: Colors.green,
  effortLevel: 'Medium',
  isAllDay: false,
),

    // Add more sample events as needed
  ];
}
