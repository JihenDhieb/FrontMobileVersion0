import 'package:appcommerce/DetailPanier.dart';
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
  List<String> listArticles = [];
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
        'id': article
            .id, // access the 'id' property of the 'Article' object using dot notation
        'name': article.name,
        'quantity': 1
      };
      listArticles.add(jsonEncode(articleMap));
      _counter++;
    }

    await prefs.setStringList('cart', listArticles);

    setState(() {
      _articleExist(article
          .id); // access the 'id' property of the 'Article' object using dot notation
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              return ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = data[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: MemoryImage(base64Decode(item.image)),
                    ),
                    title: Text(item.nom),
                    subtitle: Text(item.prix),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              _removeItem(item.id);
                            });
                          },
                        ),
                        FutureBuilder<int>(
                          future: _nombreArticle(item.id),
                          builder: (BuildContext context,
                              AsyncSnapshot<int> snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                '${snapshot.data}',
                                style: TextStyle(fontSize: 18),
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
                        ),
                      ],
                    ),
                    onTap: () {
                      _DetailArticle(context, item.id);
                    },
                  );
                },
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
