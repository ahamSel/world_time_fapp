import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';

class Home extends StatefulWidget {
  final String? timezone;

  Home({this.timezone});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String usrTimezone = '';
  String? time;

  Future<String> getUserTimezone() async {
    try {
      http.Response response =
          await http.get(Uri.parse('https://worldtimeapi.org/'));
      dom.Document html = parse(response.body);
      String? userTimezone = html
          .querySelector('code.language-shell')
          ?.innerHtml
          .split('timezone')[1]
          .replaceAll('"', '')
          .substring(1);
      return userTimezone!;
    } catch (err) {
      print(err.toString());
      return 'error';
    }
  }

  Future<void> getTime(String timezone) async {
    try {
      http.Response response = await http
          .get(Uri.parse('https://worldtimeapi.org/api/timezone/$timezone'));
      Map data = jsonDecode(response.body);
      DateTime timeNow = DateTime.parse(data['datetime']);
      String utcOffset = data['utc_offset'];
      utcOffset = utcOffset.substring(0, 3);
      timeNow = timeNow.add(Duration(hours: int.parse(utcOffset)));
      setState(() => time = DateFormat.jm().format(timeNow));
    } catch (err) {
      print(err.toString());
      setState(() =>
          time = 'Could not load time. Please check your internet connection.');
    }
  }

  Future<void> showTime() async {
    context.loaderOverlay.show();
    if (widget.timezone == null) {
      usrTimezone = await getUserTimezone();
      await getTime(usrTimezone);
    } else
      await getTime(widget.timezone!);
    context.loaderOverlay.hide();
  }

  @override
  void initState() {
    super.initState();
    showTime();
  }

  @override
  Widget build(BuildContext context) {
    final keybrOnScreen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      backgroundColor: Colors.red[100],
      body: SafeArea(
          child: Center(
        child: !keybrOnScreen
            ? Column(
                children: [
                  SizedBox(height: 35),
                  ElevatedButton(
                      child: Text(
                        'Edit timezone',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () => widget.timezone == null
                          ? Navigator.popAndPushNamed(context, '/timezones')
                          : Navigator.pop(context)),
                  SizedBox(
                    height: 100,
                  ),
                  Container(
                    width: 350,
                    height: 100,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        widget.timezone ?? usrTimezone,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(time ?? 'Loading time...',
                      style:
                          TextStyle(fontSize: 50, fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 200,
                  ),
                  ElevatedButton(
                      child: Text(
                        'Refresh',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: showTime),
                ],
              )
            : Text(
                'Your keyboard is on the way.\nPlease lower it...',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
      )),
    );
  }
}
