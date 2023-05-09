import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'MapPage.dart';

class SurvivorReadPage extends StatefulWidget {
  final String ndefUID;

  const SurvivorReadPage({super.key, required this.ndefUID});

  @override
  _SurvivorReadPageState createState() => _SurvivorReadPageState();
}

class _SurvivorReadPageState extends State<SurvivorReadPage> {
  // From victim table
  String natID = 'Girilmemiş';
  String name = 'Girilmemiş';
  String surname = 'Girilmemiş';
  String sex = 'Girilmemiş';
  String ageMin = 'Girilmemiş';
  String ageMax = 'Girilmemiş';
  String bloodType = 'Girilmemiş';
  String chronicIllness = 'Girilmemiş';
  double longitude = 0.0;
  double latitude = 0.0;
  String address = '';

  final Color _primaryColor = const Color(0xff6a6b83);

  // From rescue table
  String city = 'Girilmemiş';
  String province = 'Girilmemiş';
  String neighbourhood = 'Girilmemiş';
  String street = 'Girilmemiş';
  String building = 'Girilmemiş';
  String rescueDate = 'Girilmemiş';

  // From clinic table
  String clinicHospitalName = 'Girilmemiş';
  String clinicEnterDate = 'Girilmemiş';
  String clinicDischargeDate = 'Girilmemiş';

  // From er table
  String erHospitalName = 'Girilmemiş';
  String erEnterDate = 'Girilmemiş';
  String erDischargeDate = 'Girilmemiş';

  // From firstaid table
  final Map<int, String> _victimConditions = {
    0: 'Hafif Yaralı',
    1: 'Yaralı',
    2: 'Ağır Yaralı',
    3: 'Ölü'
  };
  String firstaidHospitalName = 'Girilmemiş';
  String victimCondition = 'Girilmemiş';
  String firstaidAppliedDate = 'Girilmemiş';

  // From morgue table
  String morgueHospitalName = 'Girilmemiş';
  String morgueEnterDate = 'Girilmemiş';
  String morgueDischargeDate = 'Girilmemiş';

  // From graveyard table
  String graveyardName = 'Girilmemiş';
  String burialDate = 'Girilmemiş';

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();

    // Connect to DB
    db = FirebaseFirestore.instance;

    // Get victim info from DB with ndefUID
    getVictimFromDB();
    getRescueFromDB();
    getClinicFromDB();
    getGraveyardFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        middle: Text(
          "Depremzede Bilgisi",
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.only(top: 20)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$name $surname',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 25.0,
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 5)),
                      Text(
                        "ndefUID: ${widget.ndefUID}",
                        style: const TextStyle(
                          fontSize: 15.0,
                          color: Colors.black38,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 15)),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'TC Kimlik No.',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            natID,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Cinsiyet',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            sex,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(padding: EdgeInsets.only(top: 10)),
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(
                                'Minimum Yaş',
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.black38,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  ageMin,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(padding: EdgeInsets.only(top: 10)),
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(
                                'Maksimum Yaş',
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.black38,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  ageMax,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Kan Grubu',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            bloodType,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Kronik Rahatsızlıklar',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            chronicIllness,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Son Görülen Konum',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            address,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _primaryColor,
                    ),
                    onPressed: () {
                      Navigator.push<String>(
                        context,
                        MaterialPageRoute(builder: (context) => MapPage(lat: latitude, long: longitude)),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.map,
                            size: 40.0,
                            color: _primaryColor,
                          ),
                          const Padding(padding: EdgeInsets.only(left: 10.0)),
                          const Text('Konumu Haritada Göster'),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            size: 40.0,
                            color: _primaryColor,
                          ),
                        ],
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Enkazdan Çıkarılma Tarihi',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            rescueDate,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'İl',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            city,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'İlçe',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            province,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Mahalle',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            neighbourhood,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Cadde',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            street,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Bina Adı',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            building,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Hastane Adı',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            clinicHospitalName,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Hastaneye Giriş Tarihi',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            clinicEnterDate,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Hastaneden Çıkış Tarihi',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            clinicDischargeDate,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Mezarlık Adı',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            graveyardName,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Defin Tarihi',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.black38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            burialDate,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
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
        latitude = data['latitude'] ?? latitude;
        longitude = data['longitude'] ?? longitude;
      });
    } else {
      throw Exception('Failed to fetch victim data');
    }

    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    var first = placemarks.first;
    setState(() {
      address = '${first.name}, ${first.administrativeArea}/${first.subAdministrativeArea}, ${first.street} ${first.postalCode}, ${first.isoCountryCode}';
    });
  }

  Future<void> getRescueFromDB() async {
    final docRef = db.collection('rescue').doc(widget.ndefUID);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      setState(() {
        city = data['city'] ?? city;
        province = data['province'] ?? province;
        neighbourhood = data['neighbourhood'] ?? neighbourhood;
        street = data['street'] ?? street;
        building = data['building'] ?? building;
        rescueDate = data['rescue_datetime']?.toString() ?? rescueDate;
      });
    } else {
      throw Exception('Failed to fetch rescue data');
    }
  }

  Future<void> getClinicFromDB() async {
    final docRef = db.collection('clinic').doc(widget.ndefUID);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      setState(() {
        clinicHospitalName = data['hospital_name'] ?? clinicHospitalName;
        clinicEnterDate = data['enter_datetime']?.toString() ?? clinicEnterDate;
        clinicDischargeDate = data['discharge_datetime']?.toString() ?? clinicDischargeDate;
      });
    } else {
      throw Exception('Failed to fetch clinic data');
    }
  }

  Future<void> getGraveyardFromDB() async {
    final docRef = db.collection('graveyard').doc(widget.ndefUID);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      setState(() {
        graveyardName = data['graveyard_name'] ?? clinicHospitalName;
        burialDate = data['burial_datetime']?.toString() ?? clinicDischargeDate;
      });
    } else {
      throw Exception('Failed to fetch graveyard data');
    }
  }
}
