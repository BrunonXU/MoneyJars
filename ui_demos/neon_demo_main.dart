import 'package:flutter/material.dart';
import 'glassmorphism_demo.dart';

void main() {
  runApp(GlassmorDemoApp());
}

class GlassmorDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glassmorphism UI Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GlassmorphismDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}