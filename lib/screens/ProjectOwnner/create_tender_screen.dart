// lib/screens/contractor/create_tender_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';

class CreateTenderScreen extends StatefulWidget {
  const CreateTenderScreen({super.key});

  @override
  _CreateTenderScreenState createState() => _CreateTenderScreenState();
}

class _CreateTenderScreenState extends State<CreateTenderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minBidController = TextEditingController();
  DateTime? _endDate;
  TimeOfDay? _endTime;

  void _createTender() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _minBidController.text.isEmpty ||
        _endDate == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    double? minBid = double.tryParse(_minBidController.text);
    if (minBid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid minimum bid.')),
      );
      return;
    }

    final endDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    String userName = (await authService.getUserName()) ?? 'Unknown';
    String userId = authService.currentUser!.uid;

    await firebaseService.createTender(userId, userName, {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'minBid': minBid,
      'endTime': endDateTime,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tender created successfully!')),
    );
    Navigator.pop(context);
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _endDate = selectedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (selectedTime != null) {
      setState(() {
        _endTime = selectedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tender'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tender Name'),
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenWidth * 0.03),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenWidth * 0.03),
            TextField(
              controller: _minBidController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Minimum Bid'),
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenWidth * 0.03),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectDate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _endDate == null
                      ? 'Select End Date'
                      : 'End Date: ${_endDate!.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: AppColors.buttonText,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectTime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _endTime == null
                      ? 'Select End Time'
                      : 'End Time: ${_endTime!.format(context)}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: AppColors.buttonText,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.05),
            SizedBox(
              width: double.infinity,
              height: screenWidth * 0.12,
              child: ElevatedButton(
                onPressed: _createTender,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create Tender',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: AppColors.buttonText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
