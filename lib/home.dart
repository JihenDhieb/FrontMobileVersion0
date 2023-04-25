import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _getStoredLocation();
  }

  Future<void> _getStoredLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _latitude = prefs.getDouble('latitude') ?? 0.0;
      _longitude = prefs.getDouble('longitude') ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomePage()));
        },
        child: Icon(
          Icons.home,
          color: Colors.white,
          size: 50,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.account_circle,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.local_offer,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Latitude: $_latitude',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Text(
              'Longitude: $_longitude',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
