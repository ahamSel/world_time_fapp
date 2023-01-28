import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';

class Home extends StatefulWidget {
  final String? timezone;

  const Home({Key? key, this.timezone}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer timer = Timer(const Duration(seconds: 1), () {});
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
      return 'error';
    }
  }

  Future<void> getTime(String timezone) async {
    try {
      http.Response response = await http
          .get(Uri.parse('https://worldtimeapi.org/api/timezone/$timezone'));
      Future.delayed(const Duration(), () {
        Map data = jsonDecode(response.body);
        DateTime timeNow = DateTime.parse(data['datetime']);
        String utcOffset = data['utc_offset'];
        timeNow = timeNow.add(Duration(
            hours: int.parse(utcOffset.substring(0, 3)),
            minutes: int.parse(
                '${utcOffset.substring(0, 1)}${utcOffset.substring(4)}')));
        setState(
            () => time = DateFormat("yyyy-MM-dd\nh:mm:ss a").format(timeNow));
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            timeNow = timeNow.add(const Duration(seconds: 1));
            time = DateFormat("yyyy-MM-dd\nh:mm:ss a").format(timeNow);
          });
        });
      });
    } catch (err) {
      setState(() => time = 'Unkown error!');
    }
  }

  Future<void> showTime() async {
    context.loaderOverlay.show();
    if (widget.timezone == null) {
      usrTimezone = await getUserTimezone();
      await getTime(usrTimezone);
    } else {
      await getTime(widget.timezone!);
    }
    Future.delayed(const Duration(), () => context.loaderOverlay.hide());
  }

  @override
  void initState() {
    super.initState();
    showTime();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).viewInsets.bottom != 0) {
      FocusScope.of(context).unfocus();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.red[100],
      body: SafeArea(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    widget.timezone
                            ?.replaceAll('/', ' - ')
                            .replaceAll('_', ' ')
                            .split(' - ')
                            .reversed
                            .join(', ') ??
                        usrTimezone
                            .replaceAll('/', ' - ')
                            .replaceAll('_', ' ')
                            .split(' - ')
                            .reversed
                            .join(', '),
                    style: const TextStyle(fontSize: 40),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  Column(
                    children: [
                      Text(
                        time?.split('\n')[0] ?? 'Loading...',
                        style: const TextStyle(fontSize: 30),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        time?.split('\n')[1] ?? 'Loading...',
                        style: const TextStyle(fontSize: 40),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                ],
              ),
              ElevatedButton(
                  child: const Text(
                    'Choose another region',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () => widget.timezone == null
                      ? Navigator.popAndPushNamed(context, '/timezones')
                      : Navigator.pop(context)),
            ],
          ),
        ),
      )),
    );
  }
}
