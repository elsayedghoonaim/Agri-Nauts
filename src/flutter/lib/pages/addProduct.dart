import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String _title = '';
  String _subtitle = '';
  double? _price;
  bool _isLoading = false; // Track upload status

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (_imageFile != null && _title.isNotEmpty && _subtitle.isNotEmpty && _price != null) {
      setState(() {
        _isLoading = true; // Set loading status
      });

      try {
        // Upload image to Firebase Storage
        final ref = _storage.ref().child('products/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_imageFile!);
        final imageUrl = await ref.getDownloadURL();

        // Save product data to Firestore
        await _firestore.collection('products').add({
          'title': _title,
          'subtitle': _subtitle,
          'price': _price,
          'imageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product uploaded successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Clear the fields
        setState(() {
          _imageFile = null;
          _title = '';
          _subtitle = '';
          _price = null;
        });
      } catch (e) {
        print('Error uploading product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload product: $e'),
            duration: Duration(seconds: 2),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // Reset loading status
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields and select an image.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Upload Your Product Here!')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            if (_imageFile != null) ...[
              SizedBox(height: 10),
              AspectRatio(
                aspectRatio: 1, // Maintain square aspect ratio
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ],
            SizedBox(height: 20),
            _buildTextField(
              label: 'Title',
              onChanged: (value) => _title = value,
              isError: _title.isEmpty,
            ),
            SizedBox(height: 10),
            _buildTextField(
              label: 'Subtitle',
              onChanged: (value) => _subtitle = value,
              isError: _subtitle.isEmpty,
            ),
            SizedBox(height: 10),
            _buildPriceField(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadProduct, // Disable button while loading
              child: _isLoading
                  ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : Text('Upload To Store'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _imageFile = null;
                  _title = '';
                  _subtitle = '';
                  _price = null;
                });
              },
              child: Text('Clear Fields'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required Function(String) onChanged, bool isError = false}) {
    return Card(
      elevation: 4,
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          errorText: isError ? 'This field cannot be empty' : null,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(10),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPriceField() {
    return Card(
      elevation: 4,
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Price',
          errorText: _price == null ? 'Please enter a valid price' : null,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(10),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            _price = double.tryParse(value);
          } else {
            _price = null; // Reset price if input is empty
          }
        },
      ),
    );
  }
}
