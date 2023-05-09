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
  num nb = 0;
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
    List<String> listCart = prefs.getStringList('cart') ?? [];
    for (int i = 0; i < listCart.length; i++) {
      Map<String, dynamic> item = json.decode(listCart[i]);
      nb += item['quantite'];
    }
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

  bool isLocalSelected = false;

  @override
  Widget build(BuildContext context) {
    int cartCount = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Colors.orange,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: ListTile(
                leading: Icon(Icons.location_city, color: Colors.red),
                title: Text(
                  'Régional',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.blue),
                title: Text(
                  'Local',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  setState(() {
                    isLocalSelected = true;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage("loc")),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            // Add buttons for each item in Category enum
            ...Category.values.map((category) {
              if (isLocalSelected) {
                if (category == Category.RESTAURANTS ||
                    category == Category.PATISSERIE ||
                    category == Category.SUPERETTE) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.category),
                      title: Text(
                        category.toString().split('.').last,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // Action when the specific category is tapped
                      },
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              } else {
                // Ajoutez des catégories restantes lorsque Local n'est pas sélectionné
                if (category != Category.RESTAURANTS &&
                    category != Category.PATISSERIE &&
                    category != Category.SUPERETTE) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.category),
                      title: Text(
                        category.toString().split('.').last,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // Action when the specific category is tapped
                      },
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              }
            }).toList(),
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
                        margin: EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: Colors.grey[200],
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search for items',
                                    border: InputBorder.none,
                                    icon: Icon(Icons.search),
                                  ),
                                  onChanged: (value) {
                                    // TODO: Implement search functionality
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // TODO: Implement clear functionality
                                },
                                child: Icon(Icons.clear),
                              ),
                            ),
                          ],
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
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomAppBar(
          color: Colors.white,
          child: Container(
            height: 70,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.account_circle, color: Colors.grey),
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => LoginPage()));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.local_offer, color: Colors.grey),
                  onPressed: () {},
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.grey),
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
                          '${nb}',
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
                  icon: Icon(Icons.list, color: Colors.grey),
                  onPressed: () {
                    // Action when the icon is pressed
                  },
                ),
              ],
            ),
          ),
          elevation: 0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.home, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomePage("")));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
