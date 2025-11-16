import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SmartDesk",
      home: NoticeList(),
    );
  }
}

// -------------------------------------------------------------
//                        NOTICE LIST
// -------------------------------------------------------------
class NoticeList extends StatefulWidget {
  const NoticeList({Key? key}) : super(key: key);

  @override
  _NoticeListState createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> {
  late Future<List<Widget>> _noticeData;

  @override
  void initState() {
    super.initState();
    _noticeData = getData();
  }

  // ------------ REFRESH HANDLER ----------
  Future<void> _onRefresh() async {
    setState(() {
      _noticeData = getData();
    });
  }

  // ------------ OPEN PAGE --------------
  Future<void> loadAndOpen(String link) async {
    final url = Uri.parse("https://www.soa.ac.in$link");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      var link2 = document.querySelectorAll(
          'article > div > div > div > div > div > div > div > div > div > a');

      var href = link2.isNotEmpty ? link2[0].attributes['href'] : link;
      _launchUrl(href ?? link);
    } else {
      Fluttertoast.showToast(
        msg: "Unable to connect to http://soa.ac.in",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black12,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _launchUrl(String link) async {
    final Uri _url = Uri.parse(link);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  // ------------ SCRAPE WEBSITE --------------
  Future<List<Widget>> getData() async {
    final url = Uri.parse("https://www.soa.ac.in/iter-news-and-events");
    var response = await http.get(url);
    List<Widget> data = [];

    if (response.statusCode == 200) {
      var document = parser.parse(response.body);

      var dates = document
          .querySelectorAll("div > div > span.blog-meta-secondary > time");

      var links = document.querySelectorAll('div > h1 > a');

      for (var i = 0; i < links.length; i++) {
        var link = links[i];

        if (link.attributes['href'] != null) {
          data.add(
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF0A7AFF), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // LEFT SIDE
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dates[i].text.trim(),
                            style: TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            link.text.trim(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // RIGHT SIDE BUTTON
                    ElevatedButton(
                      onPressed: () {
                        loadAndOpen(link.attributes['href'] ?? "");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0A7AFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text("View"),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    return data;
  }

  // ------------ UI BUILDER --------------
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder<List<Widget>>(
        future: _noticeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Image.asset("assets/offline.png", width: 180),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "No Internet Connection",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(child: Text("Swipe down to retry")),
              ],
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return snapshot.data![index];
            },
          );
        },
      ),
    );
  }
}
