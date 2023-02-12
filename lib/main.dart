import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:world_time/pages/home.dart';
import 'package:world_time/pages/loading.dart';
import 'package:world_time/pages/timezones.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/home',
        routes: {
          '/home': (context) => const LoaderOverlay(
              useDefaultLoading: false,
              overlayWidget: Loading(),
              child: Home()),
          '/timezones': (context) => const LoaderOverlay(
              useDefaultLoading: false,
              overlayWidget: Loading(),
              child: Timezones()),
        },
        theme: ThemeData(
          fontFamily: 'Lexend',
          primaryColor: Colors.red,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.red[200]),
          highlightColor: Colors.redAccent,
          inputDecorationTheme: const InputDecorationTheme(
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
                padding: MaterialStateProperty.all(const EdgeInsets.all(13)),
                backgroundColor: MaterialStateProperty.all(Colors.red),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)))),
          ),
          scrollbarTheme: ScrollbarThemeData(
              interactive: true,
              radius: const Radius.circular(5),
              thickness: MaterialStateProperty.all(13),
              thumbColor: MaterialStateProperty.all(Colors.red)),
        ));
  }
}
