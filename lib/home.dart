import 'package:appcommerce/gestionpanier.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'DetailPanier.dart';

class HomePage extends StatefulWidget {
  String value;

  HomePage(this.value);
  @override
  _HomePageState createState() => _HomePageState();
}

enum Category {
  RESTAURANTS,
  MODE,
  BEAUTE,
  ELECTRONIQUES,
  ELECTROMENAGER,
  SUPERETTE,
  SPORTS,
  PATISSERIE
}

class _HomePageState extends State<HomePage> {
  double _latitude = 0.0;
  double _longitude = 0.0;
  int _cartCount = 0;
  List<String> listCart = [];
  List<CarouselSlider> _carouselSliders = [];
  @override
  void initState() {
    super.initState();
    _getStoredLocation();
    _get();
    _cart();
  }

  void _cart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    listCart = prefs.getStringList('cart') ?? [];
  }

  Future<void> _DetailArticle(BuildContext context, id) async {
    final request = await http
        .get(Uri.parse('http://192.168.1.26:8080/article/getarticle/$id'));
    final Map<String, dynamic> article = json.decode(request.body);

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => DetailPanier(article)));
  }

  Future<List<Widget>> _get() async {
    List<Widget> widgets = [];
    if (widget.value == "reg") {
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
                return GestureDetector(
                  onTap: () {
                    _DetailArticle(context, articles[index]['id']);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
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
                        'Price: ${articles[index]['prix']}',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                );
              },
            );
            _carouselSliders.add(
              CarouselSlider(
                options: CarouselOptions(
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.33, // increase to display more items
                  autoPlay: false,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: false,
                ),
                items: items,
              ),
            );
            widgets.add(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      Category.values[i].toString().split('.').last,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  _carouselSliders.last,
                ],
              ),
            );
          }
        }
      }
    } else if (widget.value == "loc") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      double? lat = prefs.getDouble('latitude');
      double? long = prefs.getDouble('longitude');
      for (var i = 0; i < Category.values.length; i++) {
        final activity = Category.values[i].toString().split('.').last;
        final response = await http.post(
            Uri.parse(
                'http://192.168.1.26:8080/article/articlesLocal/$lat/$long'),
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
                      height: 100,
                      width: 100,
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
                      'Price: ${articles[index]['prix']}',
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
                  viewportFraction: 0.33, // increase to display more items
                  autoPlay: false,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: false,
                ),
                items: items,
              ),
            );
            widgets.add(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      Category.values[i].toString().split('.').last,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  _carouselSliders.last,
                ],
              ),
            );
          }
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
    int cartCount = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade300))),
              child: ListTile(
                leading: Icon(Icons.location_city, color: Colors.red),
                title: Text('Régional',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage("reg")),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade300))),
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.blue),
                title: Text('Local',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage("loc")),
                  );
                },
              ),
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
              context, MaterialPageRoute(builder: (_) => HomePage("")));
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
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => gestionPanier()));
                  },
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${listCart.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
