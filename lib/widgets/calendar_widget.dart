import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:weekly_planner_sf_main/model/event_data_source.dart';
import 'package:weekly_planner_sf_main/model/tag.dart';
import 'package:weekly_planner_sf_main/pages/event_viewing_page.dart';
import 'package:weekly_planner_sf_main/provider/event_provider.dart';
import 'package:weekly_planner_sf_main/provider/settings_provider.dart';
import 'package:weekly_planner_sf_main/provider/tag_provider.dart';
import 'package:weekly_planner_sf_main/utils/app_colors.dart';
import 'package:weekly_planner_sf_main/utils/setting_constants.dart';
import 'package:weekly_planner_sf_main/utils/utils.dart';
import 'package:weekly_planner_sf_main/widgets/tasks_widget.dart';

class CalendarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // make the list of events be provided by the EventProvider, so we update this everytime it notifieslisteners.
    final eventProvider = Provider.of<EventProvider>(context);
    final events = eventProvider.events;

    Map<String, Color> effortLevelColors =
        SettingsUtil.getEffortLevelColors(context);
    // Debug: Print each event's tags to the console

    return SfCalendar(
      view: CalendarView.week,
      timeSlotViewSettings: const TimeSlotViewSettings(
        timeFormat: settings_TimeFormat,
        timeInterval: settings_TimeInterval,
        startHour: settings_startHour,
        endHour: settings_endHour,
      ),
      firstDayOfWeek: 1,
      dataSource: EventDataSource(events,
          effortLevelColors), // This is basically a "wrapper" around our list of events, which basically explains our SF_calendar how to work with our events.
      initialSelectedDate: DateTime.now(),
      selectionDecoration: const BoxDecoration(color: Colors.transparent),
      cellBorderColor: Colors.transparent,
      appointmentBuilder: appointmentBuilder,
      // on long press get the details of the date (aka the events we have on that day)
      onLongPress: (details) async {
        final provider = Provider.of<EventProvider>(context,
            listen:
                false); // once again unsure if this should be false, but we'll test it out (*UNFINISHED*)

        provider.setDate(details.date!);
        await showModalBottomSheet(
          context: context,
          builder: (context) => TasksWidget(),
        );
        provider
            .loadEvents(); // kind of a bad fix, but it makes sure that we load the entire calendar again after having only loaded events for the selected date.
      },
      onTap: (details) async {
        if (details.appointments == null) return;
        final eventTapped = details.appointments!.first;

        // Fetch tags for the event before navigation
        final eventProvider =
            Provider.of<EventProvider>(context, listen: false);
        List<Tag> tags = await eventProvider.fetchTagsForEvent(eventTapped.id);
        final updatedEvent = eventTapped.copyWith(tags: tags);

        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EventViewingPage(event: updatedEvent),
        ));
      },
    );
  }

  Widget appointmentBuilder(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final event =
        details.appointments.first;

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Determine appointment color based on effort level
        Color appointmentColor;
        switch (event.effortLevel) {
          case 'Recharge':
            appointmentColor = settingsProvider.rechargeEffortColor;
            break;
          case 'Low':
            appointmentColor = settingsProvider.lowEffortColor;
            break;
          case 'Medium':
            appointmentColor = settingsProvider.mediumEffortColor;
            break;
          case 'High':
            appointmentColor = settingsProvider.highEffortColor;
            break;
          default:
            appointmentColor =
                event.backgroundColor ?? Colors.grey; // Fallback color
        }

        // Determine whether to show tags based on the appointment height
        bool showTags =
            details.bounds.height > 50; // Adjust the threshold as needed

        return Container(
          width: details.bounds.width,
          height: details.bounds.height,
          decoration: BoxDecoration(
            color: appointmentColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  event.title,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  minFontSize: 14,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showTags) // Show small circles for each tag if there's enough space
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Wrap(
                    direction: Axis.horizontal,
                    children: event.tags
                        .map((tag) => Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tag.color,
                              ),
                            ))
                        .toList().cast<Widget>(),
                  ),
                )
              else // Show a single icon indicator if not enough space
                const Positioned(
                  right: 4,
                  bottom: 4,
                  child: Icon(Icons.tag, size: 16, color: Colors.white),
                ),
            ],
          ),
        );
      },
    );
  }
}
