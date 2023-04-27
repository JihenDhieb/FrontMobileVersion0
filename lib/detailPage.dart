import 'package:appcommerce/Addarticle.dart';
import 'package:appcommerce/DetailArticle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'listePage.dart';
import 'dart:convert';
import 'EditPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

class detailPage extends StatelessWidget {
  PickedFile? imageEdit;

  String? nom;
  final Map<dynamic, dynamic> pageData;
  final List<dynamic> articles;
  late Map<dynamic, dynamic> imageProfile;
  late Map<dynamic, dynamic> imageCouv;

  detailPage(this.pageData, this.articles) {
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

  void _submitFormdelete(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id2 = prefs.getString('id');
    final String id = pageData['id'];
    final Response = await http
        .get(Uri.parse('http://192.168.1.26:8080/pages/delete/$id/$id2'));
    if (Response.statusCode == 200) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyTableScreen()));
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

  void _showConfirmationDialogDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Are you sure you want to delete Page ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _submitFormdelete(context);
              Navigator.pop(context);
            },
            child: Text('delete'),
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
              _showConfirmationDialogDelete(context);
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
                    height: 200,
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
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text(
                      'Title: ${pageData['title']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Address: ${pageData['address']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Phone: ${pageData['phone']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Email: ${pageData['email']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Postal Code: ${pageData['postalCode']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Activity: ${pageData['activity'].toString().split('.').last}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Region: ${pageData['region'].toString().split('.').last}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (articles.length != 0)
                      CarouselSlider.builder(
                        itemCount: articles.length,
                        itemBuilder: (BuildContext context, int index,
                            int pageViewIndex) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          DetailArticle(articles[index])));
                            },
                            child: Expanded(
                              child: Container(
                                padding: EdgeInsets.all(3.0),
                                margin: EdgeInsets.symmetric(horizontal: 0.5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 90,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: MemoryImage(
                                            base64Decode(
                                              articles[index]['image']['bytes'],
                                            ),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Name: ${articles[index]['nom']}',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    SizedBox(height: 6.0),
                                    Text(
                                      'Stock: ${articles[index]['nbstock']}',
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          autoPlay: false,
                          aspectRatio: 2.0,
                          enlargeCenterPage: true,
                          scrollDirection: Axis.horizontal,
                          viewportFraction: 0.33,
                        ),
                      ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Addarticle(pageData)));
                      },
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 4.0),
                            Text('Add Article'),
                          ],
                        ),
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
