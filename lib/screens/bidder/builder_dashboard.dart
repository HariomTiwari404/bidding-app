// lib/screens/builder/builder_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../models/tender_model.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../login/login_screen.dart';
import 'place_bid_screen.dart';

class BidderDashboard extends StatelessWidget {
  const BidderDashboard({super.key});

  void _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Available Tenders'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<List<Tender>>(
        stream: firebaseService.getTendersForBidders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred.'));
          }
          final tenders = snapshot.data ?? [];
          if (tenders.isEmpty) {
            return const Center(child: Text('No tenders available.'));
          }

          List<Tender> sortedTenders = [...tenders];
          sortedTenders.sort((a, b) {
            bool aExpired = DateTime.now().isAfter(a.endTime);
            bool bExpired = DateTime.now().isAfter(b.endTime);
            if (!aExpired && bExpired) return -1;
            if (aExpired && !bExpired) return 1;
            return 0;
          });

          return ListView.separated(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: sortedTenders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tender = sortedTenders[index];
              final isExpired = DateTime.now().isAfter(tender.endTime);
              final status = isExpired ? 'Expired' : 'Active';
              final statusColor = isExpired ? AppColors.error : Colors.green;

              return Card(
                color: AppColors.bidCardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    tender.name ?? 'Unnamed Tender',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: Text(
                    status,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceBidScreen(tender: tender),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
