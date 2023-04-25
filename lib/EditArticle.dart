import 'package:appcommerce/DetailArticle.dart';
import 'package:appcommerce/detailPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'DetailArticle.dart';

class EditArticle extends StatefulWidget {
  final dynamic article;
  EditArticle(this.article);

  @override
  _EditArticleState createState() => _EditArticleState();
}

class _EditArticleState extends State<EditArticle> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late TextEditingController _nbstockController;
  late TextEditingController _prixController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.article['nom']);
    _descriptionController =
        TextEditingController(text: widget.article['description']);
    _prixController = TextEditingController(text: widget.article['prix']);
    _nbstockController = TextEditingController(text: widget.article['nbstock']);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _nbstockController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String nom = _nomController.text;
      final String prix = _prixController.text;
      final String description = _descriptionController.text;
      final String nbstock = _nbstockController.text;

      final response = await http.put(
        Uri.parse('http://192.168.1.26:8080/article/editArticle'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic>{
          'id': widget.article['id'],
          'nom': nom,
          'description': description,
          'prix': prix,
          'nbstock': nbstock,
        }),
      );

      if (response.statusCode == 200) {
        // If update is successful, navigate back to Compte widget
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DetailArticle(widget.article),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Article')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'nom',
                  labelStyle: TextStyle(
                    color: Colors.blueGrey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(
                    color: Colors.blueGrey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _prixController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(
                    color: Colors.blueGrey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your prix';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _nbstockController,
                decoration: InputDecoration(
                  labelText: 'Nbstock',
                  labelStyle: TextStyle(
                    color: Colors.blueGrey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your nbStock';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
