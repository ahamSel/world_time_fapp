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
      theme: ThemeData(
          fontFamily: 'Lexend',
          primaryColor: Colors.red,
          accentColor: Colors.red[200],
          highlightColor: Colors.redAccent,
          inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.red),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 3),
                  borderRadius: BorderRadius.all(Radius.circular(10)))),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.redAccent),
                padding: MaterialStateProperty.all(EdgeInsets.all(13)),
                backgroundColor: MaterialStateProperty.all(Colors.red),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)))),
          ),
          scrollbarTheme: ScrollbarThemeData(
              interactive: true,
              radius: Radius.circular(5),
              thickness: MaterialStateProperty.all(13),
              thumbColor: MaterialStateProperty.all(Colors.red)))));
}
