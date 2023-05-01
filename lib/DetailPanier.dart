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
  List<String> numberArticle = [];
  bool _max = false;
  void _addtocart(dynamic article) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listArticles = prefs.getStringList('cart') ?? [];
    listArticles.add(jsonEncode(article));
    await prefs.setStringList('cart', listArticles);

    setState(() {
      _articleExist(article['id']);
      _counter++;
    });
  }

  void _articleExist(dynamic id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listArticles = prefs.getStringList('cart') ?? [];
    for (String element in listArticles) {
      Map<String, dynamic> article = json.decode(element);
      if (article["id"] == id.toString()) {
        _exist = true;
        break;
      } else {
        _exist = false;
      }
    }
    setState(() {});
  }

  Future<void> _numbreArticle(dynamic id, dynamic nb) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listArticles = prefs.getStringList('cart') ?? [];
    for (String element in listArticles) {
      Map<String, dynamic> article = json.decode(element);
      if (article["id"] == id.toString()) {
        numberArticle.add(element);
      }
    }
    if (numberArticle.length == int.parse(nb)) {
      _max = true;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _articleExist(widget.article['id']);
    _numbreArticle(widget.article['id'], widget.article['nbstock']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Detail Article'),
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
                          Stack(children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: MemoryImage(
                                      base64Decode(widget.image['bytes'])),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ]),
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
                                            minimumSize: Size(150, 50),
                                            fixedSize: Size(400, 60),
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 80),
                                    if (_exist)
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: _counter <= 0
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _counter--;
                                                    });
                                                  },
                                            color: _counter <= 0
                                                ? Colors.grey
                                                : null,
                                          ),
                                          SizedBox(
                                            width: 50,
                                            child: Text(
                                              '${_counter + numberArticle.length}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: _counter >=
                                                    int.parse(widget
                                                        .article['nbstock'])
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _addtocart(
                                                          widget.article);
                                                    });
                                                  },
                                            color: _max ? Colors.grey : null,
                                          ),
                                        ],
                                      ),
                                  ])),
                        ])))));
  }
}
