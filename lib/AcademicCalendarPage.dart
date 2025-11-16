import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class AcademicCalendarPage extends StatefulWidget {
  final String title;
  final String url;

  const AcademicCalendarPage({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  _AcademicCalendarPageState createState() => _AcademicCalendarPageState();
}

class _AcademicCalendarPageState extends State<AcademicCalendarPage> {
  // FIX: Initialize the late field to an empty/completed Future.
  late Future<List<dynamic>> _calendarFuture = Future.value([]);
  bool offline = false;

  @override
  void initState() {
    super.initState();
    // Pass a flag to indicate this is the initial load.
    _checkConnection(isInitialLoad: true);
  }

  Future<void> _checkConnection({bool isInitialLoad = false}) async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      setState(() {
        offline = true;
        // If it's the initial load and we're offline, assign a failing Future
        // so the FutureBuilder knows to jump to snapshot.hasError.
        if (isInitialLoad) {
          _calendarFuture = Future.error('Offline');
        }
      });
    } else {
      setState(() {
        offline = false;
        _calendarFuture = fetchCalendarData();
      });
    }
  }

  Future<void> _refreshPage() async {
    // Just call _checkConnection; it will re-fetch if online.
    await _checkConnection();
  }

  Future<List<dynamic>> fetchCalendarData() async {
    final response = await http.get(Uri.parse(widget.url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load academic calendar");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: FutureBuilder<List<dynamic>>(
          future: _calendarFuture,
          builder: (context, snapshot) {
            // Check for explicit offline state first, or if Future failed (due to network error or 'Offline' error)
            if (offline || snapshot.hasError) {
              return _buildOfflinePlaceholder();
            }

            // Show loading only when a true fetch is happening and no data is present
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Data successfully loaded
            return _buildCalendarTable(snapshot.data!);
          },
        ),
      ),
    );
  }

  /// ----------------------------------------
  /// Offline Placeholder (scrollable for refresh)
  /// ----------------------------------------
  Widget _buildOfflinePlaceholder() {
    return ListView(
      padding: const EdgeInsets.only(top: 60),
      children: [
        Column(
          children: [
            // Ensure this asset exists in your pubspec.yaml and assets folder
            Image.asset("assets/offline.png", width: 180),
            const SizedBox(height: 20),
            const Text(
              "No Internet Connection",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              "Pull down to retry",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  /// ----------------------------------------
  /// Tabulated View (Word Wrap + Scroll)
  /// ----------------------------------------
  Widget _buildCalendarTable(List<dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade400, width: 1),
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(2.5),
          },
          children: [
            // TABLE HEADER
            TableRow(
              decoration: BoxDecoration(color: Colors.blue.shade50),
              children: const [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Date",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Event",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),

            // TABLE DATA ROWS
            for (var item in data)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      item["day"] ?? "",
                      softWrap: true,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      item["event"] ?? "",
                      softWrap: true, // 🔥 WORD WRAP ENABLED
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}