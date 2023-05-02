import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {

  const SearchPage({super.key,});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final Color _selectedBoxColor = Colors.blue;
  final Color _unselectedBoxColor = Colors.transparent;

  final Color _selectedTextColor = Colors.white;
  final Color _unselectedTextColor = Colors.blue;

  final TextEditingController _searchTermInputController = TextEditingController();

  List<String> _queryResults = <String>[];

  final Map<String, String> _tables = {
    'victim': 'Depremzede',
    'clinic': 'Hastane',
    'er': 'Acil',
    'firstaid': 'İlk Yardım',
    'morgue': 'Morg',
    'rescue': 'Arama-Kurtarma',
    'ambulance': 'Ambulans',
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
      body: SingleChildScrollView(
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
                                searchAndDisplay(searchTerm);
                              },
                            ),
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
                  height: 50, // adjust the height as needed
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tables.length,
                    itemBuilder: (context, index) {
                      final key = _tables.keys.elementAt(index);
                      final value = _tables.values.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
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
                            value,
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 50, // adjust the height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _queryResults.length,
                      itemBuilder: (context, index) {
                        final queryResult = _queryResults.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
                          child: Text(
                            queryResult,
                          )
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> searchAndDisplay(String searchTerm) async {
    final docRefs = await db.collection(_selectedTable).get();
    final docs = docRefs.docs.where((doc) => doc.data().containsValue(searchTerm));

    setState(() {
      _queryResults.clear();
      for (var element in docs) {
        _queryResults.add(element.data().toString());
      }
    });
  }
}
