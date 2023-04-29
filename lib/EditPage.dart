import 'package:appcommerce/MyMapEdit.dart';
import 'package:appcommerce/detailPage.dart';
import 'package:appcommerce/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'listePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPage extends StatefulWidget {
  final Map<dynamic, dynamic> pageData;

  EditPage(this.pageData);

  @override
  _EditPageState createState() => _EditPageState();
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

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _postalCodeController;
  late TextEditingController _emailController;
  late Activity selectedActivity;
  late Region selectedRegion;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.pageData['title']);
    _addressController =
        TextEditingController(text: widget.pageData['address']);
    _phoneController = TextEditingController(text: widget.pageData['phone']);
    _postalCodeController =
        TextEditingController(text: widget.pageData['postalCode']);
    _emailController = TextEditingController(text: widget.pageData['email']);

    selectedActivity = Activity.values.firstWhere((activity) =>
        activity.toString().split('.').last == widget.pageData['activity']);
    selectedRegion = Region.values.firstWhere((region) =>
        region.toString().split('.').last == widget.pageData['region']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _postalCodeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String title = _titleController.text;
      final String address = _addressController.text;
      final String phone = _phoneController.text;
      final String postalCode = _postalCodeController.text;
      final String email = _emailController.text;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('id');
      final response = await http.put(
        Uri.parse('http://192.168.1.26:8080/pages/editPage/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': widget.pageData['id'],
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
        // If update is successful, navigate back to Compte widget
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MyTableScreen(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Page details updated')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating Page details')),
        );
      }
    }
  }

  void _showConfirmationDialog() {
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

  void _goMapEdit() {
    final String title = _titleController.text;
    final String address = _addressController.text;
    final String phone = _phoneController.text;
    final String postalCode = _postalCodeController.text;
    final String email = _emailController.text;

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyAppEdit(
                widget.pageData['id'],
                title,
                address,
                phone,
                postalCode,
                email,
                selectedActivity.toString().split('.').last,
                selectedRegion.toString().split('.').last,
                widget.pageData['longitude'],
                widget.pageData['latitude'])));
  }

  bool isFoodSelected = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Page ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => MyTableScreen()));
          },
        ),
        backgroundColor: Colors.blue, // couleur de fond de la barre
        elevation: 0, // retirer l'ombre de la barre
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'title',
                  labelStyle: TextStyle(
                    color: Colors.blueGrey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(
                    color: Colors.blueGrey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(
                    color: Colors.blueGrey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  labelText: 'PostalCode',
                  labelStyle: TextStyle(
                    color: Colors.blueGrey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your postalCode';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'email',
                  labelStyle: TextStyle(
                    color: Colors.blueGrey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your postalCode';
                  }
                  return null;
                },
              ),
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
                          child: Text(activity.toString().split('.').last),
                        ))
                    .toList(),
                onChanged: (activity) {
                  setState(() {
                    selectedActivity = activity!;
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
                    selectedRegion = region!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Le champ region est requis';
                  }
                  return null;
                },
              ),
              if (selectedActivity == Activity.RESTAURANTS ||
                  selectedActivity == Activity.SUPERETTE ||
                  selectedActivity == Activity.PATISSERIE) ...[
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    _goMapEdit();
                  },
                  child: Text('Add your  position'),
                ),
              ],
              if (!isFoodSelected && selectedActivity != Activity.RESTAURANTS ||
                  selectedActivity != Activity.SUPERETTE ||
                  selectedActivity != Activity.PATISSERIE)
                Center(
                  child: SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: () => _showConfirmationDialog(),
                      child: Text('Save'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
