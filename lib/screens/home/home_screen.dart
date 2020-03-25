import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:location/location.dart';
import 'package:map/map.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = MapController(
    location: LatLng(40.12676, 116.21339),
    zoom: 16,
  );
  final Location location = new Location();
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
    print(_locationData.latitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open Street Map'),
      ),
      body: Map(
        controller: controller,
        provider: const CachedOsmProvider(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onLocate,
        tooltip: 'My Location',
        child: Icon(Icons.my_location),
      ),
    );
  }
}

class CachedOsmProvider extends MapProvider {
  const CachedOsmProvider();

  @override
  ImageProvider getTile(int x, int y, int z) {
    return CachedNetworkImageProvider('http://a.tile.osm.org/$z/$x/$y.png');
  }
}
