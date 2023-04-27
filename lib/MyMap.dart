import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late LatLng _selectedLatLng;

  Set<Marker> _markers = {};

  late GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('selected_location'),
        position: latLng,
      ));
      _selectedLatLng = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        onTap: _onMapTap,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(36.8065, 10.1815),
          zoom: 15,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedLatLng != null) {
            print(
                'Selected Location: ${_selectedLatLng.latitude}, ${_selectedLatLng.longitude}');
          }
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
