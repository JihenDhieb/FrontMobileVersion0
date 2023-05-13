import 'dart:convert';
import 'package:appcommerce/EditPhoneCom.dart';
import 'package:http/http.dart' as http;
import 'package:appcommerce/gestionpanier.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'AddCommande.dart';

class ArticleCaisse {
  String idArticle;
  int qnt;

  ArticleCaisse(this.idArticle, this.qnt);
  Map<String, dynamic> toJson() {
    return {
      'idArticle': idArticle,
      'qnt': qnt,
    };
  }
}

class Caisse extends StatefulWidget {
  @override
  _CaisseState createState() => _CaisseState();
}

class _CaisseState extends State<Caisse> {
  String? _phoneNumber;
  String frais = "2.0 Dt";
  double resultat1 = 0.0;
  String description = '';
  int quantity = 0;
  String namePage = "";
  String idPage = "";
  String phone = "";
  String address = "";
  String streetAddress = "";
  double totalPrice = 0.0;
  String id = "";
  int numberArticle = 0;
  List<ArticleCaisse> articles = [];

  Future<void> addCommande() async {
    setState(() {
      _cart();
    });
    final response = await http.post(
      Uri.parse('http://192.168.1.26:8080/caisse/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'idSender': id,
        'address': address,
        'streetAddress': streetAddress,
        'phone': phone,
        'selectedTime': _time.format(context),
        'description': description,
        'idPage': idPage,
        'subTotal': totalPrice,
        'frais': frais,
        'totalPrice': resultat1,
        'articles': articles,
      }),
    );
    if (response.statusCode == 200) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => AddCommande()));
    }
  }

  Future<List<Article>> _cart() async {
    double total = 0.0;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listArticles = prefs.getStringList('cart') ?? [];
    for (int i = 0; i < listArticles.length; i++) {
      Map<dynamic, dynamic> item = json.decode(listArticles[i]);
      Map<dynamic, dynamic> page = item['page'];
      quantity = item['quantite'];
      double prix = double.parse(item['prix']);
      total += prix * quantity;
      var article = ArticleCaisse(item['id'], item['quantite']);
      articles.add(article);

      setState(() {
        idPage = page['id'];
        namePage = page['title'];
        phone = page['phone'];
        address = page['address'];
        totalPrice = total;
        resultat();
      });
    }
    return listArticles
        .map((jsonString) => jsonDecode(jsonString))
        .map((json) => Article.fromJson(json))
        .toList();
  }

  late Future<List<Article>> _cartFuture;
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

    return nombreArticle;
  }

  Future<dynamic> getPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id')!;
    final response =
        await http.get(Uri.parse('http://192.168.1.26:8080/User/Phone/$id'));
    if (response.statusCode == 200) {
      final phone = jsonDecode(response.body);
      return phone;
    } else {
      throw Exception('Failed to get phone number');
    }
  }

  Future<void> _loadPhoneNumber() async {
    final phone = await getPhoneNumber();

    setState(() {
      _phoneNumber = phone.toString();
    });
  }

  void resultat() {
    resultat1 = totalPrice + 2.000;
  }

  TimeOfDay _time = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
    _cartFuture = _cart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => gestionPanier()));
            },
          ),
          title: Text('Checkout'),
          backgroundColor: Colors.orange,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Client Information :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Address',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      address = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your Region',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16.0),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Street Address',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      streetAddress = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your street address',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16.0),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                if (_phoneNumber != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Phone number: $_phoneNumber',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => EditPhoneCom()));
                          },
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16.0),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text('Choose Time'),
                ),
                Text('Selected Time: ${_time.format(context)}'),
                SizedBox(height: 16.0),
                Text(
                  'Vendor Information :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Name Vendor: $namePage',
                ),
                SizedBox(height: 16.0),
                Text(
                  'Phone Vendor: $phone',
                ),
                SizedBox(height: 16.0),
                Text(
                  'Address Vendor: $address',
                ),
                SizedBox(height: 16.0),
                Text(
                  'Products :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                FutureBuilder<List<Article>>(
                  future: _cartFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data!;
                      return Column(
                        children: [
                          SizedBox(height: 16.0),
                          Column(
                            children: data.map((item) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                  color: Colors.red,
                                                ),
                                              ),
                                              SizedBox(height: 8.0),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  FutureBuilder<int>(
                                                    future:
                                                        _nombreArticle(item.id),
                                                    builder:
                                                        (BuildContext context,
                                                            AsyncSnapshot<int>
                                                                snapshot) {
                                                      if (snapshot.hasData) {
                                                        return Text(
                                                          'Quantity: ${snapshot.data}',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                        );
                                                      } else {
                                                        return CircularProgressIndicator();
                                                      }
                                                    },
                                                  ),
                                                  Text(
                                                    'Price: ${item.prix} Dt',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                ],
                              );
                            }).toList(),
                          ),
                          // Display the phone number here
                        ],
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Description(optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      description = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your description',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'SubTotal: $totalPrice Dt',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Shipping fees: ${frais} ',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Price: ${resultat1}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      addCommande();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                    ),
                    child: Text('Passer commande'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
