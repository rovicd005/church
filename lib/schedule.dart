import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

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
                      _buildChurchButton(context, 'Sta Ana', 'assets/sa.jpg'),
                      _buildChurchButton(context, 'Candaba', 'assets/background02.jpg'),
                      _buildChurchButton(context, 'Arayat', 'assets/ar.jpg'),
                      _buildChurchButton(context, 'San Luis', 'assets/luis.jpg'),
                      _buildChurchButton(context, 'Mexico', 'assets/mex.jpg'),
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
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final url = Uri.parse('https://sanctisync.site/church/schedules/get_church_events.php?church_name=${widget.churchName}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> eventsList = data['events'] ?? [];

        final Map<DateTime, List<String>> loadedEvents = {};

        for (var event in eventsList) {
          DateTime eventDate = DateTime.parse(event['event_date']);
          String eventName = event['event_name'];
          String eventTime = event['event_time'];

          if (loadedEvents[eventDate] == null) {
            loadedEvents[eventDate] = [];
          }
          loadedEvents[eventDate]?.add("$eventName at $eventTime");
        }

        setState(() {
          _events = loadedEvents;
        });
      } catch (e) {
        print("Error parsing response: $e");
      }
    } else {
      print("Failed to load events. Status code: ${response.statusCode}");
    }
  }

  Future<void> _deleteEvent(String event) async {
    final parts = event.split(" at ");
    if (parts.length != 2) return;

    final url = Uri.parse('https://sanctisync.site/church/schedules/delete_church_event.php');
    final response = await http.post(url, body: {
      'church_name': widget.churchName,
      'event_name': parts[0],
      'event_date': _selectedDate.toIso8601String().split('T')[0], // Only the date part
      'event_time': parts[1],
    });

    if (response.statusCode == 200) {
      setState(() {
        _events[_selectedDate]?.remove(event);
        if (_events[_selectedDate]?.isEmpty ?? false) {
          _events.remove(_selectedDate);
        }
      });
    } else {
      print("Failed to delete event. Status code: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.churchName} Schedule"),
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
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
                setState(() {
                  _calendarFormat = format;
                });
              },
              eventLoader: (day) => _events[day] ?? [],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: (_events[_selectedDate] ?? [])
                    .map((event) => _buildEventItem(event))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(String event) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(event),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteEvent(event),
        ),
      ),
    );
  }
}
