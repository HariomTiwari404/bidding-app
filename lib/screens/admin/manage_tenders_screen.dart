import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tender_bidding/models/tender_model.dart';

import '../../services/firebase_service.dart';
import '../ProjectOwnner/edit_tender_screen.dart';

class ManageTendersScreen extends StatelessWidget {
  const ManageTendersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tenders'),
      ),
      body: StreamBuilder<List<Tender>>(
        stream: firebaseService.getTendersForAdmin(),
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
          return ListView.builder(
            itemCount: tenders.length,
            itemBuilder: (context, index) {
              final tender = tenders[index];
              return ListTile(
                title: Text(tender.description),
                subtitle:
                    Text('Min Bid: \$${tender.minBid.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTenderScreen(tender: tender),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await firebaseService.deleteTender(tender.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tender deleted.')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
