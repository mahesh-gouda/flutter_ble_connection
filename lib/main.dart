import 'package:bluetotth_connectivity/bluetooth_core/permission_handler.dart';
import 'package:bluetotth_connectivity/router/router.dart';
import 'package:bluetotth_connectivity/ui/bluetooth_ui.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color:true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});




  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      builder: BotToastInit(),
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BluetoothUi(),
      onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
    );
  }
}
