import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChurchScheduleScreen extends StatefulWidget {
  final String churchName;
  ChurchScheduleScreen({required this.churchName});

  @override
  _ChurchScheduleScreenState createState() => _ChurchScheduleScreenState();
}

class _ChurchScheduleScreenState extends State<ChurchScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<String>> _events = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.churchName} Schedule"),
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        children: [
          CustomTableCalendar(
            selectedDay: _selectedDate,
            focusedDay: _selectedDate,
            onDaySelected: (selectedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
          ),
          ElevatedButton(
            onPressed: () => _scheduleEvent(),
            child: Text('Schedule Event for ${widget.churchName}'),
          ),
          Expanded(
            child: ListView(
              children: _events[_selectedDate]?.map((event) => ListTile(
                title: Text(event),
              ))?.toList() ?? [Text('No events scheduled')],
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleEvent() async {
    Map<String, dynamic>? eventDetails = await _showAddEventDialog();
    if (eventDetails != null && eventDetails['title'] != null && eventDetails['time'] != null) {
      String eventTitle = eventDetails['title'];
      TimeOfDay eventTime = eventDetails['time'];
      setState(() {
        if (_events[_selectedDate] != null) {
          _events[_selectedDate]?.add("$eventTitle at ${eventTime.format(context)}");
        } else {
          _events[_selectedDate] = ["$eventTitle at ${eventTime.format(context)}"];
        }
      });
    }
  }

  Future<Map<String, dynamic>?> _showAddEventDialog() {
    TextEditingController _eventController = TextEditingController();
    TimeOfDay _selectedTime = TimeOfDay.now();
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _eventController,
              decoration: InputDecoration(hintText: 'Enter event title'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (pickedTime != null) {
                  _selectedTime = pickedTime;
                }
              },
              child: Text('Select Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'title': _eventController.text,
                'time': _selectedTime,
              });
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

class CustomTableCalendar extends StatefulWidget {
  final Function(DateTime) onDaySelected;
  final DateTime selectedDay;
  final DateTime focusedDay;

  CustomTableCalendar({
    required this.onDaySelected,
    required this.selectedDay,
    required this.focusedDay,
  });

  @override
  _CustomTableCalendarState createState() => _CustomTableCalendarState();
}

class _CustomTableCalendarState extends State<CustomTableCalendar> {
  late DateTime _firstDay;
  late DateTime _lastDay;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _updateDateRange();
  }

  void _updateDateRange() {
    _currentMonth = widget.focusedDay;
    // Set the view to cover only two weeks as per default view
    _firstDay = _currentMonth.subtract(Duration(days: _currentMonth.weekday - 1));
    _lastDay = _firstDay.add(Duration(days: 13)); // Two weeks (14 days)
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildDaysOfWeek(),
        _buildCalendarDays(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: _onPreviousMonth,
        ),
        Text(
          DateFormat.yMMMM().format(_currentMonth),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: _onNextMonth,
        ),
      ],
    );
  }

  Widget _buildDaysOfWeek() {
    List<String> daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: daysOfWeek
          .map((day) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
      ))
          .toList(),
    );
  }

  Widget _buildCalendarDays() {
    List<Widget> dayWidgets = [];
    int startingIndex = _firstDay.weekday % 7;

    for (int i = 0; i < startingIndex; i++) {
      dayWidgets.add(Container(width: 32, height: 32));
    }

    for (int day = _firstDay.day; day <= _lastDay.day; day++) {
      DateTime currentDate = DateTime(_currentMonth.year, _currentMonth.month, day);
      bool isSelected = isSameDay(currentDate, widget.selectedDay);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            widget.onDaySelected(currentDate);
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.blue : Colors.transparent,
            ),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  void _onPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _updateDateRange();
    });
  }

  void _onNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _updateDateRange();
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
