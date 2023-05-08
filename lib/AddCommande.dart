import 'package:flutter/material.dart';
import 'Caisse.dart';

class AddCommande extends StatefulWidget {
  @override
  _AddCommandeState createState() => _AddCommandeState();
}

class _AddCommandeState extends State<AddCommande> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => Caisse()));
          },
        ),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              "Thank you for placing an order!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
