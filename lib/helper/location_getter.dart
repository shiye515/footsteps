import 'package:location/location.dart';

class LocationGetter {
  // 单例公开访问点
  factory LocationGetter() => _sharedInstance();

  // 静态私有成员，没有初始化
  static LocationGetter _instance;
  Location _location;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  // 私有构造函数
  LocationGetter._() {
    // 具体初始化代码
    _location = Location();
  }

  Stream<LocationData> get locations => _location.onLocationChanged();
  Future<LocationData> getLocation() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return null;
      }
    }

    return _location.getLocation();
  }

  // 静态、同步、私有访问点
  static LocationGetter _sharedInstance() {
    if (_instance == null) {
      _instance = LocationGetter._();
    }
    return _instance;
  }
}
