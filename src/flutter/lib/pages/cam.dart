import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nasaspaceapps/pages/response.dart';
import 'package:image_picker/image_picker.dart'; // Import the image picker package

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras![0], // Use the first available camera (usually rear camera)
      ResolutionPreset.high,
    );

    await _cameraController!.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Page'),
      ),
      body: Stack(
        children: [
          // Camera preview
          if (_isCameraInitialized)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            )
          else
            Center(child: CircularProgressIndicator()),

          // Buttons overlay
          Column(
            children: [
              Spacer(), // Push buttons to the bottom
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Image picker button
                    ElevatedButton(
                      onPressed: _pickImage, // Call the method to pick an image
                      child: Text('Pick Image'),
                    ),
                    // Capture button
                    ElevatedButton(
                      onPressed: _takePicture,
                      child: Icon(Icons.camera_alt),
                    ),
                    // Upload button (only enabled when an image is captured)
                    ElevatedButton(
                      onPressed: _capturedImage != null
                          ? () async {
                              await _uploadImage(File(_capturedImage!.path), context);
                            }
                          : null,
                      child: Text('Upload Image'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _capturedImage = image;
      });
    }
  }

  // Function to capture an image
  Future<void> _takePicture() async {
    try {
      final image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
      });
      print('Picture taken: ${image.path}');
    } catch (e) {
      print('Error capturing image: $e'); // Improved error handling
    }
  }

  // Function to upload the captured image to the API and navigate to the response page
  Future<void> _uploadImage(File imageFile, BuildContext context) async {
    try {
      var uri = Uri.parse('https://flaskappproject-production.up.railway.app/predict-vegetation');
      var request = http.MultipartRequest('POST', uri);
      // Attach the file to the request
      var pic = await http.MultipartFile.fromPath('fileup', imageFile.path);
      request.files.add(pic);

      // Send the request and capture the response
      var response = await request.send();

      // Check if the response was successful
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody'); // Log the response body for debugging
        final jsonResponse = jsonDecode(responseBody);

        // Ensure jsonResponse is of the expected type
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('predicted_class')) {
          _navigateToResponsePage(context, jsonResponse['predicted_class'], imageFile); // Pass imageFile
        } else {
          _navigateToResponsePage(context, 'Missing predicted_class in response', imageFile); // Pass imageFile
        }
      } else {
        // Handle the error response
        String responseBody = await response.stream.bytesToString();
        print('Failed to upload image: $responseBody'); // Log error response
        _navigateToResponsePage(context, 'Failed to upload image: $responseBody', imageFile); // Pass imageFile
      }
    } catch (e) {
      print('Error uploading image: $e'); // Improved error handling
      _navigateToResponsePage(context, 'Error uploading image: $e', imageFile); // Pass imageFile
    }
  }

  // Navigate to the ResponsePage
  void _navigateToResponsePage(BuildContext context, String response, File? imageFile) {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResponsePage(response: response, imageFile: imageFile), // Pass imageFile
        ),
      );
    }
  }
}
