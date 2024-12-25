import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/login/login_screen.dart';
import '../services/auth_service.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    void logout() async {
      try {
        await authService.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log out: $e')),
        );
      }
    }

    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: logout,
      tooltip: 'Logout',
    );
  }
}
