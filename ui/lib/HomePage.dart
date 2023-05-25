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
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color _primaryColor = const Color(0xff6a6b83);
  final Color _secondaryColor = const Color(0xff77789a);
  final Color _tertiaryColor = const Color(0xffebebeb);
  final Color _backgroundColor = const Color(0xffd5d5e4);
  final Color _shadowColor = const Color(0x806a6b83);

  bool _nfcSessionRunning = false;
  bool _roleExists = false;
  bool _canWriteVictim = false;
  String _dialogText = 'Etiket aranıyor...';

  final Map<String, String> _roles = {
    'clinic': 'Klinik',
    'er': 'Acil',
    'firstaid': 'İlk Yardım',
    'morgue': 'Morg',
    'rescue': 'Arama-Kurtarma',
    'burial': 'Mezarlık-Defin',
    'readonly': 'Ekip Yok',
  };

  final Map<String, String> _roleToAvatar = {
    'clinic': 'assets/images/hospital-avatar.png',
    'er': 'assets/images/hospital-avatar.png',
    'firstaid': 'assets/images/hospital-avatar.png',
    'morgue': 'assets/images/hospital-avatar.png',
    'rescue': 'assets/images/rescue-avatar.png',
    'burial': 'assets/images/burial-avatar.png',
  };

  final Map<String, String> _roleToIcon = {
    'clinic': 'assets/images/crescent32.png',
    'er': 'assets/images/crescent32.png',
    'firstaid': 'assets/images/crescent32.png',
    'morgue': 'assets/images/crescent32.png',
    'rescue': 'assets/images/hardhat32.png',
    'burial': 'assets/images/grave32.png',
  };

  late String _userRole = 'readonly';

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
        backgroundColor: _backgroundColor,
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, ss) => /*ss.data != true
                ? Center(child: Text('NFC is available: ${ss.data}'))
                :*/ Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Stack(
                    children: [
                      Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                      onPressed: !_nfcSessionRunning ? () async {
                                        _deleteCredentials();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const LoginPage()),
                                        );
                                      } : null,
                                      child: Text(
                                        'Çıkış Yap',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _primaryColor,
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SingleChildScrollView(
                            child: Column(
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
                                    height: 120,
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
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(_roleToAvatar[_userRole] ?? 'assets/images/readonly-avatar.png'),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    widget.username,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w700,
                                                      color: _primaryColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    _roles[_userRole] ?? _userRole,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: _primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 60,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _shadowColor,
                                                  blurRadius: 10.0,
                                                  offset: const Offset(0.0, 10.0),
                                                )
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _tertiaryColor,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30.0),
                                                ),
                                              ),
                                              onPressed: !_nfcSessionRunning ? _tagRead : null,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      height: 32,
                                                      width: 32,
                                                      child: Image.asset('assets/images/nfctag32.png'),
                                                    ),
                                                    Text(
                                                      'Etiket Oku',
                                                      style: TextStyle(
                                                        color: _primaryColor,
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: _canWriteVictim,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _shadowColor,
                                                  blurRadius: 10.0,
                                                  offset: const Offset(0.0, 10.0),
                                                )
                                              ],
                                            ),
                                            child: SizedBox(
                                              height: 60,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: _tertiaryColor,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                  ),
                                                ),
                                                onPressed: !_nfcSessionRunning ? _ndefWrite : null,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Icon(
                                                        Icons.edit,
                                                        size: 32.0,
                                                        color: _primaryColor,
                                                      ),
                                                      Text(
                                                        'Depremzede Bilgisi Yaz',
                                                        style: TextStyle(
                                                          color: _primaryColor,
                                                          fontSize: 16.0,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _roleExists,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 90,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(30.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _shadowColor,
                                                    blurRadius: 10.0,
                                                    offset: const Offset(0.0, 10.0),
                                                  )
                                                ],
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: _tertiaryColor,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                  ),
                                                ),
                                                onPressed: !_nfcSessionRunning ? _ndefRoleBasedRecordWrite : null,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                      height: 32,
                                                      width: 32,
                                                      child: Image.asset(_roleToIcon[_userRole] ?? 'assets/images/crescent32.png'),
                                                    ),
                                                    Text(
                                                      '${_roles[_userRole]} Kaydı Ekle',
                                                      style: TextStyle(
                                                        color: _primaryColor,
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.w700,
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
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _shadowColor,
                                                blurRadius: 10.0,
                                                offset: const Offset(0.0, 10.0),
                                              )
                                            ],
                                          ),
                                          child: SizedBox(
                                            height: 60,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _primaryColor,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30.0),
                                                ),
                                              ),
                                              onPressed: !_nfcSessionRunning ? () {
                                                Navigator.push<String>(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const SearchPage()),
                                                );
                                              }: null,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const SizedBox(
                                                      height: 32,
                                                      width: 32,
                                                      child: Icon(Icons.search),
                                                    ),
                                                    Text(
                                                      'Ara',
                                                      style: TextStyle(
                                                        color: _tertiaryColor,
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Visibility(
                          visible: _nfcSessionRunning,
                          child: SizedBox(
                            height: 120,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.0),
                                color: _tertiaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: _shadowColor,
                                    blurRadius: 10.0,
                                    offset: const Offset(0.0, 10.0),
                                  )
                                ]
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    LinearProgressIndicator(
                                      color: _tertiaryColor,
                                      backgroundColor: _primaryColor,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _dialogText,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _primaryColor,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _nfcSessionRunning = false;
                                            });
                                            NfcManager.instance.stopSession();
                                          },
                                          child: Text(
                                            'İptal Et',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: _primaryColor,
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
                      ),
                    ],
                  ),
                ),
          ),
        ),
    );
  }

  // Check if the NFC tag UID exists in the victim table
  Future<bool> victimExists(String ndefUID) async {
    final docRef = db.collection('victim').doc(ndefUID);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      return true;
    } else {
      return false;
    }
  }

  void _tagRead() {
    setState(() {
      _nfcSessionRunning = true;
      _dialogText = 'Etiket aranıyor...';
    });

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      // Get ndefUID from NFC tag
      var ndefUID = tag.data["ndef"]["identifier"]
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join('');

      final timeoutDurationRead = Duration(seconds: 5);
      final timeoutFutureRead = Future.delayed(timeoutDurationRead);

      final victimExistsFuture = victimExists(ndefUID);

      try {
        // Wait for either the victimExists to complete or the timeout to occur
        await Future.any([victimExistsFuture, timeoutFutureRead]);

        setState(() {
          _dialogText = 'Profil yükleniyor...';
        });

        // Start the timeout timer
        final timeoutDuration = Duration(seconds: 5);
        final timeoutFuture = Future.delayed(timeoutDuration);

        // Write last active location of the NFC tag to database
        final writeLocationFuture = writeLocationToDB(ndefUID);

        try {
          // Wait for either the writeLocationToDB to complete or the timeout to occur
          await Future.any([writeLocationFuture, timeoutFuture]);

          setState(() {
            _nfcSessionRunning = false;
            _dialogText = 'Etiket aranıyor...';
          });

          // Access database with Unique ID => ndefUID
          Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => SurvivorReadPage(ndefUID: ndefUID,)),
          );
        } catch (error) {
          print('Error: $error');

          setState(() {
            _nfcSessionRunning = false;
            _dialogText = 'Etiket aranıyor...';
          });

          // Access database with Unique ID => ndefUID
          Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => SurvivorReadPage(ndefUID: ndefUID,)),
          );
        }
      } catch (error) {
        print('Error: $error');

        setState(() {
          _nfcSessionRunning = false;
          _dialogText = 'Etiket aranıyor...';
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Depremzede kaydı bulunamadı.')));
      }

      NfcManager.instance.stopSession();
    });
  }


  void _ndefWrite() {
    setState(() {
      _nfcSessionRunning = true;
      _dialogText = 'Etiket aranıyor...';
    });

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      // Get UID
      var ndefUID = tag.data["ndef"]["identifier"]
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join('');

      setState(() {
        _dialogText = 'Profil yükleniyor...';
      });

      // Start the timeout timer
      final timeoutDuration = Duration(seconds: 5);
      final timeoutFuture = Future.delayed(timeoutDuration);

      // Write last active location of the NFC tag to database
      final writeLocationFuture = writeLocationToDB(ndefUID);

      try {
        // Wait for either the writeLocationToDB to complete or the timeout to occur
        await Future.any([writeLocationFuture, timeoutFuture]);

        setState(() {
          _nfcSessionRunning = false;
          _dialogText = 'Etiket aranıyor...';
        });

        // Fetch from database with UID
        Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (context) => SurvivorWritePage(ndefUID: ndefUID, userID: widget.username,)),
        );
      } catch (error) {
        print('Error: $error');

        setState(() {
          _nfcSessionRunning = false;
          _dialogText = 'Etiket aranıyor...';
        });

        // Fetch from database with UID
        Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (context) => SurvivorWritePage(ndefUID: ndefUID, userID: widget.username,)),
        );
      }

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

      final timeoutDurationRead = Duration(seconds: 5);
      final timeoutFutureRead = Future.delayed(timeoutDurationRead);

      final victimExistsFuture = victimExists(ndefUID);

      try {
        // Wait for either the victimExists to complete or the timeout to occur
        await Future.any([victimExistsFuture, timeoutFutureRead]);

        setState(() {
          _dialogText = 'Profil yükleniyor...';
        });

        // Start the timeout timer
        final timeoutDuration = Duration(seconds: 5);
        final timeoutFuture = Future.delayed(timeoutDuration);

        // Write last active location of the NFC tag to database
        final writeLocationFuture = writeLocationToDB(ndefUID);

        try {
          // Wait for either the writeLocationToDB to complete or the timeout to occur
          await Future.any([writeLocationFuture, timeoutFuture]);

          setState(() {
            _nfcSessionRunning = false;
            _dialogText = 'Etiket aranıyor...';
          });

          // Fetch from database with UID
          Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => RoleBasedRecordWritePage(
              ndefUID: ndefUID,
              username: widget.username,
              role: _userRole,
            )),
          );
        } catch (error) {
          print('Error: $error');

          setState(() {
            _nfcSessionRunning = false;
            _dialogText = 'Etiket aranıyor...';
          });

          // Fetch from database with UID
          Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => RoleBasedRecordWritePage(
              ndefUID: ndefUID,
              username: widget.username,
              role: _userRole,
            )),
          );
        }
      } catch (error) {
        print('Error: $error');

        setState(() {
          _nfcSessionRunning = false;
          _dialogText = 'Etiket aranıyor...';
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lütfen önce etikete yazınız.')));
      }

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

        _roleExists = data['burial'] ?? false;
        if (_roleExists) {
          _userRole = 'burial';
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

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> writeLocationToDB(String ndefUID) async {
    try {
      final docRef = db.collection('victim').doc(ndefUID);
      Map<String, dynamic> record = {};

      final hasPermission = await _handleLocationPermission();

      if(hasPermission) {
        // location permission is granted (or was already granted before making the request)

        // get last known location, which is a future rather than a stream
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        double lat = position.latitude;
        double long = position.longitude;

        record['latest_latitude'] = lat;
        record['latest_longitude'] = long;

        final docSnap = await docRef.get();
        if (docSnap.exists) {
          await docRef.update(record);
        } else {
          await docRef.set(record);
        }

      } else {
        // location permission is not granted
        // user might have denied, but it's also possible that location service is not enabled, restricted, and user never saw the permission request dialog.
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Depremzede lokasyonu güncellemek için konum servislerini açın.')));
      }
    } catch (e) {
      throw Exception('Failed to update location');
    }
  }
}
