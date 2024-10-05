import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationExample extends StatefulWidget {
  @override
  _LocationExampleState createState() => _LocationExampleState();
}

class _LocationExampleState extends State<LocationExample> {
  loc.Location location = loc.Location();
  String _locationInfo = "Getting location...";
  String _weatherInfo = "Fetching weather...";

  @override
  void initState() {
    super.initState();
    _getLocationAndCity();
  }

  Future<void> _getLocationAndCity() async {
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    loc.LocationData _locationData;

    try {
      // Ensure the location service is enabled
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          setState(() {
            _locationInfo = "Location service disabled.";
          });
          return;
        }
      }

      // Ensure the location permission is granted
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == loc.PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != loc.PermissionStatus.granted) {
          setState(() {
            _locationInfo = "Location permission denied.";
          });
          return;
        }
      }

      // Get the user's current location
      _locationData = await location.getLocation();

      // Reverse geocoding to get the city and country
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _locationData.latitude!,
        _locationData.longitude!,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String country = place.country ?? "Unknown country";

        // Get the main city based on administrative area
        String mainCity;
        if (place.administrativeArea != null) {
          mainCity = place.administrativeArea!; // Use null assertion
          if (mainCity == "Al-Qalyubia Governorate") {
            mainCity = "Cairo"; // Convert Al-Qalyubia to Cairo
          }
        } else {
          mainCity = "Unknown city"; // Provide a default value if it's null
        }

        setState(() {
          _locationInfo = '$mainCity, $country'; // Display main city and country
        });

        // Fetch weather data for the main city
        await _fetchWeather(mainCity);
      } else {
        setState(() {
          _locationInfo = "Unable to determine location.";
        });
      }
    } catch (e) {
      setState(() {
        _locationInfo = "Error: ${e.toString()}";
      });
    }
  }

  Future<void> _fetchWeather(String city) async {
    final apiKey = '7333e13466931bda35c0937234fd49f7';
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double kelvinTemp = data['main']['temp'];
        double celsiusTemp = kelvinTemp - 273.15; // Convert to Celsius

        setState(() {
          _weatherInfo = 'Temperature in $city: ${double.parse(celsiusTemp.toStringAsFixed(1))} °C';
          print('Temperature in Celsius: $celsiusTemp');
        });
      } else {
        setState(() {
          _weatherInfo = 'Failed to fetch weather data.';
        });
      }
    } catch (e) {
      setState(() {
        _weatherInfo = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _locationInfo,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.03,
            ),
          ),
          SizedBox(height: 10),
          Text(
            _weatherInfo,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.03,
            ),
          ),
        ],
      ),
    );
  }
}
