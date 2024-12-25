import 'package:cloud_firestore/cloud_firestore.dart';

class Bid {
  final String userId;
  final String userName;
  final String role;
  final double amount;
  final DateTime timestamp;

  Bid({
    required this.userId,
    required this.userName,
    required this.role,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'role': role,
      'amount': amount,
      'timestamp': timestamp,
    };
  }

  factory Bid.fromMap(Map<String, dynamic> map) {
    return Bid(
      userId: map['userId'],
      userName: map['userName'],
      role: map['role'],
      amount: (map['amount'] as num).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
