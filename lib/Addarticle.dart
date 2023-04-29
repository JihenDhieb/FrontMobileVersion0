import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detailPage.dart';
import 'listePage.dart';

class Addarticle extends StatelessWidget {
  final Map<dynamic, dynamic> pageData;

  Addarticle(this.pageData);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nbstockController = TextEditingController();
  File? image;

  Future<void> _pickImageGallery() async {
    try {
      final imageFile =
          await ImagePicker().getImage(source: ImageSource.gallery);
      if (imageFile != null) {
        image = File(imageFile.path);
      }
    } catch (e) {
      print('Error selecting profile image: $e');
    }
  }

  Future<void> _pickImagecamera() async {
    try {
      final imageFile =
          await ImagePicker().getImage(source: ImageSource.camera);
      if (imageFile != null) {
        image = File(imageFile.path);
      }
    } catch (e) {
      print('Error selecting profile image: $e');
    }
  }

  Future<void> addArticle(BuildContext context) async {
    final String nom = _nomController.text;
    final String prix = _prixController.text;
    final String nbstock = _nbstockController.text;
    final String description = _descriptionController.text;

    final String id = pageData['id'];

    final response = await http.post(
      Uri.parse('http://192.168.1.26:8080/article/addArticle/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'nom': nom,
        'description': description,
        'prix': prix,
        'nbstock': nbstock
      }),
    );

    if (response.statusCode == 200) {
      var id1 = response.body;

      final request = http.MultipartRequest('POST',
          Uri.parse('http://192.168.1.26:8080/article/addImageToArticle/$id1'));
      var image1 = await http.MultipartFile.fromPath('image', image!.path);
      request.files.add(image1);

      var responsee = await request.send();
      if (responsee.statusCode == 200) {
        final request = (await http.get(Uri.parse(
            'http://192.168.1.26:8080/article/findArticlesByPage/$id')));

        final List<dynamic> articles = json.decode(request.body);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => detailPage(pageData, articles)));
      }
    } else {
      print('Error adding Article');
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Are you sure you want to save these Article?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              addArticle(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _formKey,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Article',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _prixController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your Price';
                    }
                    if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                      return 'Please enter a valid Price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _nbstockController,
                  decoration: InputDecoration(
                    labelText: 'Nbstock',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your Nbstock';
                    }
                    if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                      return 'Please enter a valid NbStock';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                Stack(
                  children: [
                    SizedBox(width: 20.0),
                    Text(
                      'Photo Article',
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () {
                        bool someCondition = false;
                        if (someCondition == false) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Choose an option'),
                                  content: Text(
                                      'Do you want to pick an image from camera or gallery?'),
                                  actions: [
                                    ElevatedButton(
                                      child: Text('Camera'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _pickImagecamera();
                                      },
                                    ),
                                    ElevatedButton(
                                      child: Text('Gallery'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _pickImageGallery();
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      })
                ]),
                ElevatedButton(
                  onPressed: () => _showConfirmationDialog(context),
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ));
  }
}
