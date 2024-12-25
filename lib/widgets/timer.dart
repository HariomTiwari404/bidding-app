// lib/widgets/countdown_timer_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/colors.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime endTime;
  final VoidCallback onEnd;

  const CountdownTimerWidget({
    super.key,
    required this.endTime,
    required this.onEnd,
  });

  @override
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Duration _remaining;
  late Timer _timer;
  Color _timerColor = AppColors.textSecondary;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() {
    _updateDuration();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDuration();
      if (_remaining.inSeconds <= 0) {
        _timer.cancel();
        widget.onEnd();
      }
    });
  }

  void _updateDuration() {
    final now = DateTime.now().toUtc();
    final endTimeUtc = widget.endTime.toUtc();
    setState(() {
      _remaining = endTimeUtc.difference(now);
      if (_remaining.isNegative) {
        _remaining = Duration.zero;
      }
      _updateTimerColor();
    });
  }

  void _updateTimerColor() {
    if (_remaining.inMinutes > 15) {
      _timerColor = Colors.green;
    } else if (_remaining.inMinutes > 5) {
      _timerColor = Colors.orange;
    } else {
      _timerColor = Colors.red;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtain screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        // Removed background color as per user request
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _remaining.inSeconds > 0 ? 'Time Remaining' : 'Bidding Ended',
                style: TextStyle(
                  fontSize: screenWidth * 0.035, // 3.5% of screen width
                  fontWeight: FontWeight.w600,
                  color: _timerColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _remaining.inSeconds > 0
                    ? _formatDuration(_remaining)
                    : '00:00:00',
                style: TextStyle(
                  fontSize: screenWidth * 0.045, // 4.5% of screen width
                  fontWeight: FontWeight.bold,
                  color: _timerColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
