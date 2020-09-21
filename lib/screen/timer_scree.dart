import 'dart:async' show Timer;

import 'package:flutter/material.dart';

class TimerApp extends StatefulWidget {
  final bool isActive;
  final int time;
  TimerApp(this.isActive, this.time);
  @override
  _TimerAppState createState() => _TimerAppState();
}

class _TimerAppState extends State<TimerApp> {
  static const duration = const Duration(seconds: 1);

  int secondsPassed = 0;

  Timer timer;

  void handleTick() {
    if (widget.isActive) {
      setState(() {
        secondsPassed = secondsPassed + 1;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    secondsPassed = widget.time;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (timer == null && widget.isActive) {
      timer = Timer.periodic(duration, (Timer t) {
        // handleTick();
        if (widget.isActive) {
          if (!mounted) return;
          setState(() {
            secondsPassed = secondsPassed + 1;
          });
        }
      });
    }
    int seconds = secondsPassed % 60;
    int minutes = secondsPassed ~/ 60 % 60;
    int hours = secondsPassed ~/ (60 * 60);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LabelText(label: 'HRS', value: hours.toString().padLeft(2, '0')),
              LabelText(
                  label: 'MIN', value: minutes.toString().padLeft(2, '0')),
              LabelText(
                  label: 'SEC', value: seconds.toString().padLeft(2, '0')),
            ],
          ),
        ],
      ),
    );
  }
}

class LabelText extends StatelessWidget {
  LabelText({this.label, this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.blue[300],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '$value',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            '$label',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
