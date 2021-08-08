import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  final String? timezone;

  Home({this.timezone});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? time;

  Future<String> getUserTimezone() async {
    http.Response response =
        await http.get(Uri.parse('https://worldtimeapi.org/'));
    dom.Document html = parse(response.body);
    String? userTimezone = html
        .querySelector('code.language-shell')
        ?.innerHtml
        .split('timezone')[1]
        .replaceAll('"', '')
        .substring(1);
    return userTimezone ?? 'querySelector may have changed';
  }

  Future<void> getTime(String timezone) async {
    http.Response response = await http
        .get(Uri.parse('http://worldtimeapi.org/api/timezone/$timezone'));
    Map data = jsonDecode(response.body);
    DateTime timeNow = DateTime.parse(data['datetime']);
    String utcOffset = data['utc_offset'];
    utcOffset = utcOffset.substring(0, 3);
    timeNow = timeNow.add(Duration(hours: int.parse(utcOffset)));
    setState(() => time = DateFormat.jm().format(timeNow));
  }

  Future<void> showTime() async {
    if (widget.timezone == null) {
      String timezone = await getUserTimezone();
      await getTime(timezone);
    } else
      await getTime(widget.timezone!);
  }

  @override
  void initState() {
    super.initState();
    showTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Row(
        children: [
          ElevatedButton(
              child: Text(
                'Refresh',
              ),
              onPressed: showTime),
          SizedBox(
            width: 50,
          ),
          Text(
            time ?? 'No value',
          ),
          SizedBox(
            width: 50,
          ),
          ElevatedButton(
              onPressed: () => widget.timezone == null
                  ? Navigator.popAndPushNamed(context, '/locations')
                  : Navigator.pop(context),
              child: Text('Edit Location'))
        ],
      )),
    );
  }
}
