import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:crypto/crypto.dart';
import 'package:ui/HomePage.dart';
import 'package:ui/SignupPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordObscured = true;
  bool _showError = false;
  bool _isLoading = false;

  final TextEditingController _usernameInputController = TextEditingController();
  final TextEditingController _passwordInputController = TextEditingController();

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();

    // Connect to DB
    db = FirebaseFirestore.instance;

  }

  @override
  Widget build(BuildContext context) {
    // TODO: Home Page UI Here
    return MaterialApp(
      home: Scaffold(
        appBar: const CupertinoNavigationBar(
          middle: Text(
            "Giriş Yap",
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: FutureBuilder<bool>(
              future: NfcManager.instance.isAvailable(),
              builder: (context, ss) => /*ss.data != true
                  ? Center(child: Text('NFC is available: ${ss.data}'))
                  :*/ Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              // TODO: Logo Here
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: TextFormField(
                                    controller: _usernameInputController,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]'))
                                    ],
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Kullanıcı Adı',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: TextFormField(
                                    controller: _passwordInputController,
                                    obscureText: _passwordObscured,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: 'Şifre',
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _passwordObscured = !_passwordObscured;
                                          });
                                        },
                                        icon: Icon(
                                          _passwordObscured
                                          ? Icons.visibility : Icons.visibility_off
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (await usernamePasswordExists()) {
                                        // TODO: Store login credentials (for auto-login)
                                        // Go to Home Page (with username)
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => HomePage(username: _usernameInputController.text,)),
                                        );
                                      } else {
                                        setState(() {
                                          _showError = true;
                                          _isLoading = false;
                                        });
                                      }
                                    },
                                    child: const Text('Giriş Yap')
                                  ),
                                ),
                                Visibility(
                                  visible: _showError,
                                  child: const Text(
                                    'Kullanıcı Adı ya da Şifre yanlış.',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Profilin yok mu?',
                                      style: TextStyle(
                                        color: Colors.black38,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Go to Sign-up Page
                                        Navigator.push<String>(
                                          context,
                                          MaterialPageRoute(builder: (context) => const SignupPage()),
                                        );
                                      },
                                      child: const Text(
                                        'Kayıt ol.',
                                        style: TextStyle(
                                            color: Colors.blueAccent
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Visibility(
                                visible: _isLoading,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          spreadRadius: 3,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        )
                                      ]
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: const [
                                        CircularProgressIndicator(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> usernamePasswordExists() async {
    setState(() {
      _isLoading = true;
    });

    final docRef = db.collection('user').doc(_usernameInputController.text);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;

      String passwordInputHashed = sha256.convert(
          utf8.encode(_passwordInputController.text)
      ).toString();

      if (passwordInputHashed == data['pass']) {
        return true;
      }
    }

    return false;
  }
}
