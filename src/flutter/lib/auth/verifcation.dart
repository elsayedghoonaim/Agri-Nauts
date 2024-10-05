import 'package:flutter/material.dart';
import 'package:nasaspaceapps/auth/login.dart'; // Import your login page

class Verifcation extends StatelessWidget {
  const Verifcation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Email verification sent",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20), // Spacing between text and button
            ElevatedButton(
              onPressed: () {
                // Navigate to the login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()), // Replace with your login page
                );
              },
              child: Text("LOGIN"),
            ),
          ],
        ),
      ),
    );
  }
}
