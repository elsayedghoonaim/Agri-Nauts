import 'package:flutter/material.dart';
import 'dart:async';




class DigitalClockScreen extends StatefulWidget {
  @override
  _DigitalClockScreenState createState() => _DigitalClockScreenState();
}

class _DigitalClockScreenState extends State<DigitalClockScreen> {
  String _currentTime = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    int hour = now.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12; // Convert to 12-hour format
    hour = hour == 0 ? 12 : hour; // If hour is 0, set it to 12

    setState(() {
      _currentTime = "${hour.toString()}:${now.minute.toString().padLeft(2, '0')} $period";
    });
  }

  @override
  Widget build(BuildContext context) {
    double screewidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
            _currentTime,
            style: TextStyle(color: Colors.white,fontSize:screewidth * 0.08,fontWeight: FontWeight.bold),
          ),
    );
}}
