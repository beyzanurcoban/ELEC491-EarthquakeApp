import 'dart:convert';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoleBasedRecordWritePage extends StatefulWidget {
  final String ndefUID;
  final String username;
  final String role;

  const RoleBasedRecordWritePage({
    super.key,
    required this.ndefUID,
    required this.username,
    required this.role
  });

  @override
  _RoleBasedRecordWritePageState createState() => _RoleBasedRecordWritePageState();
}

class _RoleBasedRecordWritePageState extends State<RoleBasedRecordWritePage> {
  final Map<String, String> _roles = {
    'clinic': 'Hastane',
    'er': 'Acil',
    'firstaid': 'İlk Yardım',
    'morgue': 'Morg',
    'rescue': 'Arama-Kurtarma',
    'ambulance': 'Ambulans',
    'none': 'Yok'
  };

  final Map<String, List<String>> _dbFields = {
    'clinic': ['stat', 'enter_date', 'discharge_date', 'notes'],
    'er': ['stat', 'enter_date', 'discharge_date', 'notes'],
    'firstaid': ['victim_cond', 'applied_date', 'notes'],
    'morgue': ['stat', 'enter_date', 'discharge_date', 'notes'],
    'rescue': ['rescue_date', 'longitude', 'latitude', 'province',
                'city', 'district', 'street', 'building'],
  };

  bool stat = false;

  bool _isEnterDateSelected = false;
  bool _isDischargeDateSelected = false;

  int victimCond = 0;
  double longitude = 0.0;
  double latitude = 0.0;
  DateTime enterDate = DateTime.now();
  DateTime dischargeDate = DateTime.now();
  DateTime appliedDate = DateTime.now();
  DateTime rescueDate = DateTime.now();
  String notes = 'Girilmemiş';
  String province = 'Girilmemiş';
  String city = 'Girilmemiş';
  String district = 'Girilmemiş';
  String street = 'Girilmemiş';
  String building = 'Girilmemiş';

  final TextEditingController _notesInputController = TextEditingController();
  final TextEditingController _provinceInputController = TextEditingController();
  final TextEditingController _cityInputController = TextEditingController();
  final TextEditingController _districtInputController = TextEditingController();
  final TextEditingController _streetInputController = TextEditingController();
  final TextEditingController _buildingInputController = TextEditingController();

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();

    // Connect to DB
    db = FirebaseFirestore.instance;

    // Get current data from DB
    getRecordFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text(
          "${_roles[widget.role]} Kaydı",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                child: Text(
                  "Depremzede Etiket ID: ${widget.ndefUID}\n"
                      "Kullanıcı: ${widget.username}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Colors.black38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('enter_date') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giriş Tarihi',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _isEnterDateSelected = true;
                              enterDate = selectedDate;
                            });
                          }
                        },
                        child: Text(_isEnterDateSelected ? enterDate.toString() : 'Giriş Tarihi Seç'),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('discharge_date') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Çıkış Tarihi',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _isDischargeDateSelected = true;
                              dischargeDate = selectedDate;
                            });
                          }
                        },
                        child: Text(_isDischargeDateSelected ? dischargeDate.toString() : 'Çıkış Tarihi Seç'),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('notes') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _notesInputController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Notlar',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      writeRecordToDB();
                      Navigator.pop(context);
                    },
                    child: const Text('Kayıt Gir'),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }


  Future<void> getRecordFromDB() async {
    final docRef = db.collection(widget.role).doc(widget.ndefUID);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      setState(() {
        if (data.containsKey('enter_date') && data['enter_date'] != null) {
          enterDate = DateTime.fromMillisecondsSinceEpoch(data['enter_date'] * 1000);
          _isEnterDateSelected = true;
        }

        if (data.containsKey('discharge_date') && data['discharge_date'] != null) {
          dischargeDate = DateTime.fromMillisecondsSinceEpoch(data['discharge_date'] * 1000);
          _isDischargeDateSelected = true;
        }

        notes = data.containsKey('notes') && data['notes'] != null
            ? data['notes'].toString()
            : notes;
        _notesInputController.text = notes;
      });
    } else {
      throw Exception('Failed to fetch record');
    }
  }

  Future<void> writeRecordToDB() async {
    try {
      final docRef = db.collection(widget.role).doc(widget.ndefUID);

      Map<String, dynamic> record = {};
      if (_isDischargeDateSelected) {
        // Write discharge record, set stat to 0
        record['stat'] = false;
        record['discharge_date'] = Timestamp.fromDate(dischargeDate);
      } else {
        record['stat'] = true;
      }

      if (_isEnterDateSelected) {
        record['enter_date'] = Timestamp.fromDate(enterDate);
      }

      if (_notesInputController.text.isNotEmpty) {
        record['notes'] = _notesInputController.text;
      }

      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.update(record);
      } else {
        await docRef.set(record);
      }

    } catch (e) {
      throw Exception('Failed to update record');
    }
  }
}
