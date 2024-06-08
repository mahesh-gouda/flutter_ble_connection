import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothListingScreen extends StatefulWidget {
  const BluetoothListingScreen({super.key});

  @override
  State<BluetoothListingScreen> createState() => _BluetoothListingScreenState();
}

class _BluetoothListingScreenState extends State<BluetoothListingScreen> {

 late StreamSubscription<BluetoothAdapterState> subscription;

 List<ScanResult>? results;

 BluetoothDevice? connectedDevice;

 List<BluetoothService>? services;


  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    startBluetoothListners();
    super.initState();
  }


  @override
  void dispose() {
    // cancel to prevent duplicate listeners
    subscription.cancel();
    super.dispose();
  }



  Future<void> startBluetoothListners() async{
    // first, check if bluetooth is supported by your hardware
// Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

// handle bluetooth on & off
// note: for iOS the initial state is typically BluetoothAdapterState.unknown
// note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
     subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
        print("Bluetooth Turned ON");
        listDevices();

      } else {
        // show an error to the user, etc

        print("Bluetooth Turned off");
      }
    });

    // listDevices();

// turn on bluetooth ourself if we can
// for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
     await FlutterBluePlus.turnOn();
    }
  }


  Future<void> listDevices() async{
    // listen to scan results
// Note: `onScanResults` only returns live scan results, i.e. during scanning. Use
//  `scanResults` if you want live scan results *or* the results from a previous scan.
    var subscription = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isNotEmpty) {

        ScanResult r = results.last; // the most recently found device
        print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
        setState(() {
          this.results = results;
        });
      }
    },
      onError: (e) => print(e),
    );

// cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);
//
// // Wait for Bluetooth enabled & permission granted
// // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
//     await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;

// Start scanning w/ timeout
// Optional: use `stopScan()` as an alternative to timeout
    await FlutterBluePlus.startScan(
      withKeywords:["Evie"],
    );
    
  }


  Future connectDevice(BluetoothDevice device) async{

    await FlutterBluePlus.stopScan();
    // listen for disconnection
    var subscription = device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        // 1. typically, start a periodic timer that tries to
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!
        print("${device.isConnected} ${device.disconnectReason}");
      }else  if (state == BluetoothConnectionState.connected) {
        // Force the bonding popup to show now (Android Only)
        await device.createBond();
        connectedDevice = device;
        listServices();

      }
    });


//     await device.connect();
//     // enable auto connect
// //  - note: autoConnect is incompatible with mtu argument, so you must call requestMtu yourself
    await device.connect(autoConnect:true, mtu:null);
    // await device.requestMtu(512);

     BotToast.closeAllLoading();
  }

  Future listServices() async {
    // Note: You must call discoverServices after every re-connection!
    services = await connectedDevice!.discoverServices();
    services?.forEach((service) {
      // do something with service
      print("ServiceId: ${service.serviceUuid}  ");
      for (var characteristic in service.characteristics) {
        print("Characteristics: ${characteristic.characteristicUuid}");
      }
    });



  }

  
  Future writeData(String command) async {
    BluetoothCharacteristic? char;
    services?.forEach((service) {
      if (service.serviceUuid == Guid("b56c04ea-6cba-4dd4-83b9-7f3056a1bac5")) {
        // do something with service
        print("ServiceId: ${service.serviceUuid}  ");
        for (var characteristic in service.characteristics) {
          if (characteristic.characteristicUuid == Guid("6ae5deca-d2d0-4e13-a662-ad16e9a78dde")) {
            print("Characteristics: ${characteristic.characteristicUuid}");
            char = characteristic;
          }
        }
      }
    });
    
    if(char != null){
      final subscription = char!.lastValueStream.listen((value) {
        // lastValueStream` is updated:
        //   - anytime read() is called
        //   - anytime write() is called
        //   - anytime a notification arrives (if subscribed)
        //   - also when first listened to, it re-emits the last value for convenience.

        print("Value is: ${value}");
        print("Converted value is: ${String.fromCharCodes(value)}");
      });

// cleanup: cancel subscription when disconnected
      connectedDevice!.cancelWhenDisconnected(subscription);

// enable notifications
      await char!.setNotifyValue(true);

     await char?.write(command.codeUnits,withoutResponse: false,allowLongWrite: true,timeout: 100);
     await subscription.cancel();

    }
    
    
  }

  @override
  Widget build(BuildContext context) {
     if(results == null) {
       return Scaffold(
         body: Container(
           color: Colors.white,
           child: Center(
             child: Text("Scanning..."),
           ),
         ),
       );
     }else {
       return Scaffold(
         body: Container(
           color: Colors.white,
           child: SingleChildScrollView(
             child: Column(
               children: [
             SizedBox(
               height: 700,
               child: ListView.builder(
               itemCount: results!.length,
                 itemBuilder: (context, index) {
                   final device = results![index].device;
                   return ListTile(
                     title: Text('${device.remoteId}: "${ results![index].advertisementData.advName}" found!'),
                     subtitle: Text(device.advName.toString()),
                     onTap: () async{

                       BotToast.showLoading();
                      await  connectDevice(device);
                     },
                   );
                 },
               ),
             ),

                 SizedBox(height: 50,),

                 ElevatedButton(onPressed: (){
                   String result = "\$S 9f0e2k false";
                   writeData(result);
                 }, child: Text("Write Data 1")),

                 SizedBox(height: 50,),

                 ElevatedButton(onPressed: (){
                   String result = "\$S 9f0e2k true";
                   writeData(result);
                 }, child: Text("Write Data 2")),
               ],
             ),
           ),
         ),
       );
     }
  }
}
