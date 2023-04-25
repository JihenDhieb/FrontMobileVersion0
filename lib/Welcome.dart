import 'package:flutter/material.dart';
import 'home.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  Location _location = Location();
  late SharedPreferences _prefs;
  LocationData? _currentLocation;
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      final double? latitude = _prefs.getDouble('latitude');
      final double? longitude = _prefs.getDouble('longitude');
      if (latitude != null && longitude != null) {
        _currentLocation = LocationData.fromMap(
            {'latitude': latitude, 'longitude': longitude});
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    });
  }

  Future<void> _getLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      await _getLocation();
      return;
    }
    if (status.isDenied) {
      var result = await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text("Location Permission Required"),
                content:
                    Text("Please grant permission to access your location."),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  ElevatedButton(
                    child: Text("OK"),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ));
      if (result != null && result) {
        status = await Permission.locationWhenInUse.request();
        if (status.isGranted) {
          await _getLocation();
        }
      }
    }
  }

  Future<void> _getLocation() async {
    try {
      _currentLocation = await _location.getLocation();
      print(
          'Latitude: ${_currentLocation?.latitude}, Longitude: ${_currentLocation?.longitude}');

      // Store the latitude and longitude in shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', _currentLocation?.latitude ?? 0.0);
      await prefs.setDouble('longitude', _currentLocation?.longitude ?? 0.0);
    } catch (e) {
      print("Error: ${e.toString()}");
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color.fromARGB(248, 24, 51, 186),
                  Color.fromARGB(255, 111, 29, 165),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp)),
        child: Center(
          child: Stack(
            children: [
              Positioned(
                bottom: 350,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 100,
                    ),
                    const Text(
                      'Online Shopping ',
                      style: TextStyle(
                        fontSize: 29,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: ElevatedButton(
                  onPressed: _getLocationPermission,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on),
                      SizedBox(width: 5.0),
                      Text('Get current location'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
