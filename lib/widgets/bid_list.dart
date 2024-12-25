// lib/widgets/bid_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../models/bid_model.dart';
import '../../services/firebase_service.dart';

class BidList extends StatelessWidget {
  final String tenderId;

  const BidList({super.key, required this.tenderId});

  void _showBidDetails(BuildContext context, Bid bid, double screenWidth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: screenWidth * 0.2,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: screenWidth * 0.06,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      bid.userName,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.badge,
                    color: AppColors.accent,
                    size: screenWidth * 0.05,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    bid.role,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: AppColors.bidAmount,
                    size: screenWidth * 0.05,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Bid Amount: \$${bid.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: AppColors.bidAmount,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.textSecondary,
                    size: screenWidth * 0.05,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Submitted on: ${DateFormat.yMMMd().add_jm().format(bid.timestamp)}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: AppColors.bidTimestamp,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: screenWidth * 0.12,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: AppColors.buttonText,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder<List<Bid>>(
      stream: firebaseService.getBids(tenderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('Failed to load bids.')),
          );
        }
        final bids = snapshot.data ?? [];
        if (bids.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No bids yet.')),
          );
        }
        bids.sort((a, b) => b.amount.compareTo(a.amount));
        return Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            itemCount: bids.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final bid = bids[index];
              return GestureDetector(
                onTap: () => _showBidDetails(context, bid, screenWidth),
                child: Card(
                  color: AppColors.bidCardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.accent,
                          child: Text(
                            bid.userName.isNotEmpty
                                ? bid.userName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.buttonText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bid.userName,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${bid.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: AppColors.bidAmount,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat.Hm().format(bid.timestamp),
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: AppColors.bidTimestamp,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textSecondary,
                              size: screenWidth * 0.04,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
