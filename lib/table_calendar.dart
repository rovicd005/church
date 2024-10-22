import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

// Main ScheduleScreen with Custom Calendar Integration
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

// ChurchScheduleScreen with the custom calendar widget
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

// Custom Calendar Widget
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
    _firstDay = DateTime(widget.focusedDay.year, widget.focusedDay.month, 1);
    _lastDay = DateTime(widget.focusedDay.year, widget.focusedDay.month + 1, 0);
    _currentMonth = widget.focusedDay;
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
    int totalDays = _lastDay.day;

    int startingIndex = _firstDay.weekday % 7;

    for (int i = 0; i < startingIndex; i++) {
      dayWidgets.add(Container(width: 32, height: 32));
    }

    for (int day = 1; day <= totalDays; day++) {
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
      _firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
      _lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    });
  }

  void _onNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
      _lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
