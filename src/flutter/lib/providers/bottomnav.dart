import 'package:flutter/material.dart';

class BottomNavBarProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void updateIndex(int newIndex) {
    _currentIndex = newIndex;
    notifyListeners(); // Notify listeners to rebuild the UI
  }
}
