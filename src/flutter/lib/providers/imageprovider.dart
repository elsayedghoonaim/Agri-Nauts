import 'package:flutter/material.dart';
import 'dart:io';

class ImageProviderModel with ChangeNotifier {
  File? _selectedImage;

  File? get selectedImage => _selectedImage;

  void setImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }
}
