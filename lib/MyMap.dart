import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CreatePage.dart';
import 'listePage.dart';

class MyApp extends StatefulWidget {
  String title;
  String address;
  String phone;
  String postalCode;
  String email;
  dynamic activity;
  dynamic region;
  dynamic imageProfile;
  dynamic imageCouverture;
  dynamic longitude;
  dynamic latitude;
  MyApp(this.title, this.address, this.phone, this.postalCode, this.email,
      this.activity, this.region, this.imageProfile, this.imageCouverture);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> addPage(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    final response = await http.post(
      Uri.parse('http://192.168.1.26:8080/pages/add/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'title': widget.title,
        'address': widget.address,
        'phone': widget.phone,
        'postalCode': widget.postalCode,
        'email': widget.email,
        'activity': widget.activity,
        'region': widget.region,
        'longitude': widget.longitude,
        'latitude': widget.latitude
      }),
    );
    if (response.statusCode == 200) {
      var id1 = response.body;

      final request = http.MultipartRequest('POST',
          Uri.parse('http://192.168.1.26:8080/pages/addImagesToPage/$id1'));

      var imageProfile1 = await http.MultipartFile.fromPath(
          'imageProfile', widget.imageProfile!.path);
      var imageCouverture1 = await http.MultipartFile.fromPath(
          'imageCouverture', widget.imageCouverture!.path);

      request.files.add(imageProfile1);
      request.files.add(imageCouverture1);
      var responsee = await request.send();
      if (responsee.statusCode == 200) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyTableScreen()));
      }
    } else {
      print('Error adding page');
    }
  }

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
        backgroundColor: Colors.orange,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MyTableScreen(),
                ),
              );
            }),
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
            widget.longitude = _selectedLatLng.longitude;
            widget.latitude = _selectedLatLng.latitude;
            addPage(context);
          }
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.save),
      ),
    );
  }
}
