import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Caisse.dart';

class EditPhoneCom extends StatefulWidget {
  @override
  _EditPhoneComState createState() => _EditPhoneComState();
}

class _EditPhoneComState extends State<EditPhoneCom> {
  String? _phoneNumber;
  TextEditingController _phoneNumberController = TextEditingController();

  Future<dynamic> getPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    final response =
        await http.get(Uri.parse('http://192.168.1.26:8080/User/Phone/$id'));
    if (response.statusCode == 200) {
      final phone = jsonDecode(response.body);

      _phoneNumber = phone.toString();
      _phoneNumberController.text = _phoneNumber.toString();
      return phone;
    } else {
      throw Exception('Failed to get phone number');
    }
  }

  Future<dynamic> EditPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    final response = await http.post(
        Uri.parse('http://192.168.1.26:8080/User/editPhone/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: _phoneNumber);

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => Caisse()));
    } else {
      throw Exception('Failed to edit phone number');
    }
  }

  @override
  void initState() {
    super.initState();
    getPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => Caisse()));
            }),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone,
              size: 50.0,
              color: Colors.black,
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.0),
                  TextFormField(
                    controller: _phoneNumberController,
                    onChanged: (value) {
                      _phoneNumber = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      contentPadding: const EdgeInsets.all(16.0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                EditPhone();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.orange),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.orange),
                  ),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                    Size(150, 50)), // Ajout de la propriété minimumSize
              ),
              child: Text(
                'Edit',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
