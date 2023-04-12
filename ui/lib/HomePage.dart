import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:ui/SurvivorReadPage.dart';
import 'package:ui/SurvivorWritePage.dart';

import 'InputPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Home Page UI Here
    return MaterialApp(
      home: Scaffold(
        appBar: const CupertinoNavigationBar(
          middle: Text(
            "ELEC491 NFC Takip",
          ),
        ),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, ss) => /*ss.data != true
                ? Center(child: Text('NFC is available: ${ss.data}'))
                :*/ Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          // TODO: Icon Here
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 10),
                                    child: SizedBox(
                                      height: 60,
                                      child: OutlinedButton(
                                        style: ElevatedButton.styleFrom(
                                          side: const BorderSide(
                                            width: 2.0,
                                            color: Colors.indigoAccent,
                                          ),
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        onPressed: _tagRead,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Icon(
                                              Icons.nfc_rounded,
                                              color: Colors.indigoAccent,
                                            ),
                                            Text(
                                              'NFC Etiket Oku',
                                              style: TextStyle(
                                                color: Colors.indigoAccent,
                                                fontSize: 18.0,
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
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 20),
                                    child: SizedBox(
                                      height: 60,
                                      child: FilledButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigoAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        onPressed: _ndefWrite,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Icon(
                                              Icons.edit
                                            ),
                                            Text(
                                              'NFC Etikete Yaz',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18.0,
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
                          ],
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      // Get ndefUID from NFC tag
      var ndefUID = tag.data["ndef"]["identifier"]
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join('');

      // Access database with Unique ID => ndefUID
      Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => SurvivorReadPage(ndefUID: ndefUID,)),
      );

      NfcManager.instance.stopSession();
    });
  }

  void _ndefWrite() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      // Get UID
      var ndefUID = tag.data["ndef"]["identifier"]
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join('');

      // Fetch from database with UID
      Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => SurvivorWritePage(ndefUID: ndefUID,)),
      );

      NfcManager.instance.stopSession();
    });
  }
}
