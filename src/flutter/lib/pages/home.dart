import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nasaspaceapps/providers/imageprovider.dart';
import 'package:nasaspaceapps/providers/map.dart';
import 'package:nasaspaceapps/wedgits/drawer.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MapController _mapController = MapController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  DateTime? _selectedDate;

  bool _isDrawingPolygon = false; // Track polygon drawing state

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MapProvider()),
        ChangeNotifierProvider(create: (context) => ImageProviderModel()),
      ],
      child: Consumer<MapProvider>(
        builder: (context, mapProvider, child) {
          if (mapProvider.userLatLng == null) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          return Scaffold(
            drawer: Drawer(
              child: DrawerPage(),
            ),
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.green,
              title: Text("AGRI-NUTS", style: TextStyle(color: Colors.green)),
            ),
            body: Container(
              color: Colors.green,
              child: Column(
                children: [
                  Text(
                    "Explore",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenwidth * 0.08,
                    ),
                  ),
                  Text(
                    "Your Map",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenwidth * 0.08,
                    ),
                  ),
                  Text(
                    "Please Enter Your Location",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 217, 217, 217),
                      fontSize: screenwidth * 0.04,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _latitudeController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Latitude",
                                  labelStyle: TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: screenwidth * 0.04),
                            Expanded(
                              child: TextField(
                                controller: _longitudeController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Longitude",
                                  labelStyle: TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2.0),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.white),
                              onPressed: () {
                                _moveCameraToCoordinates(context);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: screenheight * 0.01),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                          onPressed: () => _pickDate(context),
                          child: Text(
                            'Pick a Date',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        Text(
                          "Selected Date: ${_selectedDate != null ? "${_selectedDate!.toLocal()}".split(' ')[0] : 'No date selected'}",
                        ),
                        // Radio button for drawing polygon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Draw Polygon',
                              style: TextStyle(color: Colors.white),
                            ),
                            Switch(
                              value: _isDrawingPolygon,
                              onChanged: (value) {
                                setState(() {
                                  _isDrawingPolygon = value;
                                  mapProvider.togglePolygonMode(value); // Toggle polygon drawing mode
                                });
                              },
                              activeColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: mapProvider.userLatLng!,
                        initialZoom: 20.0,
                        onMapReady: () {
                          mapProvider.setMapReady(true);
                        },
                        onTap: (tapPosition, latLng) {
                          if (_isDrawingPolygon) {
                            mapProvider.addPolygonPoint(latLng); // Add polygon points
                          }
                          mapProvider.addMarker(latLng); // Add markers
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            if (mapProvider.userLatLng != null)
                              Marker(
                                point: mapProvider.userLatLng!,
                                width: screenwidth * 0.01,
                                height: screenheight * 0.01,
                                child: AnimatedContainer(
                                  duration: Duration(
                                      milliseconds:
                                          mapProvider.isMarkerMoving ? 300 : 0),
                                  child: Icon(Icons.my_location,
                                      color: Colors.blue, size: 20),
                                ),
                              ),
                            ...mapProvider.markers.map((position) {
                              return Marker(
                                point: position,
                                width: 40.0,
                                height: 40.0,
                                child:
                                    Icon(Icons.location_on, color: Colors.red),
                              );
                            }).toList(),
                          ],
                        ),
                        if (mapProvider.polygons.isNotEmpty ||
                            mapProvider.currentPolygon.isNotEmpty)
                          PolygonLayer(
                            polygons: [
                              ...mapProvider.polygons.map((polygonPoints) {
                                return Polygon(
                                  points: polygonPoints,
                                  color: Colors.green.withOpacity(0.3),
                                  borderStrokeWidth: 3,
                                  borderColor: Colors.green,
                                );
                              }).toList(),
                              if (_isDrawingPolygon && mapProvider.currentPolygon.isNotEmpty)
                                Polygon(
                                  points: mapProvider.currentPolygon,
                                  color: Colors.blue.withOpacity(0.3),
                                  borderStrokeWidth: 3,
                                  borderColor: Colors.blue,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                _moveCameraToUserLocation(context);
              },
              child: Icon(Icons.my_location, color: Colors.green),
            ),
          );
        },
      ),
    );
  }

  void _moveCameraToCoordinates(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final double? lat = double.tryParse(_latitudeController.text);
    final double? lng = double.tryParse(_longitudeController.text);

    if (lat != null && lng != null) {
      final newLatLng = LatLng(lat, lng);
      _mapController.move(newLatLng, 15.0);
      mapProvider.userLatLng = newLatLng;
      mapProvider.addMarker(newLatLng);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid Latitude or Longitude values!')),
      );
    }
  }

  void _moveCameraToUserLocation(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    if (mapProvider.userLatLng != null) {
      _mapController.move(mapProvider.userLatLng!, 15.0);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        print('Picked date: $_selectedDate');
      });
    }
  }
}
