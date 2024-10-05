import 'package:flutter/material.dart';
import 'dart:async';

class DateDisplayScreen extends StatefulWidget {
  @override
  _DateDisplayScreenState createState() => _DateDisplayScreenState();
}

class _DateDisplayScreenState extends State<DateDisplayScreen> {
  String _currentDate = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateDate();
    _timer = Timer.periodic(Duration(days: 1), (timer) {
      _updateDate();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateDate() {
    final now = DateTime.now();
    String day = now.day.toString();
    String month = _getMonthName(now.month); // Get month name
    String abbreviatedDay = _getAbbreviatedDay(now); // Get abbreviated day

    setState(() {
      _currentDate = "$abbreviatedDay, $day, $month"; // Format: Mon, 23, September
    });
  }

  String _getMonthName(int month) {
    const List<String> monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return monthNames[month - 1]; // Adjust for 0-indexed list
  }

  String _getAbbreviatedDay(DateTime date) {
    const List<String> dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return dayNames[date.weekday - 1]; // Adjust for 0-indexed list
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _currentDate,
        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
      ),
    );
  }
}
