import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background000.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              PreferredSize(
                preferredSize: Size.fromHeight(70.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey[900]!, Colors.grey[700]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: AppBar(
                      centerTitle: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChurchButton(context, 'Sta Ana', 'assets/background01.jpg'),
                      _buildChurchButton(context, 'Candaba', 'assets/background02.jpg'),
                      _buildChurchButton(context, 'Arayat', 'assets/background05.jpg'),
                      _buildChurchButton(context, 'San Luis', 'assets/background03.jpg'),
                      _buildChurchButton(context, 'Mexico', 'assets/background04.jpg'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChurchButton(BuildContext context, String churchName, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.15,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.7),
                      BlendMode.dstATop,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                churchName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black.withOpacity(0.8),
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChurchScheduleScreen(churchName: churchName),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChurchScheduleScreen extends StatefulWidget {
  final String churchName;

  ChurchScheduleScreen({required this.churchName});

  @override
  _ChurchScheduleScreenState createState() => _ChurchScheduleScreenState();
}

class _ChurchScheduleScreenState extends State<ChurchScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
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
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            eventLoader: (day) => _events[day] ?? [],
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
