import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart';
import 'curriculum.dart';
import 'about.dart';
import 'Calendar.dart';
import 'notice_event.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartDesk',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SmartDesk(),
    );
  }
}

class SmartDesk extends StatefulWidget {
  @override
  _SmartDeskState createState() => _SmartDeskState();
}

class _SmartDeskState extends State<SmartDesk> {
  int _selectedIndex = 0;
  late Future<List<Widget>> _noticeData;

  @override
  void initState() {
    super.initState();
    _noticeData = getData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _launchUrl(String link) async {
    link = "https://www.soa.ac.in$link";
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
      var date = document.querySelectorAll(
        "div > div > span.blog-meta-secondary > time",
      );

      var links = document.querySelectorAll('div > h1 > a');
      var i = 0;
      for (var link in links) {
        if (link.attributes['href'] != null) {
          data.add(
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                          date[i].text.trim(),
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          link.text.trim(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _launchUrl(link.attributes['href'] ?? "");
                    },
                    child: Text("View"),
                  ),
                ],
              ),
            ),
          );
        }
        i += 1;
      }
    } else {
      print("Failed to load page: ${response.statusCode}");
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      NoticeList(),
      Calendar(),
      CurriculumPage(jsonUrl: "https://raw.githubusercontent.com/imtiyaz-allam/SmartDesk-backend/refs/heads/main/curriculum.json"),
    ];

    return Scaffold(
      appBar: AppBar(title: Text("SmartDesk"), actions: [
        IconButton(
          icon: const Icon(
            Icons.info,
            color: Colors.blue,
            size: 28,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AboutScreen()
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.computer_rounded,
            color: Colors.blue,
            size: 28,
          ),
          onPressed: () async {
            final Uri _url =
                Uri.parse("https://soaportals.com/StudentPortalSOA/#/");
            if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
              throw Exception('Could not launch $_url');
            }
          },
        ),
      ]),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Notice and Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Curriculum',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
