import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ui/RoleBasedRecordWritePage.dart';
import 'package:ui/SearchPage.dart';
import 'package:ui/SurvivorReadPage.dart';
import 'package:ui/SurvivorWritePage.dart';
import 'LoginPage.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _nfcSessionRunning = false;
  bool _roleExists = false;
  bool _canWriteVictim = false;

  Color _primaryColor = const Color(0xff6a6b83);

  final Map<String, String> _roles = {
    'clinic': 'Hastane',
    'er': 'Acil',
    'firstaid': 'İlk Yardım',
    'morgue': 'Morg',
    'rescue': 'Arama-Kurtarma',
    'ambulance': 'Ambulans',
    'none': 'Yok'
  };

  late String _userRole = 'none';

  final _storage = FlutterSecureStorage();

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();

    // Connect to DB
    db = FirebaseFirestore.instance;

    // Get victim info from DB with ndefUID
    getUserFromDB();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Home Page UI Here
    return Scaffold(
        appBar: CupertinoNavigationBar(
          middle: const Text(
            "ELEC491 NFC Takip",
          ),
          automaticallyImplyLeading: false,
          trailing: CupertinoButton(
            onPressed: () {
              Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            child: const Icon(
              CupertinoIcons.search,
              color: Colors.blue,
            ),
          ),
        ),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, ss) => /*ss.data != true
                ? Center(child: Text('NFC is available: ${ss.data}'))
                :*/ Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30, left: 80, right: 80, bottom: 16),
                            child: Image.asset('assets/images/dost_logo.png'),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'Kullanıcı: ${widget.username}\nYetki: ${_roles[_userRole]}',
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.black38,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 10),
                                      child: SizedBox(
                                        height: 60,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: _tagRead,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Icon(
                                                Icons.nfc_rounded,
                                                color: _primaryColor,
                                              ),
                                              Text(
                                                'NFC Etiket Oku',
                                                style: TextStyle(
                                                  color: _primaryColor,
                                                  fontSize: 18.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: _canWriteVictim,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 10),
                                        child: SizedBox(
                                          height: 60,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: _ndefWrite,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: const [
                                                Icon(
                                                  Icons.edit
                                                ),
                                                Text(
                                                  'NFC Etikete Yaz',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: _roleExists,
                                child: Column(
                                  children: [
                                    const Divider(
                                      indent: 25,
                                      endIndent: 25,
                                      thickness: 2,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                                            child: SizedBox(
                                              height: 60,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                onPressed: _ndefRoleBasedRecordWrite,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Icon(
                                                      Icons.add_rounded,
                                                      color: Colors.deepOrange,
                                                    ),
                                                    Text(
                                                      '${_roles[_userRole]} Kaydı Ekle',
                                                      style: const TextStyle(
                                                        color: Colors.deepOrange,
                                                        fontSize: 18.0,
                                                      ),
                                                    ),
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
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: TextButton(
                                    onPressed: () async {
                                      _deleteCredentials();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LoginPage()),
                                      );
                                    },
                                    child: const Text('Çıkış Yap')
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Visibility(
                            visible: _nfcSessionRunning,
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
                                    Text(
                                      'Etiket Aranıyor...'
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 20.0)),
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
    );
  }

  void _tagRead() {
    setState(() {
      _nfcSessionRunning = true;
    });
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {

      // Get ndefUID from NFC tag
      var ndefUID = tag.data["ndef"]["identifier"]
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join('');

      // Access database with Unique ID => ndefUID
      Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => SurvivorReadPage(ndefUID: ndefUID,)),
      );

      setState(() {
        _nfcSessionRunning = false;
      });
      NfcManager.instance.stopSession();
    });
  }

  void _ndefWrite() {
    setState(() {
      _nfcSessionRunning = true;
    });

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      // Get UID
      var ndefUID = tag.data["ndef"]["identifier"]
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join('');

      // Fetch from database with UID
      Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => SurvivorWritePage(ndefUID: ndefUID,)),
      );

      setState(() {
        _nfcSessionRunning = false;
      });
      NfcManager.instance.stopSession();
    });
  }

  void _ndefRoleBasedRecordWrite() {
    setState(() {
      _nfcSessionRunning = true;
    });

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      // Get UID
      var ndefUID = tag.data["ndef"]["identifier"]
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join('');

      // Fetch from database with UID
      Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => RoleBasedRecordWritePage(
          ndefUID: ndefUID,
          username: widget.username,
          role: _userRole,
        )),
      );

      setState(() {
        _nfcSessionRunning = false;
      });
      NfcManager.instance.stopSession();
    });
  }

  void getUserFromDB() async {
    final docRef = db.collection('user').doc(widget.username);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      setState(() {
        _canWriteVictim = data['victim'] ?? false;

        _roleExists = data['ambulance'] ?? false;
        if (_roleExists) {
          _userRole = 'ambulance';
          return;
        }

        _roleExists = data['clinic'] ?? false;
        if (_roleExists) {
          _userRole = 'clinic';
          return;
        }

        _roleExists = data['firstaid'] ?? false;
        if (_roleExists) {
          _userRole = 'firstaid';
          return;
        }

        _roleExists = data['er'] ?? false;
        if (_roleExists) {
          _userRole = 'er';
          return;
        }

        _roleExists = data['morgue'] ?? false;
        if (_roleExists) {
          _userRole = 'morgue';
          return;
        }

        _roleExists = data['rescue'] ?? false;
        if (_roleExists) {
          _userRole = 'rescue';
          return;
        }

      });
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  Future<void> _deleteCredentials() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }
}
