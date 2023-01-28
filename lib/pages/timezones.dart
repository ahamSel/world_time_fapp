import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:world_time/pages/home.dart';
import 'package:world_time/pages/loading.dart';

class Timezones extends StatefulWidget {
  const Timezones({Key? key}) : super(key: key);

  @override
  State<Timezones> createState() => _TimezonesState();
}

class _TimezonesState extends State<Timezones> {
  String errorSign = '';
  dynamic timezones;
  List<String> searchedTimezones = [];

  final textController = TextEditingController();

  Future<void> getTimezones() async {
    try {
      context.loaderOverlay.show();
      Response response =
          await get(Uri.parse('https://worldtimeapi.org/api/timezone/'));
      Future.delayed(
          const Duration(seconds: 1), () => context.loaderOverlay.hide());
      setState(() => timezones = jsonDecode(response.body));
    } catch (err) {
      errorSign = 'Could not load timezones due to a network error.';
      setState(() => timezones = null);
    }
  }

  void getSearchedTimezones() {
    searchedTimezones.clear();
    setState(() {
      if (textController.text.isNotEmpty) {
        for (dynamic timezone in timezones) {
          if (timezone
              .replaceAll('/', ' - ')
              .replaceAll('_', ' ')
              .toLowerCase()
              .contains(textController.text.toLowerCase())) {
            searchedTimezones.add(timezone);
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getTimezones();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.red[100],
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
          title: const Text(
            'Timezones',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          backgroundColor: Colors.red,
          centerTitle: true,
          elevation: 0.5,
        ),
        body: timezones != null
            ? Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                    child: TextField(
                      onChanged: (value) {
                        textController.text = value;
                        textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: textController.text.length));
                        getSearchedTimezones();
                      },
                      controller: textController,
                      cursorColor: Colors.red,
                      decoration: const InputDecoration(
                        hintText: 'Search for a timezone',
                      ),
                    ),
                  ),
                  Expanded(
                    child: (searchedTimezones.isEmpty &&
                                textController.text.isEmpty) ||
                            searchedTimezones.isNotEmpty
                        ? Scrollbar(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ListView.builder(
                                itemCount: searchedTimezones.isEmpty
                                    ? timezones.length
                                    : searchedTimezones.length,
                                itemBuilder: (context, i) {
                                  return Center(
                                      child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    elevation: 5,
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoaderOverlay(
                                                      useDefaultLoading: false,
                                                      overlayWidget:
                                                          const Loading(),
                                                      child: Home(
                                                        timezone: searchedTimezones
                                                                .isEmpty
                                                            ? timezones[i]
                                                            : searchedTimezones[
                                                                i],
                                                      ),
                                                    )));
                                      },
                                      tileColor: Colors.red,
                                      title: Text(
                                        searchedTimezones.isEmpty
                                            ? timezones[i]
                                                .replaceAll('/', ' - ')
                                                .replaceAll('_', ' ')
                                            : searchedTimezones[i]
                                                .replaceAll('/', ' - ')
                                                .replaceAll('_', ' '),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ));
                                },
                              ),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.only(top: 50),
                            child: const Text(
                              'Timezone cannot be found.',
                              style: TextStyle(fontSize: 20),
                            )),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Fetching timezones...',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(errorSign)
                  ],
                ),
              ));
  }
}
