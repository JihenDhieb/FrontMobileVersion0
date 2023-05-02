import 'package:appcommerce/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'gestionpanier.dart';

class DetailPanier extends StatefulWidget {
  final Map<String, dynamic> article;
  late Map<dynamic, dynamic> image;
  DetailPanier(this.article) {
    image = article['image'];
  }
  @override
  _DetailPanierState createState() => _DetailPanierState();
}

class _DetailPanierState extends State<DetailPanier> {
  int _counter = 0;
  bool _exist = false;
  int numberArticle = 0;
  bool _max = false;
  void _addtocart(dynamic article) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listArticles = prefs.getStringList('cart') ?? [];
    for (int i = 0; i < listArticles.length; i++) {
      Map<String, dynamic> item = json.decode(listArticles[i]);
      if (item['id'] == article['id']) {
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
      article['quantite'] = 1;
      listArticles.add(jsonEncode(article));
      _counter++;
    }

    await prefs.setStringList('cart', listArticles);

    setState(() {
      _articleExist(article['id']);
    });
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
          _counter--;
        } else {
          setState(() {
            _exist = false;
            listArticles.removeAt(i);
            _counter--;
          });
        }
        break;
      }
    }
    await prefs.setStringList('cart', listArticles);
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

  Future<void> _numbreArticle(dynamic id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listArticles = prefs.getStringList('cart') ?? [];
    int numberArticle = 0;
    for (String element in listArticles) {
      Map<String, dynamic> article = json.decode(element);
      if (article["id"] == id.toString()) {
        numberArticle = article['quantite'];

        break;
      }
    }
    setState(() {
      this.numberArticle = numberArticle;
    });
  }

  @override
  void initState() {
    super.initState();
    _articleExist(widget.article['id']);
    _numbreArticle(widget.article['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Detail Article'),
          backgroundColor: Colors.orange,
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
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: Image.memory(
                                    base64Decode(widget.image['bytes']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 16),
                                    Text(
                                      'Name: ${widget.article['nom']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Description: ${widget.article['description']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Nbstock: ${widget.article['nbstock']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Price: ${widget.article['prix']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 150),
                                    if (!_exist)
                                      Center(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _addtocart(widget.article);

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Article added to cart!'),
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.add_shopping_cart),
                                          label: Text('Add to cart'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            minimumSize: Size(150, 50),
                                            fixedSize: Size(400, 60),
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 80),
                                    if (_exist)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () {
                                              setState(() {
                                                _removeItem(
                                                    widget.article["id"]);
                                              });
                                            },
                                          ),
                                          SizedBox(
                                            width: 200,
                                            child: Text(
                                              '${_counter + numberArticle}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 24),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () {
                                              setState(() {
                                                _addtocart(widget.article);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                  ])),
                        ])))));
  }
}
