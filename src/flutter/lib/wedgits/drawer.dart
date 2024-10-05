import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nasaspaceapps/pages/air.dart';
import 'package:nasaspaceapps/pages/cam.dart';
import 'package:nasaspaceapps/pages/drought.dart';
import 'package:nasaspaceapps/pages/soil.dart';
import 'package:nasaspaceapps/providers/imageprovider.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          
          SizedBox(height: 8.0),
      
          
          // Options
          ListTile(
            title: Text('Drought'),
            onTap: () {
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => Droughtchart()),
);
            },
          ),
          ListTile(
            title: Text('Soil Data Prediction'),
            onTap: () {
              Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => Soilchart ()),
);
            },
          ),
          ListTile(
            title: Text('Air Quality Prediction'),
            onTap: () {
              Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AirQuality ()),
);
            },
          ),
          
        ],
      ),
    );
  }
}
