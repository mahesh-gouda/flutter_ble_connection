import 'package:bluetotth_connectivity/ui/bluetooth_listing_screen.dart';
import 'package:bluetotth_connectivity/ui/bluetooth_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String homePage = "/home";
  static const String listingPage = "/listingPage";

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case homePage:
        return MaterialPageRoute(
            builder: (context) => BluetoothUi(),
            settings: RouteSettings(name: homePage));


      case listingPage:
        return MaterialPageRoute(
            builder: (context) => BluetoothListingScreen(),
            settings: RouteSettings(name: listingPage));



      default:
        return MaterialPageRoute(
            builder: (context) => BluetoothUi(),
            settings: RouteSettings(name: homePage));
    }
  }
}
