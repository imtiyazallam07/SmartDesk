import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'curriculum.dart';
import 'about.dart';
import 'Calendar.dart';

// -----------------------------------------------------------------------------
// CONFIGURATION & GLOBALS
// -----------------------------------------------------------------------------

const String taskName = "noticeCheckTask";
const String uniqueTaskName = "unique_notice_check_id";
const String urlToCheck = "https://www.soa.ac.in/iter-news-and-events";
const String channelId = "smartdesk_channel_id";
const String channelName = "SmartDesk Notices";

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// -----------------------------------------------------------------------------
// 1. BACKGROUND WORKER (Must be static/top-level)
// -----------------------------------------------------------------------------
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == taskName) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final int lastKnownCount = prefs.getInt('notice_count') ?? 0;
        final response = await http.get(Uri.parse(urlToCheck));

        if (response.statusCode == 200) {
          var document = parser.parse(response.body);
          var links = document.querySelectorAll('div > h1 > a');
          int currentCount = links.length;
          int difference = currentCount - lastKnownCount;
          if (lastKnownCount != 0) {
            await _showNotification(difference > 0 ? difference : 1);
          }
          await prefs.setInt('notice_count', currentCount);
        } else {
          print("HTTP Error: ${response.statusCode}");
        }
      } catch (e) {
        print("Background Fetch Error: $e");
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}

// -----------------------------------------------------------------------------
// 2. NOTIFICATION HELPER
// -----------------------------------------------------------------------------
Future<void> _showNotification(int newNoticesCount) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: 'Notifications for new academic notices',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'New Notice',
    showWhen: true,
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'SmartDesk Update',
    '$newNoticesCount new notice(s) posted on the portal.',
    platformChannelSpecifics,
  );
}

// -----------------------------------------------------------------------------
// 3. MAIN ENTRY POINT
// -----------------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  await androidImplementation?.requestNotificationsPermission();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  Workmanager().registerPeriodicTask(
    uniqueTaskName,
    taskName,
    frequency: const Duration(hours: 24),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );

  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartDesk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: SmartDesk(),
    );
  }
}


// -----------------------------------------------------------------------------
// 4. HOME SCREEN
// -----------------------------------------------------------------------------
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
    _checkForUpdates();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

// ---------------------------------------------------------------------------
// UPDATE CHECKER LOGIC (Simple Inequality Check)
// ---------------------------------------------------------------------------
  Future<void> _checkForUpdates() async {
    if (!mounted) return;

    try {
      String currentVersion = "1.5.2";
      final response = await http.get(Uri.parse("https://raw.githubusercontent.com/imtiyaz-allam/SmartDesk-backend/refs/heads/main/latest_version.txt"));

      if (response.statusCode == 200) {
        String serverVersion = response.body.trim();
        if (currentVersion != serverVersion) {
          _showVersionMismatchDialog(serverVersion);
        }
      }
    } catch (e) {
      print("Update check failed: $e");
    }
  }

// ---------------------------------------------------------------------------
// DIALOG BOX IMPLEMENTATION
// ---------------------------------------------------------------------------
  void _showVersionMismatchDialog(String serverVersion) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text("Newer Version Available!"),
        content: Text(
            "A newer version ($serverVersion) is available. Would you like to check out the update?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Stay on this version"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUrl("https://github.com/imtiyazallam07/SmartDesk/releases/download/v$serverVersion/SmartDesk-v$serverVersion.apk");
            },
            child: Text("Check Out"),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String fullLink) async {
    final Uri _url = Uri.parse(fullLink);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<List<Widget>> getData() async {
    final url = Uri.parse(urlToCheck);
    List<Widget> data = [];

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        var dateElements = document.querySelectorAll("div > div > span.blog-meta-secondary > time");
        var linkElements = document.querySelectorAll('div > h1 > a');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('notice_count', linkElements.length);

        for (int i = 0; i < linkElements.length; i++) {
          var link = linkElements[i];
          var date = dateElements.length > i ? dateElements[i].text.trim() : "Date N/A";
          String? href = link.attributes['href'];

          if (href != null) {
            data.add(_buildNoticeCard(date, link.text.trim(), href));
          }
        }
      }
    } catch (e) {
      print("Frontend Fetch Error: $e");
    }
    return data;
  }

  Widget _buildNoticeCard(String date, String title, String href) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl("https://www.soa.ac.in$href"),
                icon: Icon(Icons.open_in_new, size: 16),
                label: Text("Read More"),
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      Scaffold(
        body: RefreshIndicator(
          onRefresh: () {
            setState(() {
              _noticeData = getData();
            });
            return _noticeData;
          },
          child: FutureBuilder<List<Widget>>(
            future: _noticeData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text("Error loading notices. Check internet."));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No notices found"));
              }
              return ListView(
                padding: EdgeInsets.only(top: 10),
                children: snapshot.data!,
              );
            },
          ),
        ),
      ),
      Calendar(),
      CurriculumPage(
          jsonUrl: "https://raw.githubusercontent.com/imtiyaz-allam/SmartDesk-backend/refs/heads/main/curriculum.json"
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("SmartDesk", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.computer_outlined, color: Colors.blue[800]),
            onPressed: () async {
              final Uri _url = Uri.parse(
                  "https://soaportals.com/StudentPortalSOA/#/");
              if (!await launchUrl(
                  _url, mode: LaunchMode.externalApplication)) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not open portal")));
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.blue[800]),
            onPressed: () =>
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => AboutScreen())),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.newspaper), label: 'Notices'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(
              icon: Icon(Icons.menu_book), label: 'Curriculum'),
        ],
      ),
    );
  }
}