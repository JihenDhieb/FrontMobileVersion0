import 'package:appcommerce/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'listePage.dart';
import 'dart:convert';
import 'EditPage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class detailPage extends StatelessWidget {
  PickedFile? imageEdit;
  final Map<dynamic, dynamic> pageData;
  late Map<dynamic, dynamic> imageProfile;
  late Map<dynamic, dynamic> imageCouv;
  detailPage(this.pageData) {
    imageProfile = pageData['imageProfile'];
    imageCouv = pageData['imageCouverture'];
  }
  void _submitFormProf() async {
    final String id = pageData['id'];

    final request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.1.26:8080/pages/editProfile/$id'));

    var imageProf =
        await http.MultipartFile.fromPath('imageProfile', imageEdit!.path);

    request.files.add(imageProf);

    var responsee = await request.send();
    if (responsee.statusCode == 200) {
      print('changed');
    }
  }

  void _submitFormCouv() async {
    final String id = pageData['id'];

    final request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.1.26:8080/pages/editCouverture/$id'));

    var imageCouv1 =
        await http.MultipartFile.fromPath('imageCouverture', imageEdit!.path);

    request.files.add(imageCouv1);

    var responsee = await request.send();
    if (responsee.statusCode == 200) {
      print('changed');
    }
  }

  void _showConfirmationDialogProf(BuildContext context) {
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
              _submitFormProf();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialogCouv(BuildContext context) {
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
              _submitFormCouv();
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
    Future<void> _pickImageCouvCamera() async {
      imageEdit = await ImagePicker().getImage(source: ImageSource.camera);
      if (imageEdit != null) {
        _showConfirmationDialogCouv(context);
      }
    }

    Future<void> _pickImageCouvGallery() async {
      imageEdit = await ImagePicker().getImage(source: ImageSource.gallery);

      if (imageEdit != null) {
        _showConfirmationDialogCouv(context);
      }
    }

    Future<void> _pickImageProfCamera() async {
      imageEdit = await ImagePicker().getImage(source: ImageSource.camera);
      if (imageEdit != null) {
        _showConfirmationDialogProf(context);
      }
    }

    Future<void> _pickImageProfGallery() async {
      imageEdit = await ImagePicker().getImage(source: ImageSource.gallery);

      if (imageEdit != null) {
        _showConfirmationDialogProf(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => MyTableScreen()));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Ajoutez ici la logique pour supprimer l'élément
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPage(pageData),
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(base64Decode(imageCouv['bytes'])),
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
                                        _pickImageCouvCamera();
                                      },
                                    ),
                                    ElevatedButton(
                                      child: Text('Gallery'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _pickImageCouvGallery();
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      })
                ],
              ),
              Stack(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: MemoryImage(base64Decode(imageProfile['bytes'])),
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
                                        _pickImageProfCamera();
                                      },
                                    ),
                                    ElevatedButton(
                                      child: Text('Gallery'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _pickImageProfGallery();
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      })
                ],
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text(
                      'Title :${pageData['title']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Address :${pageData['address']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tcity:${pageData['city']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Phone :${pageData['phone']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Email :${pageData['email']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'PostalCode :${pageData['postalCode']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Ajouter le code pour ajouter un produit ici
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 4.0),
                          Text('Ajouter produit'),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
