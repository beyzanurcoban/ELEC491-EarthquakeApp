import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'LoginPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NFCTrackerApp());
}

class NFCTrackerApp extends StatelessWidget {
  const NFCTrackerApp({super.key});

  final Color _primaryColor = const Color(0xff6a6b83);
  final Color _secondaryColor = const Color(0xff77789a);
  final Color _tertiaryColor = const Color(0xffebebeb);
  final Color _backgroundColor = const Color(0xffd5d5e4);
  final Color _shadowColor = const Color(0x806a6b83);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Tracker',
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: _backgroundColor,
        primaryColor: _primaryColor,
        dialogTheme: DialogTheme(
          backgroundColor: _tertiaryColor,
          titleTextStyle: TextStyle(
            fontSize: 16.0,
            color: _primaryColor,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: TextStyle(
            fontSize: 14.0,
            color: _primaryColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        colorScheme: ColorScheme.light(
          primary: _primaryColor,
          secondary: _secondaryColor,
          tertiary: _tertiaryColor,
          onPrimary: _tertiaryColor,
          onSurface: _primaryColor,
        ),
        timePickerTheme: TimePickerThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // this is the border radius of the picker
          ),
        ),
      ),
    );
  }
}


