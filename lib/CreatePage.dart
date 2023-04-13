import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'listePage.dart';

class ProfileForm extends StatefulWidget {
  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _CityController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  File? imageProfile;
  File? imageCouverture;
  String? title;
  String? address;
  String? phone;
  String? postalCode;
  String? city;
  String? email;

  Future<void> _pickProfileImage() async {
    try {
      final imageFile =
          await ImagePicker().getImage(source: ImageSource.gallery);
      if (imageFile != null) {
        setState(() {
          imageProfile = File(imageFile.path);
        });
      }
    } catch (e) {
      print('Error selecting profile image: $e');
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final imageFile =
          await ImagePicker().getImage(source: ImageSource.gallery);
      if (imageFile != null) {
        setState(() {
          imageCouverture = File(imageFile.path);
        });
      }
    } catch (e) {
      print('Error selecting cover image: $e');
    }
  }

  Future<void> addPage() async {
    final String title = _titleController.text;
    final String address = _addressController.text;
    final String city = _CityController.text;
    final String phone = _phoneController.text;
    final String postalCode = _postalCodeController.text;
    final String email = _emailController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    final response = await http.post(
      Uri.parse('http://192.168.42.28:8080/pages/add/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'address': address,
        'city': city,
        'phone': phone,
        'postalCode': postalCode,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      var id1 = response.body;

      final request = http.MultipartRequest('POST',
          Uri.parse('http://192.168.42.28:8080/pages/addImagesToPage/$id1'));

      var imageProfile1 =
          await http.MultipartFile.fromPath('imageProfile', imageProfile!.path);
      var imageCouverture1 = await http.MultipartFile.fromPath(
          'imageCouverture', imageCouverture!.path);

      request.files.add(imageProfile1);
      request.files.add(imageCouverture1);
      var responsee = await request.send();
    } else {
      print('Error adding page');
    }
  }

  void _showConfirmationDialog(BuildContext context) {
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
              addPage();

              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => ListPage()));
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
                  'Add Page',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    title = value;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le champ adresse est requis';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    address = value;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _CityController,
                  decoration: InputDecoration(
                    labelText: 'Ville',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le champ ville est requis';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    city = value;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le champ email est requis';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    email = value;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'phone',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le champ phone est requis';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    phone = value;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(
                    labelText: 'postalCode',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le champ postalCode est requis';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    postalCode = value;
                  },
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Image de profil',
                    ),
                    SizedBox(width: 20.0),
                    Text(
                      'Image de couverture',
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickProfileImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        child: imageProfile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.file(
                                  imageProfile!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey[800],
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    GestureDetector(
                      onTap: _pickCoverImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        child: imageCouverture != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.file(
                                  imageCouverture!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey[800],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
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

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}
