import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  Future<PermissionStatus> requestPermission() async {
    final permission = await location.requestPermission();
    return permission;
  }

  Future<LocationData> getCurrentLocation() async {
    final serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      if (await location.requestService() == false) {
        throw Exception('GPS service not enabled');
      }
    }

    final permissionGranted = await requestPermission();
    if (permissionGranted == PermissionStatus.denied ||
        permissionGranted == PermissionStatus.deniedForever) {
      throw Exception("Location Permission not granted");
    }

    return await location.getLocation();
  }
}
