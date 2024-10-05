import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapProvider extends ChangeNotifier {
  final Location _location = Location();
  LatLng? _userLatLng;  
  bool _mapReady = false;
  bool _isMarkerMoving = false;

  List<LatLng> _markers = [];
  List<List<LatLng>> _polygons = [];  // To store completed polygons
  List<LatLng> _currentPolygon = [];  // To store the current polygon being drawn

  LatLng? get userLatLng => _userLatLng;

  // Setter for userLatLng
  set userLatLng(LatLng? value) {
    _userLatLng = value;
    notifyListeners();
  }

  bool get mapReady => _mapReady;
  bool get isMarkerMoving => _isMarkerMoving;
  List<LatLng> get markers => _markers;
  List<List<LatLng>> get polygons => _polygons;  // Getter for saved polygons
  List<LatLng> get currentPolygon => _currentPolygon;  // Getter for the current polygon

  MapProvider() {
    _initializeLocation();
  }

  void setMapReady(bool ready) {
    _mapReady = ready;
    notifyListeners();
  }

  void addMarker(LatLng position) {
    _markers.add(position);
    notifyListeners();
  }

  // Adds a complete polygon to the list of polygons
  void savePolygon() {
    if (_currentPolygon.isNotEmpty) {
      _polygons.add(List.from(_currentPolygon));  // Save current polygon
      _currentPolygon.clear();  // Clear the current polygon for new creation
    }
    notifyListeners();
  }

  // Adds a point to the current polygon being drawn
  void addPolygonPoint(LatLng point) {
    _currentPolygon.add(point);
    notifyListeners();
  }

  // Clears all polygons (optional)
  void clearPolygons() {
    _polygons.clear();
    notifyListeners();
  }

  // Toggles between creating a new polygon or finalizing the current one
  void togglePolygonMode(bool isEnabled) {
    if (!isEnabled) {
      // If disabling, save the current polygon
      savePolygon();
    } else {
      // If enabling, clear the current polygon to start a new one
      _currentPolygon.clear();
    }
  }

  void _initializeLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData currentLocation = await _location.getLocation();
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      LatLng newLatLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      userLatLng = newLatLng;  // Using setter to update location
      _mapReady = true;
    }

    _location.onLocationChanged.listen((LocationData newLocation) {
      if (newLocation.latitude != null && newLocation.longitude != null) {
        LatLng updatedLatLng = LatLng(newLocation.latitude!, newLocation.longitude!);
        _updateUserLocation(updatedLatLng);
      }
    });
  }

  void _updateUserLocation(LatLng newLatLng) {
    _isMarkerMoving = true;
    userLatLng = newLatLng;  // Using setter to update location
    notifyListeners();

    Future.delayed(Duration(milliseconds: 300), () {
      _isMarkerMoving = false;
      notifyListeners();
    });
  }
}
