// lib/screens/winner_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../models/bid_model.dart';
import '../services/firebase_service.dart';

class WinnerScreen extends StatelessWidget {
  final String tenderId;

  const WinnerScreen({super.key, required this.tenderId});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Winner'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<Bid?>(
        future: firebaseService.getWinner(tenderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred.'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No bids were placed.'));
          }
          Bid winner = snapshot.data!;
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Card(
                color: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: screenWidth * 0.2,
                        color: Colors.amber,
                      ),
                      SizedBox(height: screenWidth * 0.05),
                      Text(
                        'Winner: ${winner.userName}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Text(
                        'Bid Amount: \$${winner.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: AppColors.bidAmount,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Text(
                        'Submitted on: ${DateFormat.yMMMd().add_jm().format(winner.timestamp)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: AppColors.bidTimestamp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
