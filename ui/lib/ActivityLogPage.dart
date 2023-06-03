import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final Map<String, String> tableNames = {
  'victim': 'Depremzede',
  'clinic': 'Klinik',
  'er': 'Acil',

  'firstaid': 'İlk Yardım',
  'morgue': 'Morg',
  'rescue': 'Arama-Kurtarma',
  'burial': 'Mezarlık-Defin',
};

class ActivityLogPage extends StatefulWidget {
  final String ndefUID;

  const ActivityLogPage({super.key, required this.ndefUID});

  @override
  _ActivityLogPageState createState() => _ActivityLogPageState();
}

const Color _primaryColor = Color(0xff6a6b83);
const Color _secondaryColor = Color(0xff77789a);
const Color _tertiaryColor = Color(0xffebebeb);
const Color _backgroundColor = Color(0xffd5d5e4);
const Color _shadowColor = Color(0x806a6b83);

class _ActivityLogPageState extends State<ActivityLogPage> {

  List<LogRecord> _logRecords = [];

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();

    // Connect to DB
    db = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    FutureBuilder(
                      future: _fetchLogRecords(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Hata: ${snapshot.error}');
                        } else {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: ListView.builder(
                                itemCount: _logRecords.length,
                                itemBuilder: (context, index) {
                                  return LogRecordWidget(logRecord: _logRecords[index]);
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
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
      ),
    );
  }

  Future<void> _fetchLogRecords() async {
    _logRecords.clear();

    try {
      CollectionReference logCol = db.collection('activity_log');

      QuerySnapshot qs = await logCol.where('ndefUID', isEqualTo: widget.ndefUID).get();

      for (QueryDocumentSnapshot qds in qs.docs) {
        Map<String, dynamic>? data = qds.data() as Map<String, dynamic>;
        DateTime date = data['date'].toDate();
        String userID = data['userID'];
        String tableName = data['table_name'];
        String ndefUID = data['ndefUID'];

        LogRecord record = LogRecord(
          date: date,
          userID: userID,
          tableName: tableName,
          ndefUID: ndefUID,
        );

        _logRecords.add(record);
      }

      _logRecords.sort((a, b) => b.date.compareTo(a.date));

    } catch (e) {
      print('Error fetching data: $e');
    }
  }
}

class LogRecordWidget extends StatelessWidget {
  final LogRecord logRecord;

  const LogRecordWidget({Key? key, required this.logRecord,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: Image.asset(
                      'assets/images/nfctag32.png',
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 10.0)),
                  Text(
                    logRecord.date.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 15.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${tableNames[logRecord.tableName]} Kaydı',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                    ),
                  ),
                  Text(
                    'Kullanıcı: ${logRecord.userID}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}

class LogRecord {
  final DateTime date;
  final String userID;
  final String tableName;
  final String ndefUID;

  LogRecord({
    required this.date,
    required this.userID,
    required this.tableName,
    required this.ndefUID,
  });
}
