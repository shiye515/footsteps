import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:footsteps/token.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = MapController();
  final Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  void onLocate() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    _locationData = await location.getLocation();
    controller.move(
      LatLng(_locationData.latitude, _locationData.longitude),
      controller.zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    var markers = <Marker>[
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(40.12676, 116.21339),
        builder: (ctx) => Container(
          child: FlutterLogo(),
        ),
        anchorPos: AnchorPos.align(AnchorAlign.center),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('mapbox'),
      ),
      body: FlutterMap(
        mapController: controller,
        options: MapOptions(
          center: LatLng(40.12676, 116.21339),
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
          MarkerLayerOptions(markers: markers),
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
