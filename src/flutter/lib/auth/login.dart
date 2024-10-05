import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nasaspaceapps/pages/first.dart';

class Login extends StatelessWidget {
  TextEditingController Username = TextEditingController();
  TextEditingController Email = TextEditingController(); 
  TextEditingController Password = TextEditingController();

  Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/2.png'), // Change to your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40), // Spacing from the top
              Text(
                'LOGIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // Email Input
              TextField(
                controller: Email,
                cursorColor: Colors.green,
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFFA5D9BA), // Background color of the TextField
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.transparent), // Rounded corners
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent), // Border color when focused
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Password Input
              TextField(
                controller: Password,
                obscureText: true,
                cursorColor: Colors.green,
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFFA5D9BA), // Background color of the TextField
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.transparent), // Rounded corners
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent), // Border color when focused
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: () async {
                  try {
                    final credential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                      email: Email.text,
                      password: Password.text,
                    );

                    // Check if the user's email is verified
                    if (credential.user != null && !credential.user!.emailVerified) {
                      // If not verified, send a SnackBar message and sign out
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please verify your email before logging in.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      await FirebaseAuth.instance.signOut();
                      return;
                    }

                    // Navigate to home page if email is verified
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => First()),
                      (Route<dynamic> route) => false, // This will remove all previous routes
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Login successful!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    print("Login successful: ${credential.user?.email}");
                  } on FirebaseAuthException catch (e) {
                    String message = 'An error occurred.';
                    if (e.code == 'user-not-found') {
                      message = 'No user found for that email.';
                    } else if (e.code == 'wrong-password') {
                      message = 'Wrong password provided for that user.';
                    } else if (e.code == 'user-disabled') {
                      message = 'User account is disabled. Please verify.';
                    } else if (e.code == 'invalid-email') {
                      message = 'Invalid email address.';
                    }

                    // Show error SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: Colors.red,
                      ),
                    );
                    print("Login error: ${e.message}");
                  }
                },
                child: Text('LOGIN'),
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                  backgroundColor: Colors.transparent, // Background color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button padding
                ),
              ),
              SizedBox(height: 20),

              // Optionally add a link to create an account or reset password here
            ],
          ),
        ),
      ),
    );
  }
}
