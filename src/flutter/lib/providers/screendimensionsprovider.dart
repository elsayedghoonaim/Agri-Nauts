import 'package:flutter/material.dart';
class ScreenDimensionsProvider with ChangeNotifier {
  double _height = 0.0;
  double _width = 0.0;

  double get height => _height;
  double get width => _width;

  void updateDimensions(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    notifyListeners();
  }
}
