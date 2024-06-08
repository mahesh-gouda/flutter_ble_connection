import 'package:permission_handler/permission_handler.dart';
class AppPermissionHandler {

  static Future<bool> requestLocationPermission() async {
    PermissionStatus locationStatus = await Permission.location.request();
    if (locationStatus.isGranted) {
      return true;
    } else {
      return false;
    }
  }


  static Future<bool> requestBluetoothPermission() async {
    PermissionStatus bluetoothStatus = await Permission.bluetooth.request();
    if (bluetoothStatus.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> checkPermissionsGranted() async {
    PermissionStatus locationStatus = await Permission.location.status;
    PermissionStatus bluetoothStatus = await Permission.bluetooth.status;
    if (bluetoothStatus.isGranted && locationStatus.isGranted) {
      return true;
    } else {
      return false;
    }
  }


}
