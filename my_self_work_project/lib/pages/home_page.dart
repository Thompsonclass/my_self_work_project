import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/sign-in');
            },
          )
        ],
      ),
      body: Center(
        child: user == null
            ? const Text('No user logged in')
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome, ${user.email}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            const Text(
              'You are now logged in!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
