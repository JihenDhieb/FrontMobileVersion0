import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:appcommerce/gestionpanier.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Caisse extends StatefulWidget {
  @override
  _CaisseState createState() => _CaisseState();
}

class _CaisseState extends State<Caisse> {
  String? _phoneNumber;
  String frais = "2.0 Dt";
  double resultat1 = 0.0;
  String description = '';
  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
    _getTotalPrice();
  }

  Future<List<Article>> _cart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listArticles = prefs.getStringList('cart') ?? [];

    return listArticles
        .map((jsonString) => jsonDecode(jsonString))
        .map((json) => Article.fromJson(json))
        .toList();
  }

  Future<dynamic> getPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
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
    print(phone);
    setState(() {
      _phoneNumber = phone.toString();
    });
  }

  double totalPrice = 0.0;

  Future<double> _getTotalPrice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listArticles = prefs.getStringList('cart') ?? [];
    for (int i = 0; i < listArticles.length; i++) {
      Map<String, dynamic> item = json.decode(listArticles[i]);
      double prix = double.parse(item['prix']);
      int quantity = item['quantite'];
      totalPrice += prix * quantity;
    }
    resultat();
    return totalPrice;
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
        body: SizedBox(
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: FutureBuilder<List<Article>>(
                      future: _cart(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final data = snapshot.data!;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "Products",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Price : ${item.prix} Dt',
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
                  ),
                ),
                if (_phoneNumber != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Phone number: $_phoneNumber',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text('Choisir l\'heure'),
                ),
                Text('Heure choisie : ${_time.format(context)}'),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            description = value;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter your street address',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Description (optional)',
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
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.note),
                            ),
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  description = value;
                                },
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: 'Add a description (optional)',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                      // Action when the "Passer commande" button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                    ),
                    child: Text('Passer commande'),
                  ),
                ),
              ],
            )));
  }
}
