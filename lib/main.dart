import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(WhatsAppMessageApp());
}

class WhatsAppMessageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Message App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}