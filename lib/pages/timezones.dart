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
    context.loaderOverlay.show();
    setState(() => errorSign = 'Fetching regions...');
    try {
      Response response =
          await get(Uri.parse('https://worldtimeapi.org/api/timezone/'));
      setState(() => timezones = jsonDecode(response.body));
      Future.delayed(const Duration(), () => context.loaderOverlay.hide());
    } catch (err) {
      if (err.toString().contains('HandshakeException')) {
        await getTimezones();
        return;
      }
      context.loaderOverlay.hide();
      errorSign = 'Could not load regions due to a network error.';
      setState(() => timezones = null);
      return;
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
              .split(' - ')
              .reversed
              .join(', ')
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
            'Regions',
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
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                        hintText: 'Search for a region',
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
                                        FocusScope.of(context).unfocus();
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
                                                .split(' - ')
                                                .reversed
                                                .join(', ')
                                            : searchedTimezones[i]
                                                .replaceAll('/', ' - ')
                                                .replaceAll('_', ' ')
                                                .split(' - ')
                                                .reversed
                                                .join(', '),
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
                              'Region cannot be found.',
                              style: TextStyle(fontSize: 20),
                            )),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorSign,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    if (errorSign[0] != 'F')
                      Column(
                        children: [
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: getTimezones,
                            child: const Text('Retry',
                                style: TextStyle(fontSize: 20)),
                          )
                        ],
                      ),
                  ],
                ),
              ));
  }
}
