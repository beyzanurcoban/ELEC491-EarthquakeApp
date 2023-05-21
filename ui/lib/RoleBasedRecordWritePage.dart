import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

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
    'burial': 'Mezarlık-Defin',
    'none': 'Yok'
  };

  final Map<String, List<String>> _dbFields = {
    'clinic': ['stay_status', 'hospital_id', 'enter_datetime', 'discharge_datetime', 'notes'],
    'er': ['stay_status', 'hospital_id', 'enter_datetime', 'discharge_datetime', 'notes'],
    'firstaid': ['plate_number', 'victim_condition', 'applied_datetime', 'notes'],
    'morgue': ['stay_status', 'hospital_id', 'enter_datetime', 'discharge_datetime', 'notes'],
    'rescue': ['rescue_datetime', 'longitude', 'latitude', 'city',
                'province', 'neighbourhood', 'street', 'building'],
    'burial': ['cemetery_id', 'grave_number', 'burial_datetime', 'notes'],
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

  bool stayStatus = false;

  bool _isEnterDateSelected = false;
  bool _isDischargeDateSelected = false;
  bool _isAppliedDateSelected = false;
  bool _isRescueDateSelected = false;
  bool _isBurialDateSelected = false;

  int victimCondition = -1;
  double longitude = 0.0;
  double latitude = 0.0;
  DateTime enterDate = DateTime.now();
  DateTime dischargeDate = DateTime.now();
  DateTime appliedDate = DateTime.now();
  DateTime rescueDate = DateTime.now();
  DateTime burialDate = DateTime.now();
  String notes = 'Girilmemiş';
  String graveNumber = 'Girilmemiş';
  String city = 'Girilmemiş';
  String province = 'Girilmemiş';
  String neighbourhood = 'Girilmemiş';
  String street = 'Girilmemiş';
  String building = 'Girilmemiş';

  final TextEditingController _notesInputController = TextEditingController();
  final TextEditingController _graveNumberInputController = TextEditingController();
  final TextEditingController _neighbourhoodInputController = TextEditingController();
  final TextEditingController _streetInputController = TextEditingController();
  final TextEditingController _buildingInputController = TextEditingController();

  // Holds Keys from Master tables
  String _selectedHospitalID = '';
  String _selectedHospitalName = '';
  String _selectedCemeteryID = '';
  String _selectedCemeteryName = '';
  String _selectedPlateNumber = '';

  // Fill these from Master tables in DB
  Map<String, String> _hospitalIDtoName = {};
  Map<String, String> _cemeteryIDtoName = {};
  List<String> _plateNumbers = [];

  late FirebaseFirestore db;

  List<String> _provinces = []; // stores the provinces from the JSON data
  Map<String, List<String>> _cities = {}; // stores the cities by province

  String _selectedProvince = '';
  String _selectedCity = '';

  @override
  void initState() {
    super.initState();

    // Connect to DB
    db = FirebaseFirestore.instance;

    // Get current data from DB
    getRecordFromDB();
    _populateProvinces();
    _populateCities();
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
                visible: _dbFields[widget.role]?.contains('hospital_id') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hastane',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      FutureBuilder(
                        future: _getHospitals(),
                        builder: (context, snapshot) {
                          return DropdownSearch(
                            clearButtonProps: ClearButtonProps(
                              isVisible: _selectedHospitalName != '',
                              onPressed: () {
                                setState(() {
                                  _selectedHospitalName = '';
                                });
                              }
                            ),
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                      hintText: 'Buradan hastane arayın.'
                                  )
                              ),
                            ),
                            selectedItem: _selectedHospitalName,
                            items: _hospitalIDtoName.values.toList(),
                            onChanged: (selectedItem) {
                              setState(() {
                                _selectedHospitalName = selectedItem!;
                                _selectedHospitalID = _hospitalIDtoName.keys.firstWhere((id) => _hospitalIDtoName[id] == _selectedHospitalName);
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('cemetery_id') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mezarlık',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      FutureBuilder(
                        future: _getCemeteries(),
                        builder: (context, snapshot) {
                          return DropdownSearch(
                            clearButtonProps: ClearButtonProps(
                              isVisible: _selectedCemeteryName != '',
                              onPressed: () {
                                setState(() {
                                  _selectedCemeteryName = '';
                                });
                              }
                            ),
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                      hintText: 'Buradan mezarlık arayın.'
                                  )
                              ),
                            ),
                            selectedItem: _selectedCemeteryName,
                            items: _cemeteryIDtoName.values.toList(),
                            onChanged: (selectedItem) {
                              setState(() {
                                _selectedCemeteryName = selectedItem!;
                                _selectedCemeteryID = _cemeteryIDtoName.keys.firstWhere((id) => _cemeteryIDtoName[id] == _selectedCemeteryName);
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('plate_number') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ambulans Plakası',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      FutureBuilder(
                        future: _getPlateNumbers(),
                        builder: (context, snapshot) {
                          return DropdownSearch<String>(
                            clearButtonProps: ClearButtonProps(
                              isVisible: _selectedPlateNumber != '',
                              onPressed: () {
                                setState(() {
                                  _selectedPlateNumber = '';
                                });
                              }
                            ),
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  hintText: 'Buradan plaka arayın.'
                                )
                              ),
                            ),
                            selectedItem: _selectedPlateNumber,
                            items: _plateNumbers,
                            onChanged: (selectedItem) {
                              setState(() {
                                _selectedPlateNumber = selectedItem!;
                              });
                            },
                          );
                        },
                      ),
                    ],
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
                            initialDate: enterDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          ).then((selectedDate) {
                            if (selectedDate != null) {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(selectedDate),
                              ).then((selectedTime) {
                                if (selectedTime != null) {
                                  setState(() {
                                    _isEnterDateSelected = true;
                                    enterDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );
                                  });
                                }
                              });
                            }
                            return null;
                          });
                        },
                        child: Text(_isEnterDateSelected ? enterDate.toString() : 'Giriş Tarihi Seçin'),
                      ),
                    ]
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
                            initialDate: dischargeDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          ).then((selectedDate) {
                            if (selectedDate != null) {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(selectedDate),
                              ).then((selectedTime) {
                                if (selectedTime != null) {
                                  setState(() {
                                    _isDischargeDateSelected = true;
                                    dischargeDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );
                                  });
                                }
                              });
                            }
                            return null;
                          });
                        },
                        child: Text(_isDischargeDateSelected ? dischargeDate.toString() : 'Çıkış Tarihi Seç'),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('applied_datetime') ?? false,
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
                            initialDate: appliedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          ).then((selectedDate) {
                            if (selectedDate != null) {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(selectedDate),
                              ).then((selectedTime) {
                                if (selectedTime != null) {
                                  setState(() {
                                    _isAppliedDateSelected = true;
                                    appliedDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );
                                  });
                                }
                              });
                            }
                            return null;
                          });
                        },
                        child: Text(appliedDate.toString()),
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
                            initialDate: rescueDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          ).then((selectedDate) {
                            if (selectedDate != null) {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(selectedDate),
                              ).then((selectedTime) {
                                if (selectedTime != null) {
                                  setState(() {
                                    _isRescueDateSelected = true;
                                    rescueDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );
                                  });
                                }
                              });
                            }
                            return null;
                          });
                        },
                        child: Text(_isRescueDateSelected ? rescueDate.toString() : DateTime.now().toString()),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('burial_datetime') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Defnedilme Tarihi',
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
                            initialDate: burialDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          ).then((selectedDate) {
                            if (selectedDate != null) {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(selectedDate),
                              ).then((selectedTime) {
                                if (selectedTime != null) {
                                  setState(() {
                                    _isBurialDateSelected = true;
                                    burialDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );
                                  });
                                }
                              });
                            }
                            return null;
                          });
                        },
                        child: Text(_isBurialDateSelected ? burialDate.toString() : DateTime.now().toString()),
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
                visible: _dbFields[widget.role]?.contains('province') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İl',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      DropdownSearch<String>(
                        clearButtonProps: ClearButtonProps(
                            isVisible: _selectedProvince != '',
                            onPressed: () {
                              setState(() {
                                _selectedProvince = '';
                              });
                            }
                        ),
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                  hintText: 'Buradan il arayın.'
                              )
                          ),
                        ),
                        selectedItem: _selectedProvince,
                        items: _provinces.toList(),
                        onChanged: (selectedItem) {
                          setState(() {
                            _selectedProvince = selectedItem!;
                          });
                        },
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
                      const Text(
                        'İlçe',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      DropdownSearch<String>(
                        clearButtonProps: ClearButtonProps(
                            isVisible: _selectedCity != '',
                            onPressed: () {
                              setState(() {
                                _selectedCity = '';
                              });
                            }
                        ),
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                  hintText: 'Buradan ilçe arayın.'
                              )
                          ),
                        ),
                        selectedItem: _selectedCity,
                        items: _selectedProvince != null && _selectedProvince.isNotEmpty
                        ? [...?_cities[_selectedProvince]]
                        : [],
                        onChanged: (selectedItem) {
                          setState(() {
                            _selectedCity = selectedItem!;
                          });
                        },
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
                      const Text(
                        'Mahalle',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextFormField(
                        controller: _neighbourhoodInputController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: neighbourhood,
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
                      const Text(
                        'Sokak',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextFormField(
                        controller: _streetInputController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: street,
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
                      const Text(
                        'Bina',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextFormField(
                        controller: _buildingInputController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: building,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _dbFields[widget.role]?.contains('grave_number') ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mezarlık Numarası',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextFormField(
                        controller: _graveNumberInputController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: graveNumber,
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
                      const Text(
                        'Notlar',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextFormField(
                        controller: _notesInputController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: notes,
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

  Future<void> _populateProvinces() async {
    List<String> provs = ['Adana', 'Adıyaman', 'Afyon', 'Ağrı', 'Amasya', 'Ankara', 'Antalya', 'Artvin',
        'Aydın', 'Balıkesir', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale',
        'Çankırı', 'Çorum', 'Denizli', 'Diyarbakır', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir',
        'Gaziantep', 'Giresun', 'Gümüşhane', 'Hakkari', 'Hatay', 'Isparta', 'Mersin', 'İstanbul', 'İzmir',
        'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir', 'Kocaeli', 'Konya', 'Kütahya', 'Malatya',
        'Manisa', 'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş', 'Nevşehir', 'Niğde', 'Ordu', 'Rize', 'Sakarya',
        'Samsun', 'Siirt', 'Sinop', 'Sivas', 'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak',
        'Van', 'Yozgat', 'Zonguldak', 'Aksaray', 'Bayburt', 'Karaman', 'Kırıkkale', 'Batman', 'Şırnak',
        'Bartın', 'Ardahan', 'Iğdır', 'Yalova', 'Karabük', 'Kilis', 'Osmaniye', 'Düzce'];

    for (var i=0; i<provs.length; i++) {
      _provinces.add(provs[i]);
    }
  }

  Future<void> _populateCities() async {
    Map<String, List<String>> cits = {
      'Adana': ['Aladağ', 'Ceyhan', 'Çukurova', 'Feke', 'İmamoğlu', 'Karaisalı', 'Karataş', 'Kozan', 'Pozantı',
        'Saimbeyli', 'Sarıçam', 'Seyhan', 'Tufanbeyli', 'Yumurtalık', 'Yüreğir'],
      'Adıyaman': ['Besni', 'Çelikhan', 'Gerger', 'Gölbaşı', 'Kahta', 'Merkez', 'Samsat', 'Sincik', 'Tut'],
      'Afyonkarahisar': ['Başmakçı', 'Bayat', 'Bolvadin', 'Çay', 'Çobanlar', 'Dazkırı', 'Dinar', 'Emirdağ', 'Evciler', 'Hocalar',
    'İhsaniye', 'İscehisar', 'Kızılören', 'Merkez', 'Sandıklı', 'Sinanpaşa', 'Sultandağı', 'Şuhut'],
      'Ağrı': ['Diyadin', 'Doğubayazıt', 'Eleşkirt', 'Hamur', 'Merkez', 'Patnos', 'Taşlıçay', 'Tutak'],
      'Amasya': ['Göynücek', 'Gümüşhacıköy', 'Hamamözü', 'Merkez', 'Merzifon', 'Suluova', 'Taşova'],
      'Ankara': ['Akyurt', 'Altındağ', 'Ayaş', 'Bala', 'Beypazarı', 'Çamlıdere', 'Çankaya', 'Çubuk', 'Elmadağ',
    'Etimesgut', 'Evren', 'Gölbaşı', 'Güdül', 'Haymana', 'Kahramankazan', 'Kalecik', 'Keçiören', 'Kızılcahamam',
    'Mamak', 'Nallıhan', 'Polatlı', 'Pursaklar', 'Sincan', 'Şereflikoçhisar', 'Yenimahalle'],
      'Antalya': ['Akseki', 'Aksu', 'Alanya', 'Demre', 'Döşemealtı', 'Elmalı', 'Finike', 'Gazipaşa', 'Gündoğmuş', 'İbradı',
    'Kaş', 'Kemer', 'Kepez', 'Konyaaltı', 'Korkuteli', 'Kumluca', 'Manavgat', 'Muratpaşa', 'Serik'],
      'Artvin': ['Ardanuç', 'Arhavi', 'Borçka', 'Hopa', 'Kemalpaşa', 'Merkez', 'Murgul', 'Şavşat', 'Yusufeli'],
      'Aydın': ['Bozdoğan', 'Buharkent', 'Çine', 'Didim', 'Efeler', 'Germencik', 'İncirliova', 'Karacasu', 'Karpuzlu',
    'Koçarlı', 'Köşk', 'Kuşadası', 'Kuyucak', 'Nazilli', 'Söke', 'Sultanhisar', 'Yenipazar'],
      'Balıkesir': ['Altıeylül', 'Ayvalık', 'Balya', 'Bandırma', 'Bigadiç', 'Burhaniye', 'Dursunbey', 'Edremit', 'Erdek',
    'Gömeç', 'Gönen', 'Havran', 'İvrindi', 'Karesi', 'Kepsut', 'Manyas', 'Marmara', 'Savaştepe', 'Sındırgı',
    'Susurluk'],
      'Bilecik': ['Bozüyük', 'Gölpazarı', 'İnhisar', 'Merkez', 'Osmaneli', 'Pazaryeri', 'Söğüt', 'Yenipazar'],
      'Bingöl': ['Adaklı', 'Genç', 'Karlıova', 'Kiğı', 'Merkez', 'Solhan', 'Yayladere', 'Yedisu'],
      'Bitlis': ['Adilcevaz', 'Ahlat', 'Güroymak', 'Hizan', 'Merkez', 'Mutki', 'Tatvan'],
      'Bolu': ['Dörtdivan', 'Gerede', 'Göynük', 'Kıbrıscık', 'Mengen', 'Merkez', 'Mudurnu', 'Seben', 'Yeniçağa'],
      'Burdur': ['Ağlasun', 'Altınyayla', 'Bucak', 'Çavdır', 'Çeltikçi', 'Gölhisar', 'Karamanlı', 'Kemer', 'Merkez',
    'Tefenni', 'Yeşilova'],
      'Bursa': ['Büyükorhan', 'Gemlik', 'Gürsu', 'Harmancık', 'İnegöl', 'İznik', 'Karacabey', 'Keles', 'Kestel',
    'Mudanya', 'Mustafakemalpaşa', 'Nilüfer', 'Orhaneli', 'Orhangazi', 'Osmangazi', 'Yenişehir', 'Yıldırım'],
      'Çanakkale': ['Ayvacık', 'Bayramiç', 'Biga', 'Bozcaada', 'Çan', 'Eceabat', 'Ezine', 'Gelibolu', 'Gökçeada', 'Lapseki',
    'Merkez', 'Yenice'],
      'Çankırı': ['Atkaracalar', 'Bayramören', 'Çerkeş', 'Eldivan', 'Ilgaz', 'Kızılırmak', 'Korgun', 'Kurşunlu', 'Merkez',
    'Orta', 'Şabanözü', 'Yapraklı'],
      'Çorum': ['Alaca', 'Bayat', 'Boğazkale', 'Dodurga', 'İskilip', 'Kargı', 'Laçin', 'Mecitözü', 'Merkez', 'Oğuzlar',
    'Ortaköy', 'Osmancık', 'Sungurlu', 'Uğurludağ'],
      'Denizli': ['Acıpayam', 'Babadağ', 'Baklan', 'Bekilli', 'Beyağaç', 'Bozkurt', 'Buldan', 'Çal', 'Çameli', 'Çardak',
    'Çivril', 'Güney', 'Honaz', 'Kale', 'Merkezefendi', 'Pamukkale', 'Sarayköy', 'Serinhisar', 'Tavas'],
      'Diyarbakır': ['Bağlar', 'Bismil', 'Çermik', 'Çınar', 'Çüngüş', 'Dicle', 'Eğil', 'Ergani', 'Hani', 'Hazro', 'Kayapınar',
    'Kocaköy', 'Kulp', 'Lice', 'Silvan', 'Sur', 'Yenişehir'],
      'Edirne': ['Enez', 'Havsa', 'İpsala', 'Keşan', 'Lalapaşa', 'Meriç', 'Merkez', 'Süloğlu', 'Uzunköprü'],
      'Elazığ': ['Ağın', 'Alacakaya', 'Arıcak', 'Baskil', 'Karakoçan', 'Keban', 'Kovancılar', 'Maden', 'Merkez', 'Palu',
    'Sivrice'],
      'Erzincan': ['Çayırlı', 'İliç', 'Kemah', 'Kemaliye', 'Merkez', 'Otlukbeli', 'Refahiye', 'Tercan', 'Üzümlü'],
      'Erzurum': ['Aşkale', 'Aziziye', 'Çat', 'Hınıs', 'Horasan', 'İspir', 'Karaçoban', 'Karayazı', 'Köprüköy', 'Narman',
    'Oltu', 'Olur', 'Palandöken', 'Pasinler', 'Pazaryolu', 'Şenkaya', 'Tekman', 'Tortum', 'Uzundere', 'Yakutiye'],
      'Eskişehir': ['Alpu', 'Beylikova', 'Çifteler', 'Günyüzü', 'Han', 'İnönü', 'Mahmudiye', 'Mihalgazi', 'Mihalıççık',
    'Odunpazarı', 'Sarıcakaya', 'Seyitgazi', 'Sivrihisar', 'Tepebaşı'],
      'Gaziantep': ['Araban', 'İslahiye', 'Karkamış', 'Nizip', 'Nurdağı', 'Oğuzeli', 'Şahinbey', 'Şehitkamil', 'Yavuzeli'],
      'Giresun': ['Alucra', 'Bulancak', 'Çamoluk', 'Çanakçı', 'Dereli', 'Doğankent', 'Espiye', 'Eynesil', 'Görele', 'Güce',
    'Keşap', 'Merkez', 'Piraziz', 'Şebinkarahisar', 'Tirebolu', 'Yağlıdere'],
      'Gümüşhane': ['Kelkit', 'Köse', 'Kürtün', 'Merkez', 'Şiran', 'Torul'],
      'Hakkari': ['Çukurca', 'Derecik', 'Merkez', 'Şemdinli', 'Yüksekova'],
      'Hatay': ['Altınözü', 'Antakya', 'Arsuz', 'Belen', 'Defne', 'Dörtyol', 'Erzin', 'Hassa', 'İskenderun', 'Kırıkhan',
    'Kumlu', 'Payas', 'Reyhanlı', 'Samandağ', 'Yayladağı'],
      'Isparta': ['Aksu', 'Atabey', 'Eğirdir', 'Gelendost', 'Gönen', 'Keçiborlu', 'Merkez', 'Senirkent', 'Sütçüler',
    'Şarkikaraağaç', 'Uluborlu', 'Yalvaç', 'Yenişarbademli'],
      'Mersin': ['Akdeniz', 'Anamur', 'Aydıncık', 'Bozyazı', 'Çamlıyayla', 'Erdemli', 'Gülnar', 'Mezitli', 'Mut',
    'Silifke', 'Tarsus', 'Toroslar', 'Yenişehir'],
      'İstanbul': ['Adalar', 'Arnavutköy', 'Ataşehir', 'Avcılar', 'Bağcılar', 'Bahçelievler', 'Bakırköy', 'Başakşehir',
    'Bayrampaşa', 'Beşiktaş', 'Beykoz', 'Beylikdüzü', 'Beyoğlu', 'Büyükçekmece', 'Çatalca', 'Çekmeköy', 'Esenler',
    'Esenyurt', 'Eyüpsultan', 'Fatih', 'Gaziosmanpaşa', 'Güngören', 'Kadıköy', 'Kağıthane', 'Kartal', 'Küçükçekmece',
    'Maltepe', 'Pendik', 'Sancaktepe', 'Sarıyer', 'Silivri', 'Sultanbeyli', 'Sultangazi', 'Şile', 'Şişli', 'Tuzla',
    'Ümraniye', 'Üsküdar', 'Zeytinburnu'],
      'İzmir': ['Aliağa', 'Balçova', 'Bayındır', 'Bayraklı', 'Bergama', 'Beydağ', 'Bornova', 'Buca', 'Çeşme', 'Çiğli',
    'Dikili', 'Foça', 'Gaziemir', 'Güzelbahçe', 'Karabağlar', 'Karaburun', 'Karşıyaka', 'Kemalpaşa', 'Kınık', 'Kiraz',
    'Konak', 'Menderes', 'Menemen', 'Narlıdere', 'Ödemiş', 'Seferihisar', 'Selçuk', 'Tire', 'Torbalı', 'Urla'],
      'Kars': ['Akyaka', 'Arpaçay', 'Digor', 'Kağızman', 'Merkez', 'Sarıkamış', 'Selim', 'Susuz'],
      'Kastamonu': ['Abana', 'Ağlı', 'Araç', 'Azdavay', 'Bozkurt', 'Cide', 'Çatalzeytin', 'Daday', 'Devrekani', 'Doğanyurt',
    'Hanönü', 'İhsangazi', 'İnebolu', 'Küre', 'Merkez', 'Pınarbaşı', 'Seydiler', 'Şenpazar', 'Taşköprü', 'Tosya'],
      'Kayseri': ['Akkışla', 'Bünyan', 'Develi', 'Felahiye', 'Hacılar', 'İncesu', 'Kocasinan', 'Melikgazi', 'Özvatan',
    'Pınarbaşı', 'Sarıoğlan', 'Sarız', 'Talas', 'Tomarza', 'Yahyalı', 'Yeşilhisar'],
      'Kırklareli': ['Babaeski', 'Demirköy', 'Kofçaz', 'Lüleburgaz', 'Merkez', 'Pehlivanköy', 'Pınarhisar', 'Vize'],
      'Kırşehir': ['Akçakent', 'Akpınar', 'Boztepe', 'Çiçekdağı', 'Kaman', 'Merkez', 'Mucur'],
      'Kocaeli': ['Başiskele', 'Çayırova', 'Darıca', 'Derince', 'Dilovası', 'Gebze', 'Gölcük', 'İzmit', 'Kandıra',
    'Karamürsel', 'Kartepe', 'Körfez'],
      'Konya': ['Ahırlı', 'Akören', 'Akşehir', 'Altınekin', 'Beyşehir', 'Bozkır', 'Cihanbeyli', 'Çeltik', 'Çumra',
    'Derbent', 'Derebucak', 'Doğanhisar', 'Emirgazi', 'Ereğli', 'Güneysınır', 'Hadim', 'Halkapınar', 'Hüyük', 'Ilgın',
    'Kadınhanı', 'Karapınar', 'Karatay', 'Kulu', 'Meram', 'Sarayönü', 'Selçuklu', 'Seydişehir', 'Taşkent', 'Tuzlukçu',
    'Yalıhüyük', 'Yunak'],
      'Kütahya': ['Altıntaş', 'Aslanapa', 'Çavdarhisar', 'Domaniç', 'Dumlupınar', 'Emet', 'Gediz', 'Hisarcık', 'Merkez',
    'Pazarlar', 'Simav', 'Şaphane', 'Tavşanlı'],
      'Malatya': ['Akçadağ', 'Arapgir', 'Arguvan', 'Battalgazi', 'Darende', 'Doğanşehir', 'Doğanyol', 'Hekimhan', 'Kale',
    'Kuluncak', 'Pütürge', 'Yazıhan', 'Yeşilyurt'],
      'Manisa': ['Ahmetli', 'Akhisar', 'Alaşehir', 'Demirci', 'Gölmarmara', 'Gördes', 'Kırkağaç', 'Köprübaşı', 'Kula',
    'Salihli', 'Sarıgöl', 'Saruhanlı', 'Selendi', 'Soma', 'Şehzadeler', 'Turgutlu', 'Yunusemre'],
      'Kahramanmaraş': ['Afşin', 'Andırın', 'Çağlayancerit', 'Dulkadiroğlu', 'Ekinözü', 'Elbistan', 'Göksun', 'Nurhak',
    'Onikişubat', 'Pazarcık', 'Türkoğlu'],
      'Mardin': ['Artuklu', 'Dargeçit', 'Derik', 'Kızıltepe', 'Mazıdağı', 'Midyat', 'Nusaybin', 'Ömerli', 'Savur',
    'Yeşilli'],
      'Muğla': ['Bodrum', 'Dalaman', 'Datça', 'Fethiye', 'Kavaklıdere', 'Köyceğiz', 'Marmaris', 'Menteşe', 'Milas',
    'Ortaca', 'Seydikemer', 'Ula', 'Yatağan'],
      'Muş': ['Bulanık', 'Hasköy', 'Korkut', 'Malazgirt', 'Merkez', 'Varto'],
      'Nevşehir': ['Acıgöl', 'Avanos', 'Derinkuyu', 'Gülşehir', 'Hacıbektaş', 'Kozaklı', 'Merkez', 'Ürgüp'],
      'Niğde': ['Altunhisar', 'Bor', 'Çamardı', 'Çiftlik', 'Merkez', 'Ulukışla'],
      'Ordu': ['Akkuş', 'Altınordu', 'Aybastı', 'Çamaş', 'Çatalpınar', 'Çaybaşı', 'Fatsa', 'Gölköy', 'Gülyalı',
    'Gürgentepe', 'İkizce', 'Kabadüz', 'Kabataş', 'Korgan', 'Kumru', 'Mesudiye', 'Perşembe', 'Ulubey', 'Ünye'],
      'Rize': ['Ardeşen', 'Çamlıhemşin', 'Çayeli', 'Derepazarı', 'Fındıklı', 'Güneysu', 'Hemşin', 'İkizdere', 'İyidere',
    'Kalkandere', 'Merkez', 'Pazar'],
      'Sakarya': ['Adapazarı', 'Akyazı', 'Arifiye', 'Erenler', 'Ferizli', 'Geyve', 'Hendek', 'Karapürçek', 'Karasu',
    'Kaynarca', 'Kocaali', 'Pamukova', 'Sapanca', 'Serdivan', 'Söğütlü', 'Taraklı'],
      'Samsun': ['19 Mayıs', 'Alaçam', 'Asarcık', 'Atakum', 'Ayvacık', 'Bafra', 'Canik', 'Çarşamba', 'Havza', 'İlkadım', 'Kavak',
    'Ladik', 'Salıpazarı', 'Tekkeköy', 'Terme', 'Vezirköprü', 'Yakakent'],
      'Siirt': ['Baykan', 'Eruh', 'Kurtalan', 'Merkez', 'Pervari', 'Şirvan', 'Tillo'],
      'Sinop': ['Ayancık', 'Boyabat', 'Dikmen', 'Durağan', 'Erfelek', 'Gerze', 'Merkez', 'Saraydüzü', 'Türkeli'],
      'Sivas': ['Akıncılar', 'Altınyayla', 'Divriği', 'Doğanşar', 'Gemerek', 'Gölova', 'Gürün', 'Hafik', 'İmranlı',
    'Kangal', 'Koyulhisar', 'Merkez', 'Suşehri', 'Şarkışla', 'Ulaş', 'Yıldızeli', 'Zara'],
      'Tekirdağ': ['Çerkezköy', 'Çorlu', 'Ergene', 'Hayrabolu', 'Kapaklı', 'Malkara', 'Marmaraereğlisi', 'Muratlı', 'Saray',
    'Süleymanpaşa', 'Şarköy'],
      'Tokat': ['Almus', 'Artova', 'Başçiftlik', 'Erbaa', 'Merkez', 'Niksar', 'Pazar', 'Reşadiye', 'Sulusaray', 'Turhal',
    'Yeşilyurt', 'Zile'],
      'Trabzon': ['Akçaabat', 'Araklı', 'Arsin', 'Beşikdüzü', 'Çarşıbaşı', 'Çaykara', 'Dernekpazarı', 'Düzköy', 'Hayrat',
    'Köprübaşı', 'Maçka', 'Of', 'Ortahisar', 'Sürmene', 'Şalpazarı', 'Tonya', 'Vakfıkebir', 'Yomra'],
      'Tunceli': ['Çemişgezek', 'Hozat', 'Mazgirt', 'Merkez', 'Nazımiye', 'Ovacık', 'Pertek', 'Pülümür'],
      'Şanlıurfa': ['Akçakale', 'Birecik', 'Bozova', 'Ceylanpınar', 'Eyyübiye', 'Halfeti', 'Haliliye', 'Harran', 'Hilvan',
    'Karaköprü', 'Siverek', 'Suruç', 'Viranşehir'],
      'Uşak': ['Banaz', 'Eşme', 'Karahallı', 'Merkez', 'Sivaslı', 'Ulubey'],
      'Van': ['Bahçesaray', 'Başkale', 'Çaldıran', 'Çatak', 'Edremit', 'Erciş', 'Gevaş', 'Gürpınar', 'İpekyolu',
    'Muradiye', 'Özalp', 'Saray', 'Tuşba'],
      'Yozgat': ['Akdağmadeni', 'Aydıncık', 'Boğazlıyan', 'Çandır', 'Çayıralan', 'Çekerek', 'Kadışehri', 'Merkez',
    'Saraykent', 'Sarıkaya', 'Sorgun', 'Şefaatli', 'Yenifakılı', 'Yerköy'],
      'Zonguldak': ['Alaplı', 'Çaycuma', 'Devrek', 'Ereğli', 'Gökçebey', 'Kilimli', 'Kozlu', 'Merkez'],
      'Aksaray': ['Ağaçören', 'Eskil', 'Gülağaç', 'Güzelyurt', 'Merkez', 'Ortaköy', 'Sarıyahşi', 'Sultanhanı'],
      'Bayburt': ['Aydıntepe', 'Demirözü', 'Merkez'],
      'Karaman': ['Ayrancı', 'Başyayla', 'Ermenek', 'Kazımkarabekir', 'Merkez', 'Sarıveliler'],
      'Kırıkkale': ['Bahşılı', 'Balışeyh', 'Çelebi', 'Delice', 'Karakeçili', 'Keskin', 'Merkez', 'Sulakyurt', 'Yahşihan'],
      'Batman': ['Beşiri', 'Gercüş', 'Hasankeyf', 'Kozluk', 'Merkez', 'Sason'],
      'Şırnak': ['Beytüşşebap', 'Cizre', 'Güçlükonak', 'İdil', 'Merkez', 'Silopi', 'Uludere'],
      'Bartın': ['Amasra', 'Kurucaşile', 'Merkez', 'Ulus'],
      'Ardahan': ['Çıldır', 'Damal', 'Göle', 'Hanak', 'Merkez', 'Posof'],
      'Iğdır': ['Aralık', 'Karakoyunlu', 'Merkez', 'Tuzluca'],
      'Yalova': ['Altınova', 'Armutlu', 'Çınarcık', 'Çiftlikköy', 'Merkez', 'Termal'],
      'Karabük': ['Eflani', 'Eskipazar', 'Merkez', 'Ovacık', 'Safranbolu', 'Yenice'],
      'Kilis': ['Elbeyli', 'Merkez', 'Musabeyli', 'Polateli'],
      'Osmaniye': ['Bahçe', 'Düziçi', 'Hasanbeyli', 'Kadirli', 'Merkez', 'Sumbas', 'Toprakkale'],
      'Düzce': ['Akçakoca', 'Cumayeri', 'Çilimli', 'Gölyaka', 'Gümüşova', 'Kaynaşlı', 'Merkez', 'Yığılca']
    };

    cits.forEach((key, value) {_cities[key] = value;});
  }

  Future<void> _getPlateNumbers() async {
    if (_plateNumbers.isEmpty) {
      final snapshot = await db.collection('ambulance_master').get();

      for (var doc in snapshot.docs) {
        setState(() {
          _plateNumbers.add(doc.id);
        });
      }
    }
  }

  Future<void> _getCemeteries() async {
    if (_cemeteryIDtoName.isEmpty) {
      final snapshot = await db.collection('cemetery_master').get();

      for (var doc in snapshot.docs) {
        var data = doc.data();
        setState(() {
          _cemeteryIDtoName[doc.id] = data['cemetery_name'];
        });
      }
    }
  }

  Future<void> _getHospitals() async {
    if (_hospitalIDtoName.isEmpty) {
      final snapshot = await db.collection('hospital_master').get();

      for (var doc in snapshot.docs) {
        var data = doc.data();
        setState(() {
          _hospitalIDtoName[doc.id] = data['hospital_name'];
        });
      }
    }
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

        if (data.containsKey('applied_datetime') && data['applied_datetime'] != null) {
          appliedDate = DateTime.fromMillisecondsSinceEpoch(data['applied_date'] * 1000);
          _isAppliedDateSelected = true;
        }

        if (data.containsKey('rescue_datetime') && data['rescue_datetime'] != null) {
          rescueDate = DateTime.fromMillisecondsSinceEpoch(data['rescue_datetime'] * 1000);
          _isRescueDateSelected = true;
        }

        if (data.containsKey('burial_datetime') && data['burial_datetime'] != null) {
          burialDate = DateTime.fromMillisecondsSinceEpoch(data['burial_datetime'] * 1000);
          _isBurialDateSelected = true;
        }

        graveNumber = data.containsKey('grave_number') && data['grave_number'] != null
            ? data['grave_number'].toString()
            : graveNumber;

        city = data.containsKey('city') && data['city'] != null
            ? data['city'].toString()
            : city;
        _selectedCity = city;

        province = data.containsKey('province') && data['province'] != null
            ? data['province'].toString()
            : province;
        _selectedProvince = province;

        neighbourhood = data.containsKey('neighbourhood') && data['neighbourhood'] != null
            ? data['neighbourhood'].toString()
            : neighbourhood;

        street = data.containsKey('street') && data['street'] != null
            ? data['street'].toString()
            : street;

        building = data.containsKey('building') && data['building'] != null
            ? data['building'].toString()
            : building;

        _selectedHospitalID = data.containsKey('hospital_id') && data['hospital_id'] != null
            ? data['hospital_id'].toString()
            : _selectedHospitalID;

        _selectedCemeteryID = data.containsKey('cemetery_id') && data['cemetery_id'] != null
            ? data['cemetery_id'].toString()
            : _selectedCemeteryID;

        _selectedPlateNumber = data.containsKey('plate_number') && data['plate_number'] != null
            ? data['plate_number'].toString()
            : _selectedPlateNumber;

        notes = data.containsKey('notes') && data['notes'] != null
            ? data['notes'].toString()
            : notes;
      });
    } else {
      throw Exception('No ${widget.role} record found for this victim');
    }
  }

  Future<void> writeRecordToDB() async {
    try {
      final docRef = db.collection(widget.role).doc(widget.ndefUID);

      Map<String, dynamic> record = {};

      if (_isEnterDateSelected) {
        record['enter_datetime'] = Timestamp.fromDate(enterDate);
        record['stay_status'] = true;
      }

      if (_isDischargeDateSelected) {
        // Write discharge record, set stay_status to 0
        record['stay_status'] = false;
        record['discharge_datetime'] = Timestamp.fromDate(dischargeDate);
      }

      if (_isAppliedDateSelected) {
        record['applied_datetime'] = Timestamp.fromDate(appliedDate);
      }

      if (_isRescueDateSelected) {
        record['rescue_datetime'] = Timestamp.fromDate(rescueDate);
      }

      if (_isBurialDateSelected) {
        record['burial_datetime'] = Timestamp.fromDate(burialDate);
      }

      if (victimCondition != -1) {
        record['victim_condition'] = victimCondition;
      }

      if (_selectedProvince.isNotEmpty) {
        record['province'] = _selectedProvince;
      }

      if (_selectedCity.isNotEmpty) {
        record['city'] = _selectedCity;
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

      if (_selectedHospitalID != '') {
        record['hospital_id'] = _selectedHospitalID;
      }

      if (_selectedCemeteryID != '') {
        record['cemetery_id'] = _selectedCemeteryID;
      }

      if (_selectedPlateNumber != '') {
        record['plate_number'] = _selectedPlateNumber;
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

      // ADD TO ACTIVITY LOG
      CollectionReference logCol = db.collection('activity_log');

      await logCol.add({
        'date': DateTime.now(),
        'userID': widget.username,
        'table_name': widget.role,
        'ndefUID': widget.ndefUID,
      });

    } catch (e) {
      throw Exception('Failed to update record');
    }
  }
}
