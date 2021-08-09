import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:world_time/pages/home.dart';

class Locations extends StatefulWidget {
  const Locations({Key? key}) : super(key: key);

  @override
  _LocationsState createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {
  String errorSign = '';
  dynamic timezones;

  Future<void> getTimezones() async {
    try {
      context.loaderOverlay.show();
      Response response =
          await get(Uri.parse('http://worldtimeapi.org/api/timezone/'));
      context.loaderOverlay.hide();
      setState(() => timezones = jsonDecode(response.body));
    } catch (err) {
      print(err.toString());
      errorSign =
          'Could not load timezones. Please check your internet connection.';
      setState(() => timezones = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: timezones != null
            ? ListView.builder(
                itemCount: timezones.length,
                itemBuilder: (context, i) {
                  return Center(
                      child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoaderOverlay(
                                    child: Home(
                                      timezone: timezones[i],
                                    ),
                                  )));
                    },
                    tileColor: Colors.amber[800],
                    title: Text(timezones[i]),
                  ));
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: getTimezones, child: Text('Get Timezones')),
                    SizedBox(
                      height: 30,
                    ),
                    Text(errorSign)
                  ],
                ),
              ));
  }
}
