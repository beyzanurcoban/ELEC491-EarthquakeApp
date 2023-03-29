import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'InputPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<dynamic> result = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Home Page UI Here
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('NFC ndef Read/Write')),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, ss) => ss.data != true
                ? Center(child: Text('NFC is available: ${ss.data}'))
                : Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.vertical,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    constraints: const BoxConstraints.expand(),
                    decoration: BoxDecoration(border: Border.all()),
                    child: SingleChildScrollView(
                      child: ValueListenableBuilder<dynamic>(
                        valueListenable: result,
                        builder: (context, value, _) =>
                            Text('${value ?? ''}'),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: GridView.count(
                    padding: const EdgeInsets.all(4),
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    children: [
                      ElevatedButton(
                          child: Text('NDEF Read'),
                          onPressed: _tagRead),
                      ElevatedButton(
                          child: Text('NDEF Write'),
                          onPressed: _ndefWrite),
                    ],
                  ),
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
      var ndef = Ndef.from(tag);
      if (ndef == null) {
        result.value = 'Tag is not ndef readable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      try {
        await ndef.read();
        if (ndef.cachedMessage == null) {
          result.value = 'Tag is empty';
          NfcManager.instance.stopSession(errorMessage: result.value);
          return;
        }
        if (ndef.cachedMessage!.records.isNotEmpty) {
          NdefRecord textRecord = ndef.cachedMessage!.records.first;
          result.value = textRecord.toString();
        } else {
          result.value = 'Tag is empty';
        }
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }

  void _ndefWrite() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      var message = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => InputPage()),
      );

      if (message == null) {
        result.value = 'Canceled';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      var records = [
        NdefRecord.createText(message),
      ];

      var ndefMessage = NdefMessage(records);

      // TODO: Buraya database call

      try {
        await ndef.write(ndefMessage);
        result.value = 'Success to "Ndef Write"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }

}