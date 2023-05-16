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

class _ActivityLogPageState extends State<ActivityLogPage> {

  final Color _primaryColor = const Color(0xff6a6b83);

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
      appBar: const CupertinoNavigationBar(
        middle: Text(
          "Kayıt Tarihçesi",
        ),
      ),
      body: SingleChildScrollView(
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
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
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

  final Color _primaryColor = const Color(0xff6a6b83);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.asset(
            'assets/images/log_branch.png',
          ),
          const Padding(padding: EdgeInsets.only(left: 10.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  logRecord.date.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
                Text(
                  '${tableNames[logRecord.tableName]} Kaydı Girildi/Güncellendi',
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Kullanıcı: ${logRecord.userID}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
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
