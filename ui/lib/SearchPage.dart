import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SurvivorReadPage.dart';

class SearchPage extends StatefulWidget {

  const SearchPage({super.key,});

  @override
  _SearchPageState createState() => _SearchPageState();
}

const Color _primaryColor = Color(0xff6a6b83);
const Color _secondaryColor = Color(0xff77789a);
const Color _tertiaryColor = Color(0xffebebeb);
const Color _backgroundColor = Color(0xffd5d5e4);
const Color _shadowColor = Color(0x806a6b83);

class _SearchPageState extends State<SearchPage> {
  bool _isLoading = false;

  final Color _selectedBoxColor = _primaryColor;
  final Color _unselectedBoxColor = Colors.transparent;

  final Color _selectedTextColor = _tertiaryColor;
  final Color _unselectedTextColor = _primaryColor;

  final TextEditingController _searchTermInputController = TextEditingController();

  List<Map<String, dynamic>> _queryResults = <Map<String, dynamic>>[];
  List<String> _queryResultIDs = <String>[];

  final Map<String, String> _tables = {
    'victim': 'Depremzede Bilgisi',
    'clinic': 'Hastane Adı',
    'firstaid': 'Ambulans Plakası',
    'rescue': 'Arama-Kurtarma Lokasyonu',
    'burial': 'Mezarlık Adı'
  };

  final Map<String, List<String>> _tableToListOfTables = {
    'victim': ['victim'],
    'clinic': ['clinic', 'er', 'morgue'],
    'rescue': ['rescue'],
    'burial': ['burial'],
    'firstaid': ['firstaid'],
  };


  String _selectedTable = '';

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();

    // Connect to DB
    db = FirebaseFirestore.instance;

    // Set selected table to first.
    _selectedTable = _tables.entries.first.key;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 30.0)),
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
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.search,
                                      size: 32,
                                      color: _primaryColor,
                                    ),
                                    const Padding(padding: EdgeInsets.only(left: 10.0)),
                                    Expanded(
                                      child: TextField(
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                        ),
                                        controller: _searchTermInputController,
                                        decoration: const InputDecoration.collapsed(
                                          hintText: 'Arama terimi girin.',
                                        ),
                                        textInputAction: TextInputAction.search,
                                        onSubmitted: (searchTerm) {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          search(searchTerm);
                                        },
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.only(left: 10.0)),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Visibility(
                                            visible: _isLoading,
                                            child: Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: const [
                                                  Center(
                                                    child: SizedBox(
                                                      height: 16,
                                                      width: 16,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2.0,
                                                        color: _primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 32,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 10.0, right: 16.0),
                        scrollDirection: Axis.horizontal,
                        itemCount: _tableToListOfTables.length,
                        itemBuilder: (context, index) {
                          final key = _tableToListOfTables.keys.elementAt(index);
                          final value = _tables[key];
                          return Padding(
                            padding: const EdgeInsets.only(left: 10.0,),
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTable = key;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  width: 1.0,
                                  color: _selectedBoxColor,
                                ),
                                backgroundColor: _selectedTable == key ? _selectedBoxColor : _unselectedBoxColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                value ?? 'Bulunamadı',
                                style: TextStyle(
                                  color: _selectedTable == key ? _selectedTextColor : _unselectedTextColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0, right: 10.0, left: 10.0, bottom: 10.0),
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _queryResults.length,
                      itemBuilder: (context, index) {
                        final queryResult = _queryResults.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: _shadowColor,
                                  blurRadius: 10.0,
                                  offset: Offset(0.0, 10.0),
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
                                  MaterialPageRoute(builder: (context) => SurvivorReadPage(ndefUID: queryResult['ndefUID'],)),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 10.0, right: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      '${queryResult['victim_name']} ${queryResult['victim_surname']}',
                                      style: const TextStyle(
                                        color: _primaryColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Etiket ID: ${queryResult['ndefUID']}',
                                      style: const TextStyle(
                                        color: _primaryColor,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                                    Text(
                                      '${queryResult['city'] ?? 'İlçe Bilgisi Yok'}, ${queryResult['province'] ?? 'İl Bilgisi Yok'}',
                                      style: const TextStyle(
                                        color: _primaryColor,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${queryResult['hospital_name']  ?? 'Hastane bilgisi girilmemiş'}',
                                      style: const TextStyle(
                                        color: _primaryColor,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    Text(
                                      '${queryResult['cemetery_name'] ?? 'Mezarlık bilgisi girilmemiş'}',
                                      style: const TextStyle(
                                        color: _primaryColor,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 60,
              child: Container(
                decoration: const BoxDecoration(
                  color: _backgroundColor,
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
      ),
    );
  }

  Future<void> search(String searchTerm) async {

    setState(() {
      _queryResults.clear();
      _queryResultIDs.clear();
    });

    List<String> searchTerms = [];

    // PARSE SEARCH TERMS IN INPUT
    searchTerms.addAll(searchTerm.split(' '));
    searchTerms.remove('');

    // JOIN MASTER TABLES
    // Search for any occurrences of the search term in master tables
    // Get IDs of entries where search term matches their name
    List<String> ids = [];

    if (_selectedTable == 'clinic') {
      var masterDocRefs = await db.collection('hospital_master').get();
      var masterDocs = masterDocRefs.docs.where((doc)
      => doc.data().values.any((value)
      => searchTerms.any((searchTerm)
      => value.toString().toLowerCase().contains(searchTerm.toLowerCase()))));

      for (var element in masterDocs) {
        ids.add(element.id.toString());
      }
    }

    if (_selectedTable == 'burial') {
      var masterDocRefs = await db.collection('cemetery_master').get();
      var masterDocs = masterDocRefs.docs.where((doc)
      => doc.data().values.any((value)
      => searchTerms.any((searchTerm)
      => value.toString().toLowerCase().contains(searchTerm.toLowerCase()))));

      for (var element in masterDocs) {
        ids.add(element.id.toString());
      }
    }

    if (_selectedTable == 'firstaid') {
      var masterDocRefs = await db.collection('ambulance_master').get();
      var masterDocs = masterDocRefs.docs.where((doc)
      => doc.data().values.any((value)
      => searchTerms.any((searchTerm)
      => value.toString().toLowerCase().contains(searchTerm.toLowerCase()))));

      for (var element in masterDocs) {
        ids.add(element.id.toString());
      }
    }

    searchTerms.addAll(ids);

    for (String table in _tableToListOfTables[_selectedTable] ?? ['victim']) {

      // SEARCH IN ALL RELATED TABLES
      var docRefs = await db.collection(table).get();
      var docs = docRefs.docs.where((doc)
        => doc.data().values.any((value)
        => searchTerms.any((searchTerm)
        => value.toString().toLowerCase().contains(searchTerm.toLowerCase()))));


      // DISPLAY INFO ON BUTTON
      for (var element in docs) {
        String ndefUID = element.id.toString();

        Map<String, dynamic> completeQuery = {};

        if (_queryResultIDs.contains(ndefUID)) {
          continue;
        }

        completeQuery['ndefUID'] = ndefUID;

        // VICTIM TABLE
        var victimDocRef = db.collection('victim').doc(ndefUID);
        var victimDocSnap = await victimDocRef.get();

        completeQuery['victim_name'] = victimDocSnap.data()?['victim_name'];
        completeQuery['victim_surname'] = victimDocSnap.data()?['victim_surname'];

        // HOSPITAL_MASTER
        for (var table in _tableToListOfTables['clinic'] ?? ['clinic']) {
          var docRef = db.collection(table).doc(ndefUID);
          var docSnap = await docRef.get();

          if (docSnap.exists && docSnap.data()?['hospital_id'] != null) {
            var docRefMaster = db.collection('hospital_master').doc(docSnap.data()!['hospital_id']);
            var docSnapMaster = await docRefMaster.get();

            completeQuery['hospital_name'] = docSnapMaster.data()?['hospital_name'];
          }
        }

        // RESCUE TABLE
        var rescueDocRef = db.collection('rescue').doc(ndefUID);
        var rescueDocSnap = await rescueDocRef.get();

        completeQuery['province'] = rescueDocSnap.data()?['province'];
        completeQuery['city'] = rescueDocSnap.data()?['city'];

        // CEMETERY_MASTER
        var burialDocRef = db.collection('burial').doc(ndefUID);
        var burialDocSnap = await burialDocRef.get();

        if (burialDocSnap.exists && burialDocSnap.data()?['cemetery_id'] != null) {
          var docRefMaster = db.collection('cemetery_master').doc(burialDocSnap.data()!['cemetery_id']);
          var docSnapMaster = await docRefMaster.get();

          completeQuery['cemetery_name'] = docSnapMaster.data()?['cemetery_name'];
        }

        setState(() {
          _queryResultIDs.add(completeQuery['ndefUID']);
          _queryResults.add(completeQuery);
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }
}
