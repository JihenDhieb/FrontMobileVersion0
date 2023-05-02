import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'listePage.dart';
import 'MyMap.dart';

class ProfileForm extends StatefulWidget {
  @override
  _ProfileFormState createState() => _ProfileFormState();
}

enum Activity {
  RESTAURANTS,
  MODE,
  BEAUTE,
  ELECTRONIQUES,
  ELECTROMENAGER,
  SUPERETTE,
  SPORTS,
  PATISSERIE
}

enum Region {
  Ariana,
  Beja,
  BenArous,
  Bizerte,
  Gabes,
  Gafsa,
  Jendouba,
  Kairouan,
  Kasserine,
  Kebili,
  Kef,
  Mahdia,
  Manouba,
  Medenine,
  Monastir,
  Nabeul,
  Sfax,
  SidiBouzid,
  Siliana,
  Sousse,
  Tataouine,
  Tozeur,
  Tunis,
  Zaghouan,
}

class _ProfileFormState extends State<ProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  File? imageProfile;
  File? imageCouverture;
  String? title;
  String? address;
  String? phone;
  String? postalCode;

  String? email;
  Activity? selectedActivity;
  Region? selectedRegion;

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

  void _goMap() {
    final String title = _titleController.text;
    final String address = _addressController.text;
    final String phone = _phoneController.text;
    final String postalCode = _postalCodeController.text;
    final String email = _emailController.text;

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyApp(
                title,
                address,
                phone,
                postalCode,
                email,
                selectedActivity.toString().split('.').last,
                selectedRegion.toString().split('.').last,
                imageProfile,
                imageCouverture)));
  }

  Future<void> addPage(BuildContext context) async {
    final String title = _titleController.text;
    final String address = _addressController.text;
    final String phone = _phoneController.text;
    final String postalCode = _postalCodeController.text;
    final String email = _emailController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    final response = await http.post(
      Uri.parse('http://192.168.1.26:8080/pages/add/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'address': address,
        'phone': phone,
        'postalCode': postalCode,
        'email': email,
        'activity': selectedActivity.toString().split('.').last,
        'region': selectedRegion.toString().split('.').last,
      }),
    );
    if (response.statusCode == 200) {
      var id1 = response.body;

      final request = http.MultipartRequest('POST',
          Uri.parse('http://192.168.1.26:8080/pages/addImagesToPage/$id1'));

      var imageProfile1 =
          await http.MultipartFile.fromPath('imageProfile', imageProfile!.path);
      var imageCouverture1 = await http.MultipartFile.fromPath(
          'imageCouverture', imageCouverture!.path);

      request.files.add(imageProfile1);
      request.files.add(imageCouverture1);
      var responsee = await request.send();
      if (responsee.statusCode == 200) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyTableScreen()));
      }
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
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.orange,
            ),
          ),
          TextButton(
            onPressed: () {
              addPage(context);
            },
            child: Text('Save'),
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  bool isFoodSelected = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Page '),
          backgroundColor: Colors.orange,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyTableScreen(),
                  ),
                );
              }),
        ),
        key: _formKey,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                SizedBox(height: 20),
                TextFormField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(
                    labelText: 'PostalCode',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a PostalCode';
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
                Column(
                  children: [
                    SizedBox(height: 20.0),
                    DropdownButtonFormField<Activity>(
                      decoration: InputDecoration(
                        labelText: 'Activity',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedActivity,
                      items: Activity.values
                          .map((activity) => DropdownMenuItem<Activity>(
                                value: activity,
                                child:
                                    Text(activity.toString().split('.').last),
                              ))
                          .toList(),
                      onChanged: (activity) {
                        setState(() {
                          selectedActivity = activity;
                          if (selectedActivity == Activity.RESTAURANTS ||
                              selectedActivity == Activity.SUPERETTE ||
                              selectedActivity == Activity.PATISSERIE) {
                            isFoodSelected = true;
                          } else {
                            isFoodSelected = false;
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Le champ activity est requis';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                DropdownButtonFormField<Region>(
                  decoration: InputDecoration(
                    labelText: 'Region',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedRegion,
                  items: Region.values
                      .map((region) => DropdownMenuItem<Region>(
                            value: region,
                            child: Text(region.toString().split('.').last),
                          ))
                      .toList(),
                  onChanged: (region) {
                    setState(() {
                      selectedRegion = region;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Le champ region est requis';
                    }
                    return null;
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
                if (isFoodSelected) ...[
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      _goMap();
                    },
                    child: Text('Add your  position'),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.orange),
                    ),
                  ),
                ],
                if (!isFoodSelected)
                  Center(
                    child: SizedBox(
                      width: 400,
                      child: ElevatedButton(
                        onPressed: () => _showConfirmationDialog(context),
                        child: Text('Save'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.orange),
                        ),
                      ),
                    ),
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
