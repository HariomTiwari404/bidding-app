import 'package:cloud_firestore/cloud_firestore.dart';

class Tender {
  final String id;
  final String companyId;
  final String companyName;
  final String name; // New field
  final String description;
  final double minBid;
  final DateTime endTime;

  Tender({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.name,
    required this.description,
    required this.minBid,
    required this.endTime,
  });

  factory Tender.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Tender(
      id: doc.id,
      companyId: data['companyId'] ?? 'Unknown',
      companyName: data['companyName'] ?? 'Unknown Company',
      name: data['name'] ?? 'Unnamed Tender', // Default name
      description: data['description'] ?? 'No description',
      minBid: (data['minBid'] as num?)?.toDouble() ?? 0.0,
      endTime: (data['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
