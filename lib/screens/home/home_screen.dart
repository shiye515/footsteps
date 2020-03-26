import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:footsteps/helper/location_getter.dart';
import 'package:footsteps/token.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final mapController = MapController();
  final LocationGetter locationGetter = LocationGetter();
  StreamSubscription subscription;

  LatLng point;
  List<LatLng> points = [];

  void onLocate() async {
    var data = await locationGetter.getLocation();
    onLocationChange(data);
  }

  onLocationChange(LocationData data) {
    var p = LatLng(data.latitude, data.longitude).round();
    if (p != point) {
      point = p;
      points.add(p);
      mapController.move(p, mapController.zoom);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    subscription = locationGetter.locations.listen(onLocationChange);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('mapbox'),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(40, 116),
          zoom: 14.0,
        ),
        layers: [
          TileLayerOptions(
            // urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            // subdomains: ['a', 'b', 'c'],
            urlTemplate:
                "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}",
            additionalOptions: {
              'accessToken': mapboxToken,
            },
          ),
          MarkerLayerOptions(markers: <Marker>[
            Marker(
              width: 20.0,
              height: 20.0,
              point: point,
              builder: (ctx) => Icon(
                Icons.my_location,
                color: Colors.blueAccent,
                size: 20,
              ),
              anchorPos: AnchorPos.align(AnchorAlign.center),
            ),
          ]),
          PolylineLayerOptions(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 1.0,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onLocate,
        tooltip: 'My Location',
        child: Icon(Icons.my_location),
      ),
    );
  }
}
