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
  final Color _primaryColor = const Color(0xff6a6b83);
  final Color _secondaryColor = const Color(0xff77789a);
  final Color _tertiaryColor = const Color(0xffebebeb);
  final Color _backgroundColor = const Color(0xffd5d5e4);
  final Color _shadowColor = const Color(0x806a6b83);

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
        backgroundColor: _backgroundColor,
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
                          padding: const EdgeInsets.all(20.0),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: SizedBox(
                                      height: 60,
                                      child: Image.asset('assets/images/dost_large.png'),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: SizedBox(
                                      height: 90,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _tertiaryColor,
                                          borderRadius: BorderRadius.circular(30.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _shadowColor,
                                              blurRadius: 10.0,
                                              offset: const Offset(0.0, 10.0),
                                            )
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Kullanıcı Adı',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: _primaryColor,
                                                ),
                                              ),
                                              const Padding(padding: EdgeInsets.only(top: 12.0)),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.account_circle_rounded,
                                                    size: 20.0,
                                                    color: _primaryColor,
                                                  ),
                                                  const Padding(padding: EdgeInsets.only(left: 10.0)),
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 20.0,
                                                      child: TextFormField(
                                                        cursorColor: _primaryColor,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: _primaryColor,
                                                        ),
                                                        controller: _usernameInputController,
                                                        inputFormatters: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]'))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: SizedBox(
                                      height: 90,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _tertiaryColor,
                                          borderRadius: BorderRadius.circular(30.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _shadowColor,
                                              blurRadius: 10.0,
                                              offset: const Offset(0.0, 10.0),
                                            )
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Şifre',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: _primaryColor,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.key,
                                                    size: 20.0,
                                                    color: _primaryColor,
                                                  ),
                                                  const Padding(padding: EdgeInsets.only(left: 10.0)),
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 20.0,
                                                      child: TextFormField(
                                                        cursorColor: _primaryColor,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: _primaryColor,
                                                        ),
                                                        controller: _passwordInputController,
                                                        obscureText: _passwordObscured,
                                                        obscuringCharacter: '●',
                                                        enableSuggestions: false,
                                                        autocorrect: false,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 32.0,
                                                    height: 32.0,
                                                    child: IconButton(
                                                      iconSize: 20.0,
                                                      color: _primaryColor,
                                                      onPressed: () {
                                                        setState(() {
                                                          _passwordObscured = !_passwordObscured;
                                                        });
                                                      },
                                                      icon: Icon(
                                                          _passwordObscured
                                                              ? Icons.visibility_off : Icons.visibility
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: SizedBox(
                                      height: 60,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _tertiaryColor,
                                          borderRadius: BorderRadius.circular(30.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _shadowColor,
                                              blurRadius: 10.0,
                                              offset: const Offset(0.0, 10.0),
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: TextButton(
                                                  onPressed: () {
                                                    // Go to Sign-up Page
                                                    Navigator.push<String>(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => const SignupPage()),
                                                    );
                                                  },
                                                  child: Text(
                                                    'Kayıt Ol',
                                                    style: TextStyle(
                                                      color: _primaryColor,
                                                      fontSize: 16.0,
                                                      fontWeight: FontWeight.w700
                                                    ),
                                                  ),
                                                )
                                            ),
                                            Expanded(
                                                child: SizedBox(
                                                  height: 60,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: _primaryColor,
                                                      borderRadius: BorderRadius.circular(30.0),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: _shadowColor,
                                                          blurRadius: 10.0,
                                                          offset: const Offset(0.0, 10.0),
                                                        )
                                                      ],
                                                    ),
                                                    child: TextButton(
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
                                                      child: Stack(
                                                        children: [
                                                          Visibility(
                                                            visible: !_isLoading,
                                                            child: Center(
                                                              child: Text(
                                                                'Giriş Yap',
                                                                style: TextStyle(
                                                                    color: _tertiaryColor,
                                                                    fontSize: 16.0,
                                                                    fontWeight: FontWeight.w700
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Visibility(
                                                            visible: _isLoading,
                                                            child: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                                                                child: LinearProgressIndicator(
                                                                  color: _tertiaryColor,
                                                                  backgroundColor: _primaryColor,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            )
                                          ],
                                        )
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: SizedBox(
                                      height: 60,
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: _tertiaryColor,
                                            borderRadius: BorderRadius.circular(30.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _shadowColor,
                                                blurRadius: 10.0,
                                                offset: const Offset(0.0, 10.0),
                                              )
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => const HomePage(username: 'readonly',)),
                                                      );
                                                    },
                                                    child: Text(
                                                      'Giriş Yapmadan Devam Et',
                                                      style: TextStyle(
                                                          color: _primaryColor,
                                                          fontSize: 16.0,
                                                          fontWeight: FontWeight.w700
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            ],
                                          )
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
                  child: Image.asset('assets/images/dost_large.png'),
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: username,)),
      );

      setState(() {
        _isWaitingAutoLogin = false;
      });
    } else {
      setState(() {
        _isWaitingAutoLogin = false;
      });
    }
  }
}
