import 'package:flutter/material.dart';
import 'package:testing/auth/auth_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  //get auth service
  final authService = AuthServices();

  // log out  button pressed
  void logout() async {
    await authService.signOut();
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {

    // get user email
    final currentEmail = authService.getCurrentUserEmail();
    final currentId = authService.getCurrentUserId();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: logout, 
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(currentEmail.toString()),
            Text(currentId.toString()),
          ],
        ),
      ),
    );
  }
}