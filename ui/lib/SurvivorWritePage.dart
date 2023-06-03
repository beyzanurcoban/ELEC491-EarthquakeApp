import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xff6a6b83);
const Color _secondaryColor = Color(0xff77789a);
const Color _tertiaryColor = Color(0xffebebeb);
const Color _backgroundColor = Color(0xffd5d5e4);
const Color _shadowColor = Color(0x806a6b83);

class SurvivorWritePage extends StatefulWidget {
  final String ndefUID;
  final String userID;

  const SurvivorWritePage({
    super.key,
    required this.ndefUID,
    required this.userID,
  });

  @override
  _SurvivorWritePageState createState() => _SurvivorWritePageState();
}

class _SurvivorWritePageState extends State<SurvivorWritePage> {

  String natID = 'Girilmemiş';
  String name = 'Girilmemiş';
  String surname = 'Girilmemiş';
  String sex = 'Girilmemiş';
  String ageMin = 'Girilmemiş';
  String ageMax = 'Girilmemiş';
  String bloodType = 'Girilmemiş';
  String chronicIllness = 'Girilmemiş';
  String essentialNeeds = 'Girilmemiş';
  double longitude = 0.0;
  double latitude = 0.0;

  final TextEditingController _natIDInputController = TextEditingController();
  final TextEditingController _nameInputController = TextEditingController();
  final TextEditingController _surnameInputController = TextEditingController();
  final TextEditingController _ageMinInputController = TextEditingController();
  final TextEditingController _ageMaxInputController = TextEditingController();
  final TextEditingController _chronicIllnessInputController = TextEditingController();
  final TextEditingController _essentialNeedsInputController = TextEditingController();

  late FirebaseFirestore db;

  final List<String> _bloodTypes = ['A Rh+', 'A Rh-', 'B Rh+', 'B Rh-', 'AB Rh+', 'AB Rh-', '0 Rh+', '0 Rh-'];
  final List<String> _sex = ['Kadın', 'Erkek'];

  String _selectedBloodType = 'A Rh+';
  String _selectedSex = 'Kadın';

  @override
  void initState() {
    super.initState();

    // Connect to DB
    db = FirebaseFirestore.instance;

    // Get current data from DB
    getVictimFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 50)),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                                decoration: BoxDecoration(
                                  color: _tertiaryColor,
                                  borderRadius: BorderRadius.circular(30.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: _shadowColor,
                                      blurRadius: 10.0,
                                      offset: Offset(0.0, 10.0),
                                    )
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Etiket ID: ${widget.ndefUID}",
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: _primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ),
                        TextInputFieldWidget(
                          title: 'TC Kimlik No',
                          labelText: natID,
                          controller: _natIDInputController,
                          maxLength: 11,
                          keyboardType: TextInputType.number,
                        ),
                        TextInputFieldWidget(
                          title: 'İsim',
                          labelText: name,
                          controller: _nameInputController,
                        ),
                        TextInputFieldWidget(
                          title: 'Soyisim',
                          labelText: surname,
                          controller: _surnameInputController,
                        ),
                        DropdownFieldWidget(
                          title: 'Cinsiyet',
                          selectedItem: _selectedSex,
                          items: _sex,
                        ),
                        TextInputFieldWidget(
                          title: 'Minimum Yaş',
                          labelText: ageMin,
                          controller: _ageMinInputController,
                          maxLength: 3,
                          keyboardType: TextInputType.number,
                        ),
                        TextInputFieldWidget(
                          title: 'Maksimum Yaş',
                          labelText: ageMax,
                          controller: _ageMaxInputController,
                          maxLength: 3,
                          keyboardType: TextInputType.number,
                        ),
                        DropdownFieldWidget(
                          title: 'Kan Grubu',
                          selectedItem: _selectedBloodType,
                          items: _bloodTypes,
                        ),
                        TextInputFieldWidget(
                          title: 'Kronik Rahatsızlıklar',
                          labelText: chronicIllness,
                          controller: _chronicIllnessInputController,
                        ),
                        TextInputFieldWidget(
                          title: 'Temel İhtiyaçlar',
                          labelText: essentialNeeds,
                          controller: _essentialNeedsInputController,
                        ),
                        const Padding(padding: EdgeInsets.only(top: 100.0)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 60,
                        child: Container(
                            decoration: BoxDecoration(
                              color: _tertiaryColor,
                              borderRadius: BorderRadius.circular(30.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: _shadowColor,
                                  blurRadius: 10.0,
                                  offset: Offset(0.0, 10.0),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: SizedBox(
                                      height: 60,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _primaryColor,
                                          borderRadius: BorderRadius.circular(30.0),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: _shadowColor,
                                              blurRadius: 10.0,
                                              offset: Offset(0.0, 10.0),
                                            )
                                          ],
                                        ),
                                        child: TextButton(
                                          onPressed: () async {
                                            writeVictimToDB();
                                            Navigator.pop(context);
                                          },
                                          child: Stack(
                                            children: const [
                                              Center(
                                                child: Text(
                                                  'Güncelle',
                                                  style: TextStyle(
                                                      color: _tertiaryColor,
                                                      fontSize: 16.0,
                                                      fontWeight: FontWeight.w700
                                                  ),
                                                ),
                                              ),
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
            SizedBox(
              height: 60,
              child: Container(
                decoration: const BoxDecoration(
                  color: _backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: _shadowColor,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 32,
                          width: MediaQuery.of(context).size.width,
                          child: Image.asset('assets/images/dost_large.png'),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {Navigator.pop(context);},
                          icon: const Icon(
                            Icons.arrow_back,
                            color: _primaryColor,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }

  Future<void> getVictimFromDB() async {
    final docRef = db.collection('victim').doc(widget.ndefUID);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      setState(() {
        natID = data['victim_nat_id']?.toString() ?? natID;
        name = data['victim_name'] ?? name;
        surname = data['victim_surname'] ?? surname;
        sex = data['victim_sex'] ?? sex;
        ageMin = data['victim_age_min']?.toString() ?? ageMin;
        ageMax = data['victim_age_max']?.toString() ?? ageMax;
        bloodType = data['blood_type'] ?? bloodType;
        chronicIllness = data['chronic_illness'] ?? chronicIllness;
        essentialNeeds = data['essential_needs'] ?? essentialNeeds;
        latitude = data['latitude'] ?? latitude;
        longitude = data['longitude'] ?? longitude;

        if(sex != 'Girilmemiş'){
          _selectedSex = sex;
        }

        if(bloodType != 'Girilmemiş'){
          _selectedBloodType = bloodType;
        }
      });
    } else {
      throw Exception('Failed to fetch victim data');
    }
  }

  Future<void> writeVictimToDB() async {
    try {
      final docRef = db.collection('victim').doc(widget.ndefUID);

      Map<String, dynamic> victimData = {};
      if (_natIDInputController.text.isNotEmpty) {
        victimData['victim_nat_id'] = _natIDInputController.text;
      }
      if (_nameInputController.text.isNotEmpty) {
        victimData['victim_name'] = _nameInputController.text;
      }
      if (_surnameInputController.text.isNotEmpty) {
        victimData['victim_surname'] = _surnameInputController.text;
      }
      if (_selectedSex.isNotEmpty) {
        victimData['victim_sex'] = _selectedSex;
      }
      if (_ageMinInputController.text.isNotEmpty) {
        victimData['victim_age_min'] = int.tryParse(_ageMinInputController.text);
      }
      if (_ageMaxInputController.text.isNotEmpty) {
        victimData['victim_age_max'] = int.tryParse(_ageMaxInputController.text);
      }
      if (_selectedBloodType.isNotEmpty) {
        victimData['blood_type'] = _selectedBloodType;
      }
      if (_chronicIllnessInputController.text.isNotEmpty) {
        victimData['chronic_illness'] = _chronicIllnessInputController.text;
      }
      if (_essentialNeedsInputController.text.isNotEmpty) {
        victimData['essential_needs'] = _essentialNeedsInputController.text;
      }

      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.update(victimData);
      } else {
        await docRef.set(victimData);
      }

      // ADD TO ACTIVITY LOG
      CollectionReference logCol = db.collection('activity_log');

      await logCol.add({
        'date': DateTime.now(),
        'userID': widget.userID,
        'table_name': 'victim',
        'ndefUID': widget.ndefUID,
      });

    } catch (e) {
      throw Exception('Failed to update victim data');
    }
  }
}

class TextInputFieldWidget extends StatelessWidget {

  final String title;
  final String labelText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int? maxLength;

  const TextInputFieldWidget({
    Key? key,
    required this.title,
    required this.labelText,
    required this.controller,
    this.keyboardType,
    this.maxLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: maxLength != null ? 120 : 90,
        child: Container(
          decoration: BoxDecoration(
            color: _tertiaryColor,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: const [
              BoxShadow(
                color: _shadowColor,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
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
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _primaryColor,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 10.0)),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: maxLength != null ? 40 : 20,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: labelText,
                            floatingLabelStyle: const TextStyle(
                              color: Colors.transparent
                            )
                          ),
                          cursorColor: _primaryColor,
                          style: const TextStyle(
                            fontSize: 16,
                            color: _primaryColor,
                          ),
                          controller: controller,
                          keyboardType: keyboardType,
                          maxLength: maxLength,
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
    );
  }
}

class DropdownFieldWidget extends StatefulWidget {

  final String title;
  String selectedItem;
  final List<String> items;

  DropdownFieldWidget({
    Key? key,
    required this.title,
    required this.selectedItem,
    required this.items,
  }) : super(key: key);

  @override
  _DropdownFieldWidgetState createState() => _DropdownFieldWidgetState();
}

class _DropdownFieldWidgetState extends State<DropdownFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 60,
        child: Container(
          decoration: BoxDecoration(
            color: _tertiaryColor,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: const [
              BoxShadow(
                color: _shadowColor,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _primaryColor,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                        style: const TextStyle(
                          fontSize: 14,
                          color: _primaryColor,
                        ),
                        value: widget.selectedItem,
                        items: widget.items
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            widget.selectedItem = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
