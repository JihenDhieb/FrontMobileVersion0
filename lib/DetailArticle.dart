import 'package:appcommerce/detailPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'EditArticle.dart';
import 'listePage.dart';

class DetailArticle extends StatelessWidget {
  final dynamic article;
  PickedFile? imageEdit;

  DetailArticle(this.article) {}
  Future<void> _openPage(BuildContext context) async {
    final id = this.article['page']['id'];
    print(id);
    final request = (await http.get(
        Uri.parse('http://192.168.1.26:8080/article/findArticlesByPage/$id')));

    final List<dynamic> articles = json.decode(request.body);
    final pageResponse =
        await http.get(Uri.parse('http://192.168.1.26:8080/pages/getpage/$id'));
    final Map<dynamic, dynamic> pageData = json.decode(pageResponse.body);

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => detailPage(pageData, articles)));
  }

  void _submitFormDelete(BuildContext context) async {
    final String id = this.article['id'];

    final request = (await http
        .get(Uri.parse('http://192.168.1.26:8080/article/deleteArticle/$id')));

    if (request.statusCode == 200) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => MyTableScreen()));
    }
  }

  void _submitForm() async {
    final String id = this.article['id'];

    final request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.1.26:8080/article/editimage/$id'));

    var image = await http.MultipartFile.fromPath('image', imageEdit!.path);

    request.files.add(image);

    var responsee = await request.send();
    if (responsee.statusCode == 200) {
      print('changed');
    }
  }

  void _showConfirmationDialogEdit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Are you sure you want to save these changes?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _submitForm();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialogDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Are you sure you want to delete  this article?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _submitFormDelete(context);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _pickImageCamera() async {
      imageEdit = await ImagePicker().getImage(source: ImageSource.camera);
      if (imageEdit != null) {
        _showConfirmationDialogEdit(context);
      }
    }

    Future<void> _pickImageGallery() async {
      imageEdit = await ImagePicker().getImage(source: ImageSource.gallery);

      if (imageEdit != null) {
        _showConfirmationDialogEdit(context);
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Detail Article'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _openPage(context);
              }),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showConfirmationDialogDelete(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditArticle(article),
                  ),
                );
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
                                  image: MemoryImage(base64Decode(
                                      this.article['image']['bytes'])),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
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
                                                  _pickImageCamera();
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
                          SizedBox(height: 8),
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 16),
                                    Text(
                                      'Name: ${article['nom']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Description: ${article['description']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Nbstock: ${article['nbstock']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Price: ${article['prix']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ])),
                        ])))));
  }
}
