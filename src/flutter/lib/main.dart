import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:nasaspaceapps/auth/signup.dart';
import 'package:nasaspaceapps/pages/first.dart'; // Import your SignUp page


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that widget binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home:FirebaseAuth.instance.currentUser ==null ? CreateEmailPage() :const First(), // Your initial page
    );
  }
}
