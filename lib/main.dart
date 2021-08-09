import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:world_time/pages/home.dart';
import 'package:world_time/pages/loading.dart';
import 'package:world_time/pages/locations.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/home',
    routes: {
      '/home': (context) => LoaderOverlay(child: Home()),
      '/locations': (context) => LoaderOverlay(child: Locations()),
      '/loading': (context) => LoaderOverlay(child: Loading()),
    },
  ));
}
