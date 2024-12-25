// lib/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bid_model.dart';
import '../models/tender_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Tender>> getTendersForAdmin() {
    return _db.collection('tenders').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Tender.fromDocument(doc)).toList());
  }

  Stream<List<Tender>> getTendersForProjectOwner(String companyId) {
    return _db
        .collection('tenders')
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Tender.fromDocument(doc)).toList());
  }

  Stream<List<Tender>> getTendersForBidders() {
    return _db.collection('tenders').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Tender.fromDocument(doc)).toList());
  }

  Stream<List<Tender>> getActiveTendersForBidders() {
    return _db
        .collection('tenders')
        .where('endTime', isGreaterThan: Timestamp.now())
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Tender.fromDocument(doc)).toList());
  }

  Stream<List<Tender>> getExpiredTendersForBidders() {
    return _db
        .collection('tenders')
        .where('endTime', isLessThanOrEqualTo: Timestamp.now())
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Tender.fromDocument(doc)).toList());
  }

  Future<void> createTender(
      String userId, String userName, Map<String, dynamic> tenderData) async {
    await _db.collection('tenders').add({
      ...tenderData,
      'companyId': userId,
      'companyName': userName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTender(
      String tenderId, Map<String, dynamic> tenderData) async {
    await _db.collection('tenders').doc(tenderId).update(tenderData);
  }

  Future<void> deleteTender(String tenderId) async {
    await _db.collection('tenders').doc(tenderId).delete();
  }

  Stream<List<Bid>> getBids(String tenderId) {
    return _db
        .collection('tenders')
        .doc(tenderId)
        .collection('bids')
        .orderBy('amount', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Bid.fromMap(doc.data())).toList());
  }

  Future<Bid?> getWinner(String tenderId) async {
    QuerySnapshot snapshot = await _db
        .collection('tenders')
        .doc(tenderId)
        .collection('bids')
        .orderBy('amount', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return Bid.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<DocumentSnapshot> getTender(String tenderId) {
    return _db.collection('tenders').doc(tenderId).snapshots();
  }

  Future<void> submitBid(String tenderId, Bid bid) async {
    await _db
        .collection('tenders')
        .doc(tenderId)
        .collection('bids')
        .add(bid.toMap());
  }
}
