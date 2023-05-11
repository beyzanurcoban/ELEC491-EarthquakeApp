import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  bool _isWaitingAutoLogin = false;

  final TextEditingController _usernameInputController = TextEditingController();
  final TextEditingController _passwordInputController = TextEditingController();

  final _storage = const FlutterSecureStorage();

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();

    // Connect to DB
    db = FirebaseFirestore.instance;

    // Retrieve stored credentials from DB
    _storage.readAll().then((credentials) {
      final username = credentials['username'];
      final password = credentials['password'];

      if (username != null && password != null) {
        // Auto-login the user
        setState(() {
          _isLoading = true;
        });
        _autoLoginUser(username, password);
      }
    });
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
        body: Stack(
          children: [
            Visibility(
              visible: !_isWaitingAutoLogin,
              child: SingleChildScrollView(
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
                                  Padding(
                                    padding: const EdgeInsets.only(left: 80, right: 80, bottom: 16),
                                    child: Image.asset('assets/images/dost_logo.png'),
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
                                            String usernameInput = _usernameInputController.text;
                                            String passwordInput = _passwordInputController.text;
                                            if (await usernamePasswordExists(usernameInput, passwordInput)) {
                                              // Store login credentials (for auto-login)
                                              await _storeCredentials(usernameInput, passwordInput);

                                              // Go to Home Page (with username)
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => HomePage(username: usernameInput,)),
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
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10.0),
                                        child: Row(
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
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                // Go to Sign-up Page
                                                Navigator.push<String>(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const HomePage(username: 'readonly',)),
                                                );
                                              },
                                              child: const Text(
                                                'Giriş yapmadan devam et.',
                                                style: TextStyle(
                                                    color: Colors.blueAccent
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
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
            Visibility(
              visible: _isWaitingAutoLogin,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Image.asset('assets/images/dost_logo.png'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> usernamePasswordExists(String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    final docRef = db.collection('user').doc(username);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;

      String passwordInputHashed = sha256.convert(
          utf8.encode(password)
      ).toString();

      if (passwordInputHashed == data['pass']) {
        return true;
      }
    }

    return false;
  }

  Future<void> _storeCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  Future<void> _autoLoginUser(String username, String password) async {
    setState(() {
      _isWaitingAutoLogin = true;
    });
    if (await usernamePasswordExists(username, password)) {
      setState(() {
        _isWaitingAutoLogin = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: username,)),
      );
    } else {
      setState(() {
        _isWaitingAutoLogin = false;
      });
    }
  }
}
