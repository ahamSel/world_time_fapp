import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:world_time/pages/home.dart';
import 'package:world_time/pages/loading.dart';
import 'package:world_time/pages/timezones.dart';

void main() {
  runApp(MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) => LoaderOverlay(
            child: Home(), useDefaultLoading: false, overlayWidget: Loading()),
        '/timezones': (context) => LoaderOverlay(
            child: Timezones(),
            useDefaultLoading: false,
            overlayWidget: Loading()),
      },
      theme: ThemeData(fontFamily: 'Lexend')));
}
