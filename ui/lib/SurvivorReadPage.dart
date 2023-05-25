import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'package:ui/ActivityLogPage.dart';
import 'MapPage.dart';

class SurvivorReadPage extends StatefulWidget {
  final String ndefUID;

  const SurvivorReadPage({super.key, required this.ndefUID});

  @override
  _SurvivorReadPageState createState() => _SurvivorReadPageState();
}

class _SurvivorReadPageState extends State<SurvivorReadPage> {
  final Color _primaryColor = const Color(0xff6a6b83);
  final Color _secondaryColor = const Color(0xff77789a);
  final Color _tertiaryColor = const Color(0xffebebeb);
  final Color _backgroundColor = const Color(0xffd5d5e4);
  final Color _shadowColor = const Color(0x806a6b83);

  // From victim table
  String natID = 'Girilmemiş';
  String name = 'Girilmemiş';
  String surname = 'Girilmemiş';
  String sex = 'Girilmemiş';
  String ageMin = 'Girilmemiş';
  String ageMax = 'Girilmemiş';
  String bloodType = 'Girilmemiş';
  String chronicIllness = 'Girilmemiş';
  String essentialNeeds = 'Girilmemiş';
  double latestLongitude = 0.0;
  double latestLatitude = 0.0;
  String address = '';

  // From rescue table
  bool _rescueRecordExists = false;
  String city = 'Girilmemiş';
  String province = 'Girilmemiş';
  String neighbourhood = 'Girilmemiş';
  String street = 'Girilmemiş';
  String building = 'Girilmemiş';
  String rescueDate = 'Girilmemiş';

  // From clinic table
  bool _clinicRecordExists = false;
  String clinicHospitalName = 'Girilmemiş';
  String clinicEnterDate = 'Girilmemiş';
  String clinicDischargeDate = 'Girilmemiş';
  String clinicNotes = 'Girilmemiş';

  // From er table
  bool _erRecordExists = false;
  String erHospitalName = 'Girilmemiş';
  String erEnterDate = 'Girilmemiş';
  String erDischargeDate = 'Girilmemiş';
  String erNotes = 'Girilmemiş';

  // From morgue table
  bool _morgueRecordExists = false;
  String morgueHospitalName = 'Girilmemiş';
  String morgueEnterDate = 'Girilmemiş';
  String morgueDischargeDate = 'Girilmemiş';
  String morgueNotes = 'Girilmemiş';

  // From firstaid table
  bool _firstaidRecordExists = false;
  final Map<int, String> _victimConditions = {
    0: 'Hafif Yaralı',
    1: 'Yaralı',
    2: 'Ağır Yaralı',
    3: 'Ölü'
  };
  String firstaidPlateNumber = 'Girilmemiş';
  String victimCondition = 'Girilmemiş';
  String firstaidAppliedDate = 'Girilmemiş';
  String firstaidNotes = 'Girilmemiş';

  // From burial table
  bool _burialRecordExists = false;
  String cemeteryName = 'Girilmemiş';
  String graveNumber = 'Girilmemiş';
  String burialDate = 'Girilmemiş';
  String burialNotes = 'Girilmemiş';

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();

    // Connect to DB
    db = FirebaseFirestore.instance;

    // Get victim info from *all* tables in DB with ndefUID
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 27.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 50)),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: SizedBox(
                            height: 90,
                            width: MediaQuery.of(context).size.width,
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$name $surname',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: _primaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  Text(
                                    "Etiket ID: ${widget.ndefUID}",
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
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
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      DBFieldWidget(fieldTitle: 'TC Kimlik No.', fieldValue: natID),
                                      DBFieldWidget(fieldTitle: 'Cinsiyet', fieldValue: sex),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: DBFieldWidget(fieldTitle: 'Minimum Yaş', fieldValue: ageMin)
                                          ),
                                          Expanded(
                                              child: DBFieldWidget(fieldTitle: 'Maksimum Yaş', fieldValue: ageMax)
                                          ),
                                        ],
                                      ),
                                      DBFieldWidget(fieldTitle: 'Kan Grubu', fieldValue: bloodType),
                                      DBFieldWidget(fieldTitle: 'Kronik Rahatsızlıklar', fieldValue: chronicIllness),
                                      DBFieldWidget(fieldTitle: 'Temel İhtiyaçlar', fieldValue: essentialNeeds),
                                    ],
                                  ),
                                )
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
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
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      DBFieldWidget(fieldTitle: 'Son Görülen Konum', fieldValue: address),
                                      const Padding(padding: EdgeInsets.only(top: 15.0)),
                                      SizedBox(
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
                                            onPressed: () {
                                              Navigator.push<String>(
                                                context,
                                                MaterialPageRoute(builder: (context) => MapPage(lat: latestLatitude, long: latestLongitude)),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(15.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Icon(Icons.map,
                                                    size: 32.0,
                                                    color: _primaryColor,
                                                  ),
                                                  Text(
                                                    'Haritada Gör',
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
                                )
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
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
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      const DBFieldWidget(fieldTitle: 'Kayıt Tarihçesi', fieldValue: 'Kullanıcıların bu etikete yazdığı tüm kayıtlardır.'),
                                      const Padding(padding: EdgeInsets.only(top: 15.0)),
                                      SizedBox(
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
                                            onPressed: () {
                                              Navigator.push<String>(
                                                context,
                                                MaterialPageRoute(builder: (context) => ActivityLogPage(ndefUID: widget.ndefUID,)),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(15.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Icon(Icons.history,
                                                    size: 32.0,
                                                    color: _primaryColor,
                                                  ),
                                                  Text(
                                                    'Tarihçeyi Gör',
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
                                )
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _rescueRecordExists,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
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
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const DBTableNameWidget(tableName: 'Arama-Kurtarma'),
                                    DBFieldWidget(fieldTitle: 'Kurtarma Tarihi', fieldValue: rescueDate),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: DBFieldWidget(fieldTitle: 'İl', fieldValue: province)
                                        ),
                                        Expanded(
                                            child: DBFieldWidget(fieldTitle: 'İlçe', fieldValue: city)
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: DBFieldWidget(fieldTitle: 'Mahalle', fieldValue: neighbourhood)
                                        ),
                                        Expanded(
                                            child: DBFieldWidget(fieldTitle: 'Sokak', fieldValue: street)
                                        ),
                                      ],
                                    ),
                                    DBFieldWidget(fieldTitle: 'Bina', fieldValue: building),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _firstaidRecordExists,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
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
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const DBTableNameWidget(tableName: 'İlk Yardım'),
                                    DBFieldWidget(fieldTitle: 'İlk Yardım Tarihi', fieldValue: firstaidAppliedDate),
                                    DBFieldWidget(fieldTitle: 'Ambulans Plakası', fieldValue: firstaidPlateNumber),
                                    DBFieldWidget(fieldTitle: 'Yaralanma Durumu', fieldValue: victimCondition),
                                    DBFieldWidget(fieldTitle: 'Notlar', fieldValue: firstaidNotes),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _erRecordExists,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
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
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const DBTableNameWidget(tableName: 'Acil'),
                                    DBFieldWidget(fieldTitle: 'Hastane', fieldValue: erHospitalName),
                                    DBFieldWidget(fieldTitle: 'Giriş Tarihi', fieldValue: erEnterDate),
                                    DBFieldWidget(fieldTitle: 'Çıkış Tarihi', fieldValue: erDischargeDate),
                                    DBFieldWidget(fieldTitle: 'Notlar', fieldValue: erNotes),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _clinicRecordExists,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
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
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const DBTableNameWidget(tableName: 'Klinik'),
                                    DBFieldWidget(fieldTitle: 'Hastane', fieldValue: clinicHospitalName),
                                    DBFieldWidget(fieldTitle: 'Giriş Tarihi', fieldValue: clinicEnterDate),
                                    DBFieldWidget(fieldTitle: 'Çıkış Tarihi', fieldValue: clinicDischargeDate),
                                    DBFieldWidget(fieldTitle: 'Notlar', fieldValue: clinicNotes),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _morgueRecordExists,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
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
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const DBTableNameWidget(tableName: 'Morg'),
                                    DBFieldWidget(fieldTitle: 'Hastane', fieldValue: morgueHospitalName),
                                    DBFieldWidget(fieldTitle: 'Giriş Tarihi', fieldValue: morgueEnterDate),
                                    DBFieldWidget(fieldTitle: 'Çıkış Tarihi', fieldValue: morgueDischargeDate),
                                    DBFieldWidget(fieldTitle: 'Notlar', fieldValue: morgueNotes),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _burialRecordExists,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
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
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const DBTableNameWidget(tableName: 'Defin'),
                                    DBFieldWidget(fieldTitle: 'Defin Tarihi', fieldValue: burialDate),
                                    DBFieldWidget(fieldTitle: 'Mezarlık', fieldValue: cemeteryName),
                                    DBFieldWidget(fieldTitle: 'Mezar Numarası', fieldValue: graveNumber),
                                    DBFieldWidget(fieldTitle: 'Notlar', fieldValue: burialNotes),
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
            SizedBox(
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: _shadowColor,
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 10.0),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {Navigator.pop(context);},
                        icon: Icon(
                          Icons.arrow_back,
                          color: _primaryColor,
                          size: 32,
                        ),
                      ),
                      SizedBox(
                        height: 32,
                        child: Image.asset('assets/images/dost_large.png'),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> fetchData() async {
    // VICTIM TABLE
    var docRef = db.collection('victim').doc(widget.ndefUID);
    var docSnap = await docRef.get();

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
        latestLatitude = data['latest_latitude'] ?? latestLatitude;
        latestLongitude = data['latest_longitude'] ?? latestLongitude;
      });
    }

    // RESCUE TABLE
    docRef = db.collection('rescue').doc(widget.ndefUID);
    docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      setState(() {
        _rescueRecordExists = true;

        province = data['province'] ?? province;
        city = data['city'] ?? city;
        neighbourhood = data['neighbourhood'] ?? neighbourhood;
        street = data['street'] ?? street;
        building = data['building'] ?? building;
        rescueDate = data['rescue_datetime']?.toDate().toString() ?? rescueDate;
      });
    }

    // FIRSTAID
    docRef = db.collection('firstaid').doc(widget.ndefUID);
    docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;

      setState(() {
        _firstaidRecordExists = true;

        firstaidPlateNumber = data['plate_number'] ?? firstaidPlateNumber;
        firstaidAppliedDate = data['applied_datetime']?.toDate().toString() ?? firstaidAppliedDate;
        victimCondition = _victimConditions[data['victim_condition']] ?? victimCondition;
        firstaidNotes = data['notes']?.toString() ?? firstaidNotes;
      });
    }

    // CLINIC
    docRef = db.collection('clinic').doc(widget.ndefUID);
    docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;

      var docRefMaster = db.collection('hospital_master').doc(data['hospital_id']);
      var docSnapMaster = await docRefMaster.get();

      setState(() {
        _clinicRecordExists = true;

        clinicHospitalName = docSnapMaster.data()?['hospital_name'] ?? clinicHospitalName;
        clinicEnterDate = data['enter_datetime']?.toDate().toString() ?? clinicEnterDate;
        clinicDischargeDate = data['discharge_datetime']?.toDate().toString() ?? clinicDischargeDate;
        clinicNotes = data['notes']?.toString() ?? clinicNotes;
      });
    }

    // ER
    docRef = db.collection('er').doc(widget.ndefUID);
    docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;

      var docRefMaster = db.collection('hospital_master').doc(data['hospital_id']);
      var docSnapMaster = await docRefMaster.get();

      setState(() {
        _erRecordExists = true;

        erHospitalName = docSnapMaster.data()?['hospital_name'] ?? erHospitalName;
        erEnterDate = data['enter_datetime']?.toDate().toString() ?? erEnterDate;
        erDischargeDate = data['discharge_datetime']?.toDate().toString() ?? erDischargeDate;
        erNotes = data['notes']?.toString() ?? erNotes;
      });
    }

    // MORGUE
    docRef = db.collection('morgue').doc(widget.ndefUID);
    docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;

      var docRefMaster = db.collection('hospital_master').doc(data['hospital_id']);
      var docSnapMaster = await docRefMaster.get();

      setState(() {
        _morgueRecordExists = true;

        morgueHospitalName = docSnapMaster.data()?['hospital_name'] ?? morgueHospitalName;
        morgueEnterDate = data['enter_datetime']?.toDate().toString() ?? morgueEnterDate;
        morgueDischargeDate = data['discharge_datetime']?.toDate().toString() ?? morgueDischargeDate;
        morgueNotes = data['notes']?.toString() ?? morgueNotes;
      });
    }

    // BURIAL
    docRef = db.collection('burial').doc(widget.ndefUID);
    docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;

      var docRefMaster = db.collection('cemetery_master').doc(data['cemetery_id']);
      var docSnapMaster = await docRefMaster.get();

      setState(() {
        _burialRecordExists = true;

        cemeteryName = docSnapMaster.data()?['cemetery_name'] ?? cemeteryName;
        graveNumber = data['grave_number']?.toString() ?? graveNumber;
        burialDate = data['burial_datetime']?.toDate().toString() ?? burialDate;
        burialNotes = data['notes']?.toString() ?? burialNotes;
      });
    }

    List<Placemark> placemarks = await placemarkFromCoordinates(latestLatitude, latestLongitude);
    var first = placemarks.first;
    setState(() {
      address = '${first.name}, ${first.administrativeArea}/${first.subAdministrativeArea}, ${first.street} ${first.postalCode}, ${first.isoCountryCode}';
    });
  }
}

class DBTableNameWidget extends StatelessWidget {
  final String tableName;

  const DBTableNameWidget({Key? key, required this.tableName}) : super(key: key);

  final Color _primaryColor = const Color(0xff6a6b83);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
          children: [
            const Padding(padding: EdgeInsets.only(top: 20.0)),
            Text(
              tableName,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                color: _primaryColor,
              ),
            ),
          ]
      )
    );
  }
}

class DBFieldWidget extends StatelessWidget {

  final String fieldTitle;
  final String fieldValue;

  const DBFieldWidget({Key? key, required this.fieldTitle, required this.fieldValue}) : super(key: key);

  final Color _primaryColor = const Color(0xff6a6b83);
  final Color _secondaryColor = const Color(0xff77789a);
  final Color _tertiaryColor = const Color(0xffebebeb);
  final Color _backgroundColor = const Color(0xffd5d5e4);
  final Color _shadowColor = const Color(0x806a6b83);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: Text(
                    fieldTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: Text(
                    fieldValue,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
