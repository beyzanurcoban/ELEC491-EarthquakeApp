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
          center: LatLng(39.50, 34.50),
          minZoom: 10.0,
        ),
        children: [
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
            iconSize: 25.0,
            onPressed: () {
              print('Marker pressed');
            },
          ),
        ),
      ),
    );
  }


}

