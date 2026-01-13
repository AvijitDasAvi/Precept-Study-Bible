import 'package:flutter/material.dart';

class BiblesScreen extends StatelessWidget {
  const BiblesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bibles')),
      body: Center(child: Text('Bibles Screen')),
    );
  }
}
