import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController _essetialNeedsInputController = TextEditingController();

  late FirebaseFirestore db;

  final Color _primaryColor = const Color(0xff6a6b83);

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'];
  final List<String> _sex = ['Kadın', 'Erkek'];

  String _selectedBloodType = 'A+';
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
      appBar: const CupertinoNavigationBar(
        middle: Text(
          "Depremzede Bilgi Kayıt",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                child: Text(
                  "ndefUID: ${widget.ndefUID}",
                  style: TextStyle(
                    fontSize: 15.0,
                    color: _primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TC Kimlik No',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextFormField(
                      controller: _natIDInputController,
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: natID
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İsim',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextFormField(
                      controller: _nameInputController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: name
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Soyisim',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextFormField(
                      controller: _surnameInputController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: surname
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cinsiyet'
                        ),
                        DropdownButton(
                          value: _selectedSex,
                          items: _sex
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              _selectedSex = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Minimum Yaş',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextFormField(
                      controller: _ageMinInputController,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: ageMin
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Maksimum Yaş',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextFormField(
                      controller: _ageMaxInputController,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: ageMax
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                            'Kan Grubu'
                        ),
                        DropdownButton(
                          value: _selectedBloodType,
                          items: _bloodTypes
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              _selectedBloodType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kronik Rahatsızlıklar',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextFormField(
                      controller: _chronicIllnessInputController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: chronicIllness
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Temel İhtiyaçlar',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextFormField(
                      controller: _essetialNeedsInputController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: essentialNeeds
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  writeVictimToDB();
                  Navigator.pop(context);
                },
                child: const Text('Güncelle')),
            ],
          ),
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
      if (_essetialNeedsInputController.text.isNotEmpty) {
        victimData['essential_needs'] = _essetialNeedsInputController.text;
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
