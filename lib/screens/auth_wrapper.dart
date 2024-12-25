import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'ProjectOwnner/contractor_dashboard.dart';
import 'admin/admin_dashboard.dart';
import 'bidder/builder_dashboard.dart';
import 'login/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return FutureBuilder<String?>(
              future: authService.getUserRole(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (roleSnapshot.hasError || !roleSnapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: Text('Failed to determine user role.')),
                  );
                }
                final role = roleSnapshot.data!;
                switch (role) {
                  case 'Admin':
                    return const AdminDashboard();
                  case 'ProjectOwner':
                    return const ProjectOwnerDashboard();
                  case 'Bidder':
                    return const BidderDashboard();
                  default:
                    return const Scaffold(
                      body: Center(child: Text('Unauthorized role.')),
                    );
                }
              },
            );
          } else {
            return const LoginScreen();
          }
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
