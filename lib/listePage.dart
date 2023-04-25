import 'package:appcommerce/compte.dart';
import 'package:appcommerce/detailPage.dart';
import 'package:appcommerce/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CreatePage.dart';

class Page {
  final String title;
  final String address;

  final String id;

  Page({required this.title, required this.address, required this.id});

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(title: json['title'], address: json['address'], id: json['id']);
  }
}

Future<List<Page>> getData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? id = prefs.getString('id');
  final response = await http
      .get(Uri.parse('http://192.168.1.26:8080/User/pagesByUser/$id'));
  if (response.statusCode == 200) {
    final jsonList = json.decode(response.body) as List<dynamic>;
    return jsonList.map((json) => Page.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

Future<void> _openPage(id, BuildContext context) async {
  final request = (await http.get(
      Uri.parse('http://192.168.1.26:8080/article/findArticlesByPage/$id')));

  final List<dynamic> articles = json.decode(request.body);
  final pageResponse =
      await http.get(Uri.parse('http://192.168.1.26:8080/pages/getpage/$id'));
  final Map<dynamic, dynamic> pageData = json.decode(pageResponse.body);

  Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => detailPage(pageData, articles)));
}

class MyTableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pages'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomePage()));
          },
        ),
      ),
      body: FutureBuilder<List<Page>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;

            return DataTable(
              columns: [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Adress')),
              ],
              rows: data
                  .map((item) => DataRow(
                        cells: [
                          DataCell(Text(item.title)),
                          DataCell(Text(item.address)),
                        ],
                        onSelectChanged: (selected) {
                          if (selected != null && selected) {
                            _openPage(item.id, context);
                          }
                        },
                      ))
                  .toList(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => ProfileForm()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
