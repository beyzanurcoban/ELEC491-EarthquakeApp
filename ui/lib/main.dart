//import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'HomePage.dart';

void main() {
  runApp(const NFCTrackerApp());
}

class NFCTrackerApp extends StatelessWidget {
  const NFCTrackerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'NFC Tracker',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


