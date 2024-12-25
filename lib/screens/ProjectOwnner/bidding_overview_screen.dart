// lib/screens/builder/bidding_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../models/bid_model.dart';
import '../../models/tender_model.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';

class BiddingOverviewScreen extends StatelessWidget {
  const BiddingOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bidding Overview'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<List<Tender>>(
        stream: firebaseService
            .getTendersForProjectOwner(authService.currentUser!.uid),
        builder: (context, tenderSnapshot) {
          if (tenderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (tenderSnapshot.hasError ||
              !tenderSnapshot.hasData ||
              tenderSnapshot.data!.isEmpty) {
            return const Center(child: Text('No tenders found.'));
          }
          final tenders = tenderSnapshot.data!;
          return ListView.builder(
            itemCount: tenders.length,
            itemBuilder: (context, index) {
              final tender = tenders[index];
              return ExpansionTile(
                title: Text(
                  tender.name,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  StreamBuilder<List<Bid>>(
                    stream: firebaseService.getBids(tender.id),
                    builder: (context, bidSnapshot) {
                      if (bidSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (bidSnapshot.hasError ||
                          !bidSnapshot.hasData ||
                          bidSnapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No bids yet.'),
                        );
                      }
                      final bids = bidSnapshot.data!;
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.02),
                            child: FutureBuilder<Bid?>(
                              future: firebaseService.getWinner(tender.id),
                              builder: (context, winnerSnapshot) {
                                if (winnerSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (winnerSnapshot.hasError ||
                                    !winnerSnapshot.hasData ||
                                    winnerSnapshot.data == null) {
                                  return const Text(
                                    'No winner yet.',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  );
                                }
                                final winner = winnerSnapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Winner:',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Name: ${winner.userName}',
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.035),
                                    ),
                                    Text(
                                      'Bid: \$${winner.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.035),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: bids.length,
                            itemBuilder: (context, bidIndex) {
                              final bid = bids[bidIndex];
                              return ListTile(
                                leading: const Icon(Icons.gavel),
                                title: Text(
                                  bid.userName,
                                  style:
                                      TextStyle(fontSize: screenWidth * 0.04),
                                ),
                                trailing: Text(
                                  '\$${bid.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.bidAmount,
                                  ),
                                ),
                                subtitle: Text(
                                  'Placed at: ${DateFormat.yMMMd().add_jm().format(bid.timestamp.toLocal())}',
                                  style:
                                      TextStyle(fontSize: screenWidth * 0.03),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
