import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';


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

  Future<void> loadAndOpen(String link) async {
    final url = Uri.parse("https://www.soa.ac.in$link");
    var response = await http.get(url);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      var link2 = document.querySelectorAll('article > div > div > div > div > div > div > div > div > div > a');
      print(link2);
      var x = link2[0].attributes['href'];
      _launchUrl(link2[0].attributes['href'] ?? link);
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

  Future<List<Widget>> getData() async {
    final url = Uri.parse("https://www.soa.ac.in/iter-news-and-events");
    var response = await http.get(url);
    List<Widget> data = [];

    if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      var dates = document.querySelectorAll("div > div > span.blog-meta-secondary > time");
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
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dates[i].text.trim(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          link.text.trim(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print(link.attributes['href']);
                      loadAndOpen(link.attributes['href'] ?? "");
                    },
                    child: const Text("View"),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: _noticeData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading data"));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return snapshot.data![index];
            },
          );
        }
      },
    );
  }
}
