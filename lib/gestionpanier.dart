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

Future<void> _removeItem(dynamic id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> listArticles = prefs.getStringList('cart') ?? [];
  List<String> toRemove = [];
  for (String element in listArticles) {
    Map<String, dynamic> article = json.decode(element);
    if (article["id"] == id.toString()) {
      toRemove.add(element);
    }
  }
  listArticles.removeWhere((element) => toRemove.contains(element));
  await prefs.setStringList('cart', listArticles);
}

class gestionPanier extends StatefulWidget {
  @override
  _gestionPanierState createState() => _gestionPanierState();
}

class _gestionPanierState extends State<gestionPanier> {
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
            return ListView.separated(
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final item = data[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: MemoryImage(base64Decode(item.image)),
                  ),
                  title: Text(item.nom),
                  subtitle: Text(item.prix),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _removeItem(item.id);
                      });
                    },
                  ),
                  onTap: () {
                    _DetailArticle(context, item.id);
                  },
                );
              },
            );
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
