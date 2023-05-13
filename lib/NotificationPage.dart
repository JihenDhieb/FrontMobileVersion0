import 'package:appcommerce/Caisse.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  final String idCaisse;

  NotificationPage({required this.idCaisse});

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  late Map<String, dynamic> CaisseData = {};
  late List<dynamic> articlesCaisse = [];
  @override
  void initState() {
    super.initState();
    _openNotification(context);
  }

  Future<void> _openNotification(BuildContext context) async {
    final String idCaisse1 = widget.idCaisse;
    final request = await http
        .get(Uri.parse('http://192.168.1.26:8080/caisse/getCaisse/$idCaisse1'));

    if (!mounted) {
      return; // Check if the widget is still mounted before updating the state
    }

    if (request.statusCode == 200) {
      setState(() {
        CaisseData = json.decode(request.body);
        _getArticles(CaisseData["articles"], context);
      });
    }
  }

  Future<void> _getArticles(
      List<dynamic> articles, BuildContext context) async {
    if (!mounted) {
      return; // Check if the widget is still mounted before performing any operations
    }
    final response = await http.post(
      Uri.parse('http://192.168.1.26:8080/caisse/getCaisseArticles'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(articles),
    );
    if (response.statusCode == 200) {
      setState(() {
        articlesCaisse = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Notification'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage("reg")),
              );
            },
          ),
          backgroundColor: Colors.orange,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Information Client',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Address: ${CaisseData['address']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Street Address: ${CaisseData['streetAddress']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Phone: ${CaisseData['phone']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Selected Time: ${CaisseData['selectedTime']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Description: ${CaisseData['description']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Subtotal: ${CaisseData['subTotal']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Frais: ${CaisseData['frais']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Total Price: ${CaisseData['totalPrice']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Products',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: articlesCaisse.length,
                  itemBuilder: (context, index) {
                    final article = articlesCaisse[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(
                                base64Decode(article['image']['bytes']),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: 100,
                          height: 100,
                        ),
                        Text(
                          'Quantity: ${article['qnt']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Name: ${article['nom']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Price: ${article['prix']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ), // Adds space between the articles
                      ],
                    );
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Existing code for other texts and products

                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Handle accept button press
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors
                                .orange, // Sets the button color to orange
                            textStyle:
                                TextStyle(fontSize: 20), // Sets the font size
                          ),
                          child: Text('Accept'),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Handle cancel button press
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors
                                .orange, // Sets the button color to orange
                            textStyle:
                                TextStyle(fontSize: 20), // Sets the font size
                          ),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
