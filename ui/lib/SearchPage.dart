import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SurvivorReadPage.dart';

class SearchPage extends StatefulWidget {

  const SearchPage({super.key,});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isLoading = false;

  final Color _selectedBoxColor = Colors.blue;
  final Color _unselectedBoxColor = Colors.transparent;

  final Color _selectedTextColor = Colors.white;
  final Color _unselectedTextColor = Colors.blue;

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
      appBar: const CupertinoNavigationBar(
        middle: Text(
          "Ara",
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search
                          ),
                          const Padding(padding: EdgeInsets.only(left: 8.0)),
                          Expanded(
                            child: TextField(
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
                          const Padding(padding: EdgeInsets.only(left: 8.0)),
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
                                            height: 14,
                                            width: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
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
                  )
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 34, // adjust the height as needed
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: _tableToListOfTables.length,
                    itemBuilder: (context, index) {
                      final key = _tableToListOfTables.keys.elementAt(index);
                      final value = _tables[key];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0,),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedTable = key;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              width: 1.0,
                              color: Colors.blue,
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
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _queryResults.length,
                  itemBuilder: (context, index) {
                    final queryResult = _queryResults.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push<String>(
                            context,
                            MaterialPageRoute(builder: (context) => SurvivorReadPage(ndefUID: queryResult['ndefUID'],)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '${queryResult['victim_name']} ${queryResult['victim_surname']}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(bottom: 4.0)),
                              Text(
                                '${queryResult['city'] ?? 'İlçe Bilgisi Yok'}, ${queryResult['province'] ?? 'İl Bilgisi Yok'}',
                                style: const TextStyle(
                                    color: Colors.black54,
                                ),
                              ),
                              Text(
                                'Hastane: ${queryResult['hospital_name']  ?? 'Girilmemiş'}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                'Mezarlık: ${queryResult['cemetery_name'] ?? 'Girilmemiş'}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
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
