import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ui/HomePage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _passwordObscured = true;
  bool _showError = false;
  String errorMessage = 'Kullanıcı Oluşturulamadı';
  bool _isLoading = false;

  final TextEditingController _usernameInputController = TextEditingController();
  final TextEditingController _passwordInputController = TextEditingController();
  final TextEditingController _passwordRepeatInputController = TextEditingController();

  final Map<String, String> _roles = {
    'clinic': 'Hastane',
    'er': 'Acil',
    'firstaid': 'İlk Yardım',
    'morgue': 'Morg',
    'rescue': 'Arama-Kurtarma',
    //OPTIONAL: 'ambulance': 'Ambulans'
  };

  String _selectedRole = 'clinic';

  final _storage = const FlutterSecureStorage();

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
    return Scaffold(
        appBar: const CupertinoNavigationBar(
          leading: CupertinoNavigationBarBackButton(),
          middle: Text(
            "Kayıt Ol",
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
                                      labelText: 'Kullanıcı adı belirleyin',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: TextFormField(
                                    controller: _passwordInputController,
                                    obscureText: _passwordObscured,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: 'Şifre belirleyin',
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
                                  child: TextFormField(
                                    controller: _passwordRepeatInputController,
                                    obscureText: _passwordObscured,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Şifreyi tekrarlayın',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 40),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Ekip Seçin:'
                                      ),
                                      DropdownButton<String>(
                                        value: _selectedRole,
                                        items: _roles.entries
                                            .map((entry) => DropdownMenuItem<String>(
                                          value: entry.key,
                                          child: Text(entry.value),
                                        )).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedRole = value!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      String usernameInput = _usernameInputController.text;
                                      String passwordInput = _passwordInputController.text;
                                      if (await userCreated()) {
                                        // TODO: Store login credentials (for auto-login)
                                        _storeCredentials(usernameInput, passwordInput);
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
                                    child: const Text('Kayıt ol')
                                  ),
                                ),
                                Visibility(
                                  visible: _showError,
                                  child: Text(
                                    errorMessage,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12.0,
                                    ),
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
    );
  }

  Future<bool> userCreated() async {
    setState(() {
      _isLoading = true;
    });

    // Check if the passwords match
    String password = _passwordInputController.text;
    String passwordRepeat = _passwordRepeatInputController.text;
    if (password != passwordRepeat) {
      return false;
    }

    // Check if the user already exists
    CollectionReference usersRef = FirebaseFirestore.instance.collection('user');
    DocumentSnapshot userDoc = await usersRef.doc(_usernameInputController.text).get();
    if (userDoc.exists) {
      errorMessage = 'Kullanıcı Adı alınmış';
      return false;
    }

    // Create the user document with the username as the document ID
    try {
      String passwordHashed = sha256.convert(
          utf8.encode(password)
      ).toString();
      await usersRef.doc(_usernameInputController.text).set({
        'pass': passwordHashed,
        'victim': true,
        _selectedRole: true,
      });
      return true;
    } catch (e) {
      // Handle any errors that occurred during the push
      errorMessage = 'Veritabanı Hatası: ${e.toString()}';
      return false;
    }
  }

  Future<void> _storeCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }
}
