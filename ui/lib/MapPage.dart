import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<Marker> allMarkers = [];

  @override
  void initState() {
    super.initState();
    setMarkers();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const CupertinoNavigationBar(
        middle: Text(
          'Harita',
        ),
      ),
      body: FlutterMap(
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
    );
  }

  void setMarkers() {

    allMarkers.add(
      Marker(
        width: 45.0,
        height: 45.0,
        point: LatLng(widget.lat, widget.long),
        builder: (context) => Container(
          child: IconButton(
            icon: const Icon(Icons.location_on),
            color: Colors.red,
            iconSize: 45.0,
            onPressed: () {
              // TODO: Long Lat Copy to Device's Clipboard
              print('Marker pressed');
            },
          ),
        ),
      ),
    );
  }


}

