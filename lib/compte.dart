import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'EditUser.dart';
import 'LoginPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CreatePage.dart';
import 'listePage.dart';

class Compte extends StatelessWidget {
  final Map<String, dynamic> userData;

  Compte(this.userData);
  void _havePage(BuildContext context) {
    print(userData['pages'].length);
    if (userData['pages'].length != 0) {
      print('true');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => MyTableScreen()));
    } else {
      print('false');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => ProfileForm()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compte'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomePage()));
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 50),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditUser(userData: userData),
                      ),
                    );
                  },
                  child: Text('Edit'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _havePage(context);
                  },
                  child: Text('Create'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Partner'),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'FirstName :${userData['firstName']}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'LastName :${userData['lastName']}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'phone: ${userData['phone']}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Email :${userData['email']}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
