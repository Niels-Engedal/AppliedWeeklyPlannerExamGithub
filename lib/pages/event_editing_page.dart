// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:weekly_planner_sf_main/model/event.dart';
import 'package:weekly_planner_sf_main/model/tag.dart';
import 'package:weekly_planner_sf_main/provider/event_provider.dart';
import 'package:weekly_planner_sf_main/provider/tag_provider.dart';
import 'package:weekly_planner_sf_main/utils/setting_constants.dart';
import 'package:weekly_planner_sf_main/utils/utils.dart';

class EventEditingPage extends StatefulWidget {
  final Event? event;

  const EventEditingPage({
    Key? key,
    this.event,
  }) : super(key: key);

  @override
  _EventEditingPageState createState() => _EventEditingPageState();
}

class _EventEditingPageState extends State<EventEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<Tag> _selectedTags = [];
  List<Tag> _availableTags = [];
  late DateTime fromDate;
  late DateTime toDate;
  late String selectedEffortLevel;

  @override
  void initState() {
    super.initState();

    // check if we are editing an event or creating it:
    if (widget.event == null) {
      // here we should add effortlevel or color etc.
      fromDate = DateTime.now();
      toDate = DateTime.now().add(const Duration(hours: 2));
      selectedEffortLevel = effortLevelsList[0]; // so we get it from the setting_constants file
      _selectedTags = [];
      loadAvailableTags();
    } else {
      final Event event = widget.event!;
      // here we should add effortlevel or color etc.
      titleController.text = event.title;
      fromDate = event.from;
      toDate = event.to;
      selectedEffortLevel = event.effortLevel;
      descriptionController.text = event.description;
      _selectedTags = List.from(event.tags);
      loadAvailableTags();
    }
    loadTags();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        actions: buildEditingActions(),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                buildTitle(),
                buildDateTimePickers(),
                buildEffortLevelPicker(),
                buildDescription(),
                buildTagsChips(), // Display the tags as chips
                buildAddTagButton(), // Field to add new tags
                buildAvailableTagsChips(),
                
              ],
            ),
          )));

  List<Widget> buildEditingActions() => [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          onPressed: saveForm, // call "saveForm"-method which validates the saved event details.
          icon: const Icon(Icons.done),
          label: const Text('SAVE'),
        ),
      ];
/* ------------------------------------------------------------------------------------------------------------------------
Methods for building Editing Page
------------------------------------------------------------------------------------------------------------------------ */ 
  // Build the title
  Widget buildTitle() => TextFormField(
    style: TextStyle(fontSize: 24),
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'Add Title',
        ),
        onFieldSubmitted: (_) => saveForm(), // call "saveForm"-method which validates title and event details (this one is when you press "ok" on your keyboard to enter)
        validator: (title) =>
            title != null && title.isEmpty ? 'Title cannot be empty' : null,
        controller: titleController,
      );

  // Build the "Date"-pickers
  Widget buildDateTimePickers() => Column(
    children: [
      buildFrom(),
      buildTo(),
    ],
    );
  
  // Method to arrange the "from"-date and "from"-time dropdownfields (Extra note: This could/should be combined with the "buildTo"-method to follow "DRY"-principles)
  Widget buildFrom() => buildHeader(
    header: 'FROM',
    child: Row(
      children: [
        // "date"-dropdownfield
        Expanded(
          flex: 2, // makes the "date"-dropdownfield take up 2x as much as the time dropdownfield
          child: buildDropdownField(
            text: Utils.toDate(fromDate),
            onClicked: () => pickFromDateTime(pickDate: true),
          ),
        ),
        // "time"-dropdownfield
        Expanded(
          child: buildDropdownField(
            text: Utils.toTime(fromDate), 
            onClicked: () => pickFromDateTime(pickDate: false), // set flag to false, so we get to pick the time
          ),
        ),
      ],
      ),
  );

  // Method to arrange the "to"-date and "to"-time dropdownfields
  Widget buildTo() => buildHeader(
    header: 'TO',
    child: Row(
      children: [
        // "date"-dropdownfield
        Expanded(
          flex: 2, // makes the "date"-dropdownfield take up 2x as much as the time dropdownfield
          child: buildDropdownField(
            text: Utils.toDate(toDate),
            onClicked: () => pickToDateTime(pickDate: true),
          ),
        ),
        // "time"-dropdownfield
        Expanded(
          child: buildDropdownField(
            text: Utils.toTime(toDate), 
            onClicked: () => pickToDateTime(pickDate: false),
          ),
        ),
      ],
      ),
  );
  
  // Method to create the dropdownfields we need in "from" and "to" selection.
  Widget buildDropdownField({
    required String text,
    required VoidCallback onClicked,    
    }) => 
    ListTile(
      title: Text(text),
      trailing: Icon(Icons.arrow_drop_down),
      onTap: onClicked,
    );

  // Method to build header above dropdownfields e.g. "FROM" or "TO"
  Widget buildHeader({
    required String header, 
    required Widget child,
    }) => 
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(top: 20)), // added padding between header and Title underlined inputfield
        Text(header, style: TextStyle(fontWeight: FontWeight.bold)),
        child,
      ],
    );

    Widget buildEffortLevelPicker() => buildHeader(
      header: "Select Effort-level", 
      child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: DropdownButtonFormField<String>(
      value: selectedEffortLevel,
      items: effortLevelsList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState((){
          selectedEffortLevel = newValue!;
        });
      },
    ),
  ),
  );

  // Method for building description field
  Widget buildDescription() => buildHeader(
    header: "Description",
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        style: TextStyle(fontSize: 12),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              hintText: 'Add description',
            ),
            onFieldSubmitted: (_) => saveForm(), // call "saveForm"-method which validates title and event details (this one is when you press "ok" on your keyboard to enter)
            controller: descriptionController,
          ),
    ),
  );
  // Method to build Tag Chips
  Widget buildTagsChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _selectedTags.map((tag) => Chip(
        label: Text(tag.text),
        backgroundColor: tag.color,
        onDeleted: () {
          setState(() => _selectedTags.removeWhere((t) => t == tag));

          // No call to TagProvider.deleteTag since we're only removing it from this event
        },
      )).toList(),
    );
  }

  // Method/button to call the tag dialog
  Widget buildAddTagButton() {
    return ElevatedButton(
      onPressed: () => showAddTagDialog(context),
      child: Text('Add Tag'),
    );
  }

  // Method to show the tag dialog
  Future<void> showAddTagDialog(BuildContext context) async {
    final tagProvider = Provider.of<TagProvider>(context, listen: false);
    final TextEditingController tagController = TextEditingController();
    Color selectedColor = Colors.blue; // Default color for the tag

    // Show a dialog to get the tag text and select a color
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Tag"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tagController,
                decoration: InputDecoration(labelText: 'Tag'),
              ),
              SizedBox(height: 20),
              // Simple color picker as circles
              Wrap(
                children: List<Widget>.generate(Colors.primaries.length, (int index) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedColor = Colors.primaries[index];
                    }),
                    child: CircleAvatar(
                      backgroundColor: Colors.primaries[index],
                      child: selectedColor == Colors.primaries[index] ? Icon(Icons.check) : null,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                if (tagController.text.isNotEmpty) {
                  // Add the new tag through the TagProvider
                  await tagProvider.addTag(tagController.text, selectedColor);
                  // Refresh your local tags list from the provider after adding
                  await tagProvider.loadTagsFromDatabase();
                  setState(() {
                    // Add the new tag to the selected tags list
                    Tag newTag = tagProvider.tags.firstWhere(
                      (t) => t.text == tagController.text && t.color == selectedColor,
                      orElse: () => Tag(text: tagController.text, color: selectedColor),
                    );
                    _selectedTags.add(newTag);
                    // Optionally, refresh the available tags list as well
                    _availableTags = tagProvider.tags;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }


  // method to load tags
  Future<void> loadTags() async {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      await tagProvider.loadTagsFromDatabase();
    // This function's behavior should differ based on whether you're editing an existing event
    // or creating a new one. For a new event, you might load all tags or no tags.
    if (widget.event != null) {
      // Editing an existing event
      List<Tag> eventTags = await tagProvider.fetchTagsForEvent(widget.event!.id!);
      setState(() {
        _selectedTags = eventTags;
      });
    } else {
      setState(() {
        _selectedTags = [];
      });
    }
  }

  // Method to load available tags
  Future<void> loadAvailableTags() async {
  final tagProvider = Provider.of<TagProvider>(context, listen: false);
  await tagProvider.loadTagsFromDatabase();
  _availableTags = tagProvider.tags;
  }

  Widget buildAvailableTagsChips() {
  return Wrap(
    spacing: 8.0,
    runSpacing: 4.0,
    children: _availableTags.map((tag) => ActionChip(
      label: Text(tag.text),
      backgroundColor: tag.color,
      // When the chip is tapped, add it to the selected tags
      onPressed: () => addTagToEvent(tag),
    )).toList(),
  );
}


  void addTagToEvent(Tag tag) {
    setState(() {
      _selectedTags.add(tag);
      _availableTags.removeWhere((t) => t.id == tag.id);
    });
  }

  Widget buildSelectedTagsChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _selectedTags.map((tag) => Chip(
        label: Text(tag.text),
        backgroundColor: tag.color,
        onDeleted: () => removeTagFromEvent(tag),
      )).toList(),
    );
  }


void removeTagFromEvent(Tag tag) {
  setState(() {
    _selectedTags.removeWhere((t) => t.id == tag.id);
    _availableTags.add(tag); // Optionally add it back to the available tags
  });
}






  


/* ------------------------------------------------------------------------------------------------------------------------
Methods for Validation and Errorhandling
------------------------------------------------------------------------------------------------------------------------ */ 
  // Method to validate if event details on EventEditingPage is filled out correctly
  Future saveForm() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final event = Event(
        title: titleController.text,
        description: descriptionController.text,
        from: fromDate,
        to: toDate,
        isAllDay: false,
        effortLevel: selectedEffortLevel,
        tags: _selectedTags, // Use the current tags from the local state
        );

      // are we editing or not?
      final isEditing = widget.event != null; // basically does it exist already or not?
      
      // access the "EventProvider" which lets everyone know that we have added a new event, so they should update if they use the events list.
      final provider = Provider.of<EventProvider>(context, listen: false); // listen has to be false, because this just provides (idk if this is correct, but "true" gives error).
      if (isEditing){
        // create the new event with some of the old stuff (mainly ID)
        final event = Event(
          id: widget.event!.id, // retain the original event's id!
          title: titleController.text,
          description: descriptionController.text,
          from: fromDate,
          to: toDate,
          isAllDay: widget.event!.isAllDay, //TODO: could maybe be relevant to actually add the option to make it all day.
          backgroundColor: effortLevelColorMap[selectedEffortLevel] ?? Colors.lightGreen,
          effortLevel: selectedEffortLevel,
          tags: _selectedTags,
        );

        // Update the event's tags:
        await provider.updateEventWithTags(event, _selectedTags);
        provider.editEvent(event, widget.event!);
        Navigator.of(context).pop();

      } else {
      provider.addEvent(event);
      }

      Navigator.of(context).pop();
    }

  }

  // Method for building toTimeErrorAlert
  Future<void> showToTimeErrorAlert() async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Invalid Date'),
        content: Text('Your "To Date" is earlier than your "From Time". Please pick a "To Time" that is after your "From Time".'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              pickToDateTime(pickDate: false);
            },
            child: const Text('Pick New "To Time"'),
          ),
        ],
      );
    },
  );
}

/* ------------------------------------------------------------------------------------------------------------------------
Methods for picking DateTime
------------------------------------------------------------------------------------------------------------------------ */ 
  // Method to update state of variable "fromDate"
  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(fromDate, pickDate: pickDate);

    if (date == null) return; // check if the date exists

    // if the picked "fromDate" is after the "toDate", then set the "toDate" to be the same day as "fromDate" and set the time of "toDate" to be the same as before.
    if (date.isAfter(toDate)){
      toDate = DateTime(date.year, date.month, date.day, date.hour, date.minute);
      // then add 2 hours to the toDate, so it is after the from date
      toDate = toDate.add(Duration(hours: 2));
    }

    setState(() => fromDate = date); // if it exists set the state to the "DateTime"-object that is returned from the "pickDateTime"-method below.
  }

  // Method to update state of variable "toDate"
  Future pickToDateTime({required bool pickDate}) async {
    final date = await pickDateTime(
    toDate,
    pickDate: pickDate, 
    firstDate: pickDate ? fromDate : null);  // because we are picking a toDate we want the dates available to be the same day as "fromDate" and forward.

    if (date == null) return; // check if the date exists

    // check if the selected time and date is after the fromDate
    if (date.isAfter(fromDate)){
      setState(() => toDate = date); // if it exists (and is after fromDate) set the state to the "DateTime"-object that is returned from the "pickDateTime"-method below.
    } else {
      // Display error message and make the user pick a new toDatetime
      showToTimeErrorAlert();
    }
  }

  // Method with logic for what happens depending on if you pick a Date or Time.
  Future <DateTime?> pickDateTime(DateTime initialDate, {required bool pickDate, DateTime? firstDate,}) async {
        // if you are picking a date, then let the user pick a date using in-built "datepicker":
        if (pickDate){
          final date = await showDatePicker(
            context: context,
            initialDate: initialDate,
            //limitations for date picker
            firstDate: firstDate ?? DateTime(2015, 8),
            lastDate: DateTime(2101), 
          );
          // make sure the date actually exists:
          if (date == null) return null; // if it doesn't return null immediately
          
          // if the date exists we move on and pick the time from our initial date (the fromDate we passed into the "pickFromDateTime"-method)
          final time = Duration(hours: initialDate.hour, minutes: initialDate.minute);

          return date.add(time); // give us the time for this 
          
          // otherwise let user pick the time of day using in-built "timepicker".
        } else {
          final timeOfDay = await showTimePicker(
            initialEntryMode: TimePickerEntryMode.dial, // or alternatively TimePickerEntryMode.dial
            context: context,
            initialTime: TimeOfDay.fromDateTime(roundDownToHour(initialDate)), // make sure the time picker shows the time we are currently on for our event
          );

          if (timeOfDay == null) return null; // check if it exists

          final date = DateTime(initialDate.year, initialDate.month, initialDate.day); // create the variable of the date we are picking a time for
          final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute); // create the variable to store the time for this date
          
          return date.add(time); // add them together to return a full "DateTime"-object with both the initial date and the newly picked time.
        }
      }
      
      // Method used when picking times.
      DateTime roundDownToHour(DateTime dateTime) {
        return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour);
      }

  
  
}
