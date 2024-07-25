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
  String userTimezone = '', time = '';

  Future<void> getUserTimezone() async {
    try {
      http.Response response =
          await http.get(Uri.parse('https://worldtimeapi.org/'));
      dom.Document html = parse(response.body);
      userTimezone = html
          .querySelector('code.language-shell')!
          .innerHtml
          .split('timezone')[1]
          .replaceAll('"', '')
          .substring(1);
    } catch (err) {
      if (err.toString().contains('HandshakeException')) {
        await getUserTimezone();
        return;
      }
      if (mounted) {
        context.loaderOverlay.hide();
      }
      setState(() {
        if (!userTimezone.contains('/')) {
          userTimezone = 'Error fetching region';
        }
        time = 'Error fetching time';
      });
      return;
    }
  }

  Future<void> getTime(String timezone) async {
    try {
      http.Response response = await http
          .get(Uri.parse('https://worldtimeapi.org/api/timezone/$timezone'));
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
    } catch (err) {
      if (err.toString().contains('HandshakeException')) {
        await getTime(timezone);
        return;
      }
      if (mounted) {
        context.loaderOverlay.hide();
      }
      setState(() => time = 'Error fetching time');
      return;
    }
  }

  Future<void> showTime() async {
    context.loaderOverlay.show();
    setState(() {
      if (!userTimezone.contains('/')) {
        userTimezone = 'Fetching region...';
      }
      time = 'Fetching time...';
    });
    try {
      if (widget.timezone == null) {
        await getUserTimezone();
        await getTime(userTimezone);
      } else {
        await getTime(widget.timezone!);
      }
      Future.delayed(const Duration(), () => context.loaderOverlay.hide());
    } catch (err) {
      if (mounted) {
        context.loaderOverlay.hide();
      }
      setState(() => time = 'Error fetching time');
      return;
    }
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
                        userTimezone
                            .replaceAll('/', ' - ')
                            .replaceAll('_', ' ')
                            .split(' - ')
                            .reversed
                            .join(', '),
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  if (time.contains('\n'))
                    Column(
                      children: [
                        Text(
                          time.split('\n')[0],
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          time.split('\n')[1],
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          time,
                          style: const TextStyle(fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                        if (time[0] != 'F')
                          Column(
                            children: [
                              const SizedBox(height: 40),
                              ElevatedButton(
                                  onPressed: showTime,
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(fontSize: 20),
                                  ))
                            ],
                          ),
                      ],
                    ),
                ],
              ),
              ElevatedButton(
                  child: const Text(
                    'Choose another region',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/timezones')),
            ],
          ),
        ),
      )),
    );
  }
}
