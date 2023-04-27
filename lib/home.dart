import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

enum Category {
  Mode,
  BEAUTE,
  ELECTRONIQUES,
}

class _HomePageState extends State<HomePage> {
  double _latitude = 0.0;
  double _longitude = 0.0;
  List<CarouselSlider> _carouselSliders = [];
  @override
  void initState() {
    super.initState();
    _getStoredLocation();
    _get();
  }

  Future<List<Widget>> _get() async {
    // Retourne une liste de Widgets plutôt qu'un Future
    List<Widget> widgets = [];
    for (var i = 0; i < Category.values.length; i++) {
      final activity = Category.values[i].toString().split('.').last;

      final response = await http.post(
          Uri.parse('http://192.168.1.26:8080/article/articlesByCategory'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(activity));

      if (response.statusCode == 200) {
        final articles = jsonDecode(response.body);
        if (articles.length != 0) {
          List<Widget> items = List.generate(
            articles.length,
            (index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 90,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(
                          base64Decode(
                            articles[index]['image']['bytes'],
                          ),
                        ),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Name: ${articles[index]['nom']}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 6.0),
                  Text(
                    'Stock: ${articles[index]['nbstock']}',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ],
              );
            },
          );
          _carouselSliders.add(
            CarouselSlider(
              options: CarouselOptions(
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
                autoPlay: false,
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
              ),
              items: items,
            ),
          );

          widgets.add(
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    Category.values[i].toString().split('.').last,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                _carouselSliders.last,
              ],
            ),
          );
        }
      }
    }
    return widgets;
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text('Régional'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              title: Text('local'),
              onTap: () {
                // Ajoutez votre logique ici
              },
            ),
          ],
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [
              PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Recherche',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            // TODO: Implement search functionality
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<Widget>>(
                future: _get(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Widget>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return SingleChildScrollView(
                        child: Column(
                          children: snapshot.data!,
                        ),
                      );
                    } else {
                      return Center(
                        child: Text('No data found'),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
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
    );
  }
}
