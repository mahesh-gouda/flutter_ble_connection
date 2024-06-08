import 'package:bluetotth_connectivity/router/router.dart';
import 'package:flutter/material.dart';

import '../bluetooth_core/permission_handler.dart';

class BluetoothUi extends StatefulWidget {
  const BluetoothUi({super.key});

  @override
  State<BluetoothUi> createState() => _BluetoothUiState();
}

class _BluetoothUiState extends State<BluetoothUi> {

  redirectUser() async {
    ///Need to handle the logic better
    bool isPermissionGiven = await  AppPermissionHandler.checkPermissionsGranted();

    if(isPermissionGiven){
      Navigator.pushNamed(context, Routes.listingPage);
    }else{
      bool locationPermission = await AppPermissionHandler.requestLocationPermission();
      if(locationPermission){
        bool bluetoothPermission = await AppPermissionHandler.requestBluetoothPermission();
        if(bluetoothPermission){
          Navigator.pushNamed(context, Routes.listingPage);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: ElevatedButton(onPressed: (){
                      redirectUser();
                  }, child: Text("Request & redirect")),
                )
              ],
            ),
          ),
        ));
  }
}
