import 'dart:convert';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'MapPage.dart';

class SurvivorReadPage extends StatefulWidget {
  final String ndefUID;

  const SurvivorReadPage({super.key, required this.ndefUID});

  @override
  _SurvivorReadPageState createState() => _SurvivorReadPageState();
}

class _SurvivorReadPageState extends State<SurvivorReadPage> {
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

  final Color _primaryColor = const Color(0xff6a6b83);

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();

    // Connect to DB
    db = FirebaseFirestore.instance;

    // Get victim info from DB with ndefUID
    getVictimFromDB();
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
                            '$latitude $longitude',
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
                  IconButton(
                      icon: const Icon(Icons.location_on),
                      color: _primaryColor,
                      iconSize: 45.0,
                      onPressed: () {
                        Navigator.push<String>(
                          context,
                          MaterialPageRoute(builder: (context) => MapPage(lat: latitude, long: longitude)),
                        );
                      },
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
  }
}
