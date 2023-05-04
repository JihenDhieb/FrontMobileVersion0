import 'package:appcommerce/DetailPanier.dart';
import 'package:appcommerce/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'package:appcommerce/DetailArticle.dart';

class Article {
  final String nom;
  final String prix;
  final dynamic image;
  final String id;

  Article(
      {required this.nom,
      required this.prix,
      required this.image,
      required this.id});

  factory Article.fromJson(Map<dynamic, dynamic> json) {
    return Article(
        nom: json['nom'],
        prix: json['prix'],
        id: json['id'],
        image: json['image']['bytes']);
  }
}

Future<List<Article>> _cart() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> listArticles = prefs.getStringList('cart') ?? [];

  return listArticles
      .map((jsonString) => jsonDecode(jsonString))
      .map((json) => Article.fromJson(json))
      .toList();
}

Future<void> _DetailArticle(BuildContext context, id) async {
  final request = await http
      .get(Uri.parse('http://192.168.1.26:8080/article/getarticle/$id'));
  final Map<String, dynamic> article = json.decode(request.body);
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => DetailPanier(article)));
}

class gestionPanier extends StatefulWidget {
  @override
  _gestionPanierState createState() => _gestionPanierState();
}

class _gestionPanierState extends State<gestionPanier> {
  int _counter = 0;
  bool _exist = false;
  int numberArticle = 0;
  bool _max = false;
  double totalPrice = 0.0;
  List<String> listArticles = [];
  double _getTotalPrice(List<String> listArticles) {
    double totalPrice = 0.0;
    for (int i = 0; i < listArticles.length; i++) {
      Map<String, dynamic> item = json.decode(listArticles[i]);
      double prix = double.parse(item['prix']);
      int quantity = item['quantite'];
      totalPrice += prix * quantity;
    }
    setState(() {
      this.totalPrice = totalPrice;
    });
    return totalPrice;
  }

  void _addtocart(dynamic article) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listArticles = prefs.getStringList('cart') ?? [];
    for (int i = 0; i < listArticles.length; i++) {
      Map<String, dynamic> item = json.decode(listArticles[i]);
      if (item['id'] == article.id) {
        // access the 'id' property of the 'Article' object using dot notation
        _exist = true;
        if (item['quantite'] < int.parse(item['nbstock'])) {
          item['quantite'] = item['quantite'] + 1;
          listArticles[i] = jsonEncode(item);

          _counter++;
          break;
        }
      }
    }

    if (!_exist) {
      Map<String, dynamic> articleMap = {
        'id': article.id,
        'name': article.name,
        'quantity': 1,
        'prix': article.prix
      };
      listArticles.add(jsonEncode(articleMap));
      _counter++;
    }
    await prefs.setStringList('cart', listArticles);
    double totalPrice = _getTotalPrice(listArticles);
    await prefs.setDouble('totalPrice', totalPrice);

    setState(() {
      _articleExist(article.id);
      _getTotalPrice(listArticles);
    });
  }

  Future<void> _articleExist(dynamic id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listArticles = prefs.getStringList('cart') ?? [];
    bool exist = listArticles
        .any((element) => json.decode(element)["id"] == id.toString());
    setState(() {
      _exist = exist;
    });
  }

  Future<int> _nombreArticle(dynamic id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listArticles = prefs.getStringList('cart') ?? [];
    int nombreArticle = 0;
    for (String element in listArticles) {
      Map<String, dynamic> article = json.decode(element);
      if (article["id"] == id.toString()) {
        nombreArticle = article['quantite'];
        break;
      }
    }
    setState(() {
      this.numberArticle = nombreArticle;
      _getTotalPrice(listArticles);
    });
    return nombreArticle;
  }

  Future<void> _removeItem(dynamic id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listArticles = prefs.getStringList('cart') ?? [];
    for (int i = 0; i < listArticles.length; i++) {
      Map<String, dynamic> article = json.decode(listArticles[i]);
      if (article["id"] == id.toString()) {
        int currentQuantity = article['quantite'];
        if (currentQuantity > 1) {
          article['quantite'] = currentQuantity - 1;
          listArticles[i] = json.encode(article);
        } else {
          listArticles.removeAt(i);
        }
        break;
      }
    }
    await prefs.setStringList('cart', listArticles);
  }

  Future<void> chekUserConnect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = prefs.getString('id');
    if (id == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('My Cart'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomePage("reg")));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Action de recherche
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _cart(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            if (data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 48.0, color: Colors.grey),
                    SizedBox(height: 16.0),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = data[index];
                        return Card(
                          child: InkWell(
                            onTap: () {
                              _DetailArticle(context, item.id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: MemoryImage(
                                      base64Decode(item.image),
                                    ),
                                    radius: 30,
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.nom,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          item.prix,
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove),
                                              onPressed: () {
                                                setState(() {
                                                  _removeItem(item.id);
                                                });
                                              },
                                              tooltip: 'Remove Item',
                                              splashColor: Colors.redAccent,
                                              highlightColor:
                                                  Colors.transparent,
                                              color: Colors.grey[700],
                                              iconSize: 24.0,
                                            ),
                                            FutureBuilder<int>(
                                              future: _nombreArticle(item.id),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<int> snapshot) {
                                                if (snapshot.hasData) {
                                                  return Text(
                                                    '${snapshot.data}',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  );
                                                } else {
                                                  return CircularProgressIndicator();
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add),
                                              onPressed: () {
                                                setState(() {
                                                  _addtocart(item);
                                                });
                                              },
                                              tooltip: 'ADD Item',
                                              splashColor: Colors.redAccent,
                                              highlightColor:
                                                  Colors.transparent,
                                              color: Colors.grey[700],
                                              iconSize: 24.0,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 300.0,
                      height: 70.0,
                      child: ElevatedButton(
                        onPressed: () {
                          chekUserConnect();
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(fontSize: 18),
                          backgroundColor: Colors.orange,
                        ),
                        child: Text('Commander (Total Price: $totalPrice)'),
                      ),
                    ),
                  )
                ],
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
