// lib/screens/builder/place_bid_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../models/bid_model.dart';
import '../../models/tender_model.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../widgets/bid_button.dart';
import '../../widgets/bid_list.dart';
import '../../widgets/timer.dart';
import '../login/login_screen.dart';
import '../winner_screen.dart';

class PlaceBidScreen extends StatefulWidget {
  final Tender tender;

  const PlaceBidScreen({super.key, required this.tender});

  @override
  _PlaceBidScreenState createState() => _PlaceBidScreenState();
}

class _PlaceBidScreenState extends State<PlaceBidScreen> {
  final TextEditingController _bidController = TextEditingController();
  late FirebaseService _firebaseService;
  late AuthService _authService;
  bool _isEnded = false;
  String _userRole = 'None';
  String _userName = 'Unknown';

  @override
  void initState() {
    super.initState();
    _firebaseService = Provider.of<FirebaseService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _initializeUser();
    _checkTenderStatus();
  }

  Future<void> _initializeUser() async {
    String role = (await _authService.getUserRole()) ?? 'None';
    String name = (await _authService.getUserName()) ?? 'Unknown';
    setState(() {
      _userRole = role;
      _userName = name;
    });
  }

  void _checkTenderStatus() {
    _firebaseService.getTender(widget.tender.id).listen((doc) {
      if (!mounted) return;
      if (doc.exists) {
        Timestamp endTime = doc['endTime'];
        if (DateTime.now().isAfter(endTime.toDate())) {
          setState(() => _isEnded = true);
        }
      } else {
        setState(() => _isEnded = true);
      }
    });
  }

  void _submitBid() async {
    if (_bidController.text.isEmpty) return;
    double? amount = double.tryParse(_bidController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid bid amount.')),
      );
      return;
    }

    if (amount < widget.tender.minBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Bid must be at least \$${widget.tender.minBid.toStringAsFixed(2)}.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Bid bid = Bid(
      userId: _authService.currentUser!.uid,
      userName: _userName,
      role: _userRole,
      amount: amount,
      timestamp: DateTime.now(),
    );
    await _firebaseService.submitBid(widget.tender.id, bid);
    _bidController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bid submitted successfully!')),
    );
  }

  void _logout() async {
    await _authService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtain screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.tender.name ?? 'Unnamed Tender'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Tender Details Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              shadowColor: AppColors.primary.withOpacity(0.3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.accent.withOpacity(0.05)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tender Name with Icon
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline,
                          color: AppColors.primary,
                          size: screenWidth * 0.07, // 7% of screen width
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.tender.name ?? 'Unnamed Tender',
                            style: TextStyle(
                              fontSize:
                                  screenWidth * 0.055, // 5.5% of screen width
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description with Icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.description,
                          color: AppColors.accent,
                          size: screenWidth * 0.06, // 6% of screen width
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.tender.description ??
                                'No description available',
                            style: TextStyle(
                              fontSize:
                                  screenWidth * 0.04, // 4% of screen width
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Minimum Bid with Icon
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: AppColors.bidAmount,
                          size: screenWidth * 0.06, // 6% of screen width
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Minimum Bid: \$${widget.tender.minBid.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04, // 4% of screen width
                            color: AppColors.bidAmount,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Countdown Timer with Icon
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: AppColors.textSecondary,
                          size: screenWidth * 0.06, // 6% of screen width
                        ),
                        const SizedBox(width: 10),
                        CountdownTimerWidget(
                          endTime: widget.tender.endTime,
                          onEnd: () {
                            if (mounted) setState(() => _isEnded = true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bid List
          Expanded(child: BidList(tenderId: widget.tender.id)),

          if (!_isEnded && _userRole == 'Bidder')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BidButton(
                controller: _bidController,
                onSubmit: _submitBid,
                minBid: widget.tender.minBid,
              ),
            ),

          // View Winner Button (visible only if bidding has ended)
          if (_isEnded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: screenHeight * 0.07, // 7% of screen height
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WinnerScreen(tenderId: widget.tender.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'View Winner',
                    style: TextStyle(
                      color: AppColors.buttonText,
                      fontSize: screenWidth * 0.045, // 4.5% of screen width
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
