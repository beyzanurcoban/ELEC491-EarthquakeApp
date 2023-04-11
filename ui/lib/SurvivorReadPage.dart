import 'dart:convert';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    getUserFromDB();
    //fetchData();
  }

  Future<void> getUserFromDB() async {
    final docRef = db.collection('victim').doc(widget.ndefUID);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      setState(() {
        natID = data['victim_nat_id'].toString();
        name = data['victim_name'];
        surname = data['victim_surname'];
        sex = data['victim_sex'];
        ageMin = data['victim_age_min'].toString();
        ageMax = data['victim_age_max'].toString();
        bloodType = data['blood_type'];
        chronicIllness = data['chronic_illness'];
        longitude = data['longitude'];
        latitude = data['latitude'];
      });
    } else {
      throw Exception('Failed to fetch victim data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(),
        middle: Text(
          "Depremzede Bilgisi",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.only(top: 30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      // TODO: Name Surname
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
                  ],
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),

          ],
        ),
      ),
    );
  }
}
