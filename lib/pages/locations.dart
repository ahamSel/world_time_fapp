import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:world_time/pages/home.dart';

class Locations extends StatefulWidget {
  const Locations({Key? key}) : super(key: key);

  @override
  _LocationsState createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {
  dynamic timezones;
  Future getTimezones() async {
    Response response =
        await get(Uri.parse('http://worldtimeapi.org/api/timezone/'));
    setState(() => timezones = jsonDecode(response.body));
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
                              builder: (context) => Home(
                                    timezone: timezones[i],
                                  )));
                    },
                    tileColor: Colors.amber[800],
                    title: Text(timezones[i]),
                  ));
                },
              )
            : Center(
                child: ElevatedButton(
                    onPressed: getTimezones, child: Text('get timezones')),
              ));
  }
}
