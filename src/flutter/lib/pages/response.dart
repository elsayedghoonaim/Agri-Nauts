import 'dart:io';
import 'package:flutter/material.dart';

class ResponsePage extends StatelessWidget {
  final String response;
  final File? imageFile; // Added the imageFile parameter

  ResponsePage({required this.response, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Response'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageFile != null) // Display the image if it exists
              Image.file(imageFile!),
            SizedBox(height: 20),
            Text(
              response,
              style: TextStyle(fontSize: 24,color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
