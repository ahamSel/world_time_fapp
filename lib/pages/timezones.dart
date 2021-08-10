import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:world_time/pages/home.dart';
import 'package:world_time/pages/loading.dart';

class Timezones extends StatefulWidget {
  const Timezones({Key? key}) : super(key: key);

  @override
  _TimezonesState createState() => _TimezonesState();
}

class _TimezonesState extends State<Timezones> {
  String errorSign = '';
  dynamic timezones;

  Future<void> getTimezones() async {
    try {
      context.loaderOverlay.show();
      Response response =
          await get(Uri.parse('https://worldtimeapi.org/api/timezone/'));
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
  void initState() {
    super.initState();
    getTimezones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.red[100],
        appBar: AppBar(
          title: Text(
            'Timezones',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
          ),
          backgroundColor: Colors.red,
          centerTitle: true,
          elevation: 0.5,
        ),
        body: timezones != null
            ? ListView.builder(
                itemCount: timezones.length,
                itemBuilder: (context, i) {
                  return Center(
                      child: Card(
                    elevation: 5,
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoaderOverlay(
                                      useDefaultLoading: false,
                                      overlayWidget: Loading(),
                                      child: Home(
                                        timezone: timezones[i],
                                      ),
                                    )));
                      },
                      tileColor: Colors.red,
                      title: Text(
                        timezones[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                  ));
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Fetching timezones...'),
                    SizedBox(
                      height: 30,
                    ),
                    Text(errorSign)
                  ],
                ),
              ));
  }
}
