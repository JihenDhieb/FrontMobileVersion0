import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late List<String> _pages = [];

  Future<void> _loadPages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    final response = await http
        .get(Uri.parse('http://192.168.42.28:8080/User/pagesByUser/$id'));
    if (response.statusCode == 200) {
      setState(() {
        _pages = response.body.split(',');
      });
    } else {
      print('failed');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pages'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pages:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return Text(_pages[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
