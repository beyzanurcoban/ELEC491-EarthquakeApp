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
  final Color _primaryColor = const Color(0xff6a6b83);
  final Color _secondaryColor = const Color(0xff77789a);
  final Color _tertiaryColor = const Color(0xffebebeb);
  final Color _backgroundColor = const Color(0xffd5d5e4);
  final Color _shadowColor = const Color(0x806a6b83);

  final Color _selectedBoxColor = const Color(0xff6a6b83);
  final Color _unselectedBoxColor = Colors.transparent;

  final Color _selectedTextColor = const Color(0xffebebeb);
  final Color _unselectedTextColor = const Color(0xff6a6b83);

  bool _passwordObscured = true;
  bool _isLoading = false;

  final TextEditingController _usernameInputController = TextEditingController();
  final TextEditingController _passwordInputController = TextEditingController();
  final TextEditingController _passwordRepeatInputController = TextEditingController();
  final TextEditingController _authTokenInputController = TextEditingController();

  final Map<String, String> _roles = {
    'readonly': 'Ekip Yok',
    'rescue': 'Arama-Kurtarma',
    'firstaid': 'İlk Yardım',
    'er': 'Acil',
    'clinic': 'Klinik',
    'morgue': 'Morg',
    'burial': 'Mezarlık-Defin',
  };

  final Map<String, List<String>> _tokens = {
    'clinic': ['9xtnU6jp', 'yjTo8XjG', 'Ze5w3557'],
    'er': ['6wZKp1vx', 'BBryTm7s', 'kcmQFpAj'],
    'firstaid': ['Rvwg3Mob', 'cb2S0otA', 'mcjwPThG'],
    'morgue': ['4Lhitzqp', '4rxr5rON', 'Kyjco87o'],
    'rescue': ['87hQ1r71', 's5RoVjfu', 'avt4EHYi'],
    'burial': ['imkW9nR0', 'K2zLdGvG', 'FKApE2Pm'],
  };

  String _selectedRole = '';

  final _storage = const FlutterSecureStorage();

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();

    // Connect to DB
    db = FirebaseFirestore.instance;

    // Set selected role to first.
    _selectedRole = _roles.entries.first.key;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _backgroundColor,
        body: Stack(
          children: [
            SingleChildScrollView(
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
                                                  height: 32.0,
                                                  width: 32.0,
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
                                              'Şifreyi Tekrarla',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: _primaryColor,
                                              ),
                                            ),
                                            const Padding(padding: EdgeInsets.only(top: 12.0)),
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
                                                      controller: _passwordRepeatInputController,
                                                      obscureText: _passwordObscured,
                                                      obscuringCharacter: '●',
                                                      enableSuggestions: false,
                                                      autocorrect: false,
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                                            child: Text(
                                              'Ekip Seçin',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: _primaryColor,
                                              ),
                                            ),
                                          ),
                                          const Padding(padding: EdgeInsets.only(top: 12.0)),
                                          Column(
                                            children: [
                                              SizedBox(
                                                height: 32,
                                                child: ListView.builder(
                                                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: _roles.length,
                                                  itemBuilder: (context, index) {
                                                    final key = _roles.keys.elementAt(index);
                                                    final value = _roles[key];
                                                    return Padding(
                                                      padding: const EdgeInsets.only(right: 8.0,),
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _selectedRole = key;
                                                          });
                                                        },
                                                        style: OutlinedButton.styleFrom(
                                                          side: BorderSide(
                                                            width: 1.0,
                                                            color: _selectedBoxColor,
                                                          ),
                                                          backgroundColor: _selectedRole == key ? _selectedBoxColor : _unselectedBoxColor,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          value ?? 'Bulunamadı',
                                                          style: TextStyle(
                                                            color: _selectedRole == key ? _selectedTextColor : _unselectedTextColor,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20, bottom: 120),
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
                                              'Yetkilendirme Kodu',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: _primaryColor,
                                              ),
                                            ),
                                            const Padding(padding: EdgeInsets.only(top: 12.0)),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.lock,
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
                                                      controller: _authTokenInputController,
                                                      enableSuggestions: false,
                                                      autocorrect: false,
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
                              ],
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
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
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Geri',
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
                                        if (await userCreated()) {
                                          // Store login credentials (for auto-login)
                                          _storeCredentials(usernameInput, passwordInput);
                                          // Go to Home Page (with username)
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => HomePage(username: usernameInput,)),
                                          );
                                        } else {
                                          setState(() {
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
                                                'Kayıt Ol',
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
                ],
              ),
            ),
          ],
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Şifre tekrarı uyuşmuyor.')));
      return false;
    }

    // Check if authorization token is valid
    bool _tokenValid = _tokens[_selectedRole]?.contains(_authTokenInputController.text) ?? false;
    if (_selectedRole == 'readonly') {_tokenValid = true;}
    if (!_tokenValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Yetkilendirme Kodu yanlış.')));
      return false;
    }

    // Check if the user already exists
    CollectionReference usersRef = FirebaseFirestore.instance.collection('user');
    DocumentSnapshot userDoc = await usersRef.doc(_usernameInputController.text).get();
    if (userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Kullanıcı adı alınmış.')));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veritabanı Hatası.')));
      return false;
    }
  }

  Future<void> _storeCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }
}
