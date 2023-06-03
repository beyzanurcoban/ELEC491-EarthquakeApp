import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  final double lat;
  final double long;

  const MapPage({
    super.key,
    required this.lat,
    required this.long,
  });

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Color _primaryColor = const Color(0xff6a6b83);
  final Color _secondaryColor = const Color(0xff77789a);
  final Color _tertiaryColor = const Color(0xffebebeb);
  final Color _backgroundColor = const Color(0xffd5d5e4);
  final Color _shadowColor = const Color(0x806a6b83);

  List<Marker> allMarkers = [];

  @override
  void initState() {
    super.initState();
    setMarkers();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                center: LatLng(widget.lat, widget.long),
                minZoom: 3.0,
                maxZoom: 17.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: allMarkers,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: 48,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: _primaryColor,
                        ),
                        iconSize: 32,
                        onPressed: () {Navigator.pop(context);},
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Text(
                          'Lokasyon için iğneye dokun',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _primaryColor,
                          ),
                        ),
                      ),
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

  void setMarkers() {

    allMarkers.add(
      Marker(
        width: 45.0,
        height: 45.0,
        point: LatLng(widget.lat, widget.long),
        builder: (context) => IconButton(
          icon: const Icon(Icons.location_on),
          color: Colors.red,
          iconSize: 45.0,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: '${widget.lat} ${widget.long}'))
                .then((_) { //only if ->
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lokasyon kopyalandı!'))
                ); // ScaffoldMessenger
            });// -> show a notification
          },
        ),
      ),
    );
  }


}

