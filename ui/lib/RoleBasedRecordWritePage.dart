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
    'clinic': ['stay_status', 'enter_datetime', 'discharge_datetime', 'notes'],
    'er': ['stay_status', 'enter_datetime', 'discharge_datetime', 'notes'],
    'firstaid': ['victim_condition', 'applied_date', 'notes'],
    'morgue': ['stay_status', 'enter_datetime', 'discharge_datetime', 'notes'],
    'rescue': ['rescue_datetime', 'longitude', 'latitude', 'city',
                'province', 'neighbourhood', 'street', 'building'],
  };

  final Map<int, String> _victimConditions = {
    0: 'Hafif Yaralı',
    1: 'Yaralı',
    2: 'Ağır Yaralı',
    3: 'Ölü'
  };

  final Color _selectedBoxColor = Colors.blue;
  final Color _unselectedBoxColor = Colors.transparent;
  final Color _selectedTextColor = Colors.white;
  final Color _unselectedTextColor = Colors.blue;

  bool stay_status = false;

  bool _isEnterDateSelected = false;
  bool _isDischargeDateSelected = false;
  bool _isAppliedDateSelected = false;
  bool _isRescueDateSelected = false;

  int victimCondition = -1;
  double longitude = 0.0;
  double latitude = 0.0;
  DateTime enterDate = DateTime.now();
  DateTime dischargeDate = DateTime.now();
  DateTime appliedDate = DateTime.now();
  DateTime rescueDate = DateTime.now();
  String notes = 'Girilmemiş';
  String city = 'Girilmemiş';
  String province = 'Girilmemiş';
  String neighbourhood = 'Girilmemiş';
  String street = 'Girilmemiş';
  String building = 'Girilmemiş';

  final TextEditingController _notesInputController = TextEditingController();
  final TextEditingController _cityInputController = TextEditingController();
  final TextEditingController _provinceInputController = TextEditingController();
  final TextEditingController _neighbourhoodInputController = TextEditingController();
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
                visible: _dbFields[widget.role]?.contains('enter_datetime') ?? false,
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
                visible: _dbFields[widget.role]?.contains('discharge_datetime') ?? false,
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
                visible: _dbFields[widget.role]?.contains('applied_date') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İlk Yardım Uygulama Tarihi',
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
                        child: Text(_isDischargeDateSelected ? dischargeDate.toString() : 'İlk Yardım Uygulama Tarihi Seç'),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('rescue_datetime') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Depremzede Kurtarma Tarihi',
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
                        child: Text(_isDischargeDateSelected ? dischargeDate.toString() : 'Depremzede Kurtarma Tarihi Seç'),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('victim_condition') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Depremzede Sağlık Durumu',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      SizedBox(
                        height: 50, // adjust the height as needed
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _victimConditions.length,
                          itemBuilder: (context, index) {
                            final key = _victimConditions.keys.elementAt(index);
                            final value = _victimConditions.values.elementAt(index);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    victimCondition = key;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    width: 1.0,
                                    color: Colors.blue,
                                  ),
                                  backgroundColor: victimCondition == key ? _selectedBoxColor : _unselectedBoxColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: victimCondition == key ? _selectedTextColor : _unselectedTextColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('city') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _cityInputController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'İl',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('province') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _provinceInputController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'İlçe',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('neighbourhood') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _neighbourhoodInputController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Mahalle',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('street') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _streetInputController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Cadde',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('building') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _buildingInputController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Bina Adı',
                        ),
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
        if (data.containsKey('enter_datetime') && data['enter_datetime'] != null) {
          enterDate = DateTime.fromMillisecondsSinceEpoch(data['enter_datetime'] * 1000);
          _isEnterDateSelected = true;
        }

        if (data.containsKey('discharge_datetime') && data['discharge_datetime'] != null) {
          dischargeDate = DateTime.fromMillisecondsSinceEpoch(data['discharge_datetime'] * 1000);
          _isDischargeDateSelected = true;
        }

        if (data.containsKey('applied_date') && data['applied_date'] != null) {
          appliedDate = DateTime.fromMillisecondsSinceEpoch(data['applied_date'] * 1000);
          _isAppliedDateSelected = true;
        }

        if (data.containsKey('rescue_datetime') && data['rescue_datetime'] != null) {
          rescueDate = DateTime.fromMillisecondsSinceEpoch(data['rescue_datetime'] * 1000);
          _isRescueDateSelected = true;
        }

        city = data.containsKey('city') && data['city'] != null
            ? data['city'].toString()
            : city;
        _cityInputController.text = city;

        province = data.containsKey('province') && data['province'] != null
            ? data['province'].toString()
            : province;
        _provinceInputController.text = province;

        neighbourhood = data.containsKey('neighbourhood') && data['neighbourhood'] != null
            ? data['neighbourhood'].toString()
            : neighbourhood;
        _neighbourhoodInputController.text = neighbourhood;

        street = data.containsKey('street') && data['street'] != null
            ? data['street'].toString()
            : street;
        _streetInputController.text = street;

        building = data.containsKey('building') && data['building'] != null
            ? data['building'].toString()
            : building;
        _buildingInputController.text = building;

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
        // Write discharge record, set stay_status to 0
        record['stay_status'] = false;
        record['discharge_datetime'] = Timestamp.fromDate(dischargeDate);
      } else {
        record['stay_status'] = true;
      }

      if (_isEnterDateSelected) {
        record['enter_datetime'] = Timestamp.fromDate(enterDate);
      }

      if (_isAppliedDateSelected) {
        record['applied_datetime'] = Timestamp.fromDate(appliedDate);
      }

      if (_isRescueDateSelected) {
        record['rescue_datetime'] = Timestamp.fromDate(rescueDate);
      }

      if (victimCondition != -1) {
        record['victim_condition'] = victimCondition;
      }

      if (_cityInputController.text.isNotEmpty) {
        record['city'] = _cityInputController.text;
      }

      if (_provinceInputController.text.isNotEmpty) {
        record['province'] = _provinceInputController.text;
      }

      if (_neighbourhoodInputController.text.isNotEmpty) {
        record['neighbourhood'] = _neighbourhoodInputController.text;
      }

      if (_streetInputController.text.isNotEmpty) {
        record['street'] = _streetInputController.text;
      }

      if (_buildingInputController.text.isNotEmpty) {
        record['building'] = _buildingInputController.text;
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
