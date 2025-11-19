import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AcademicCalendarPage.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late Future<List<dynamic>> _holidayFuture = Future.value([]);
  bool offline = false;

  static const String cacheKey = "holiday_cache_v1";

  @override
  void initState() {
    super.initState();
    _checkInternet(isInitialLoad: true);
  }

  Future<void> _checkInternet({bool isInitialLoad = false}) async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      setState(() {
        offline = true;

        if (isInitialLoad) {
          _holidayFuture = _loadFromCacheOrError();
        }
      });
    } else {
      setState(() {
        offline = false;
        _holidayFuture = fetchHolidays();
      });
    }
  }

  /// ----------------------------------------------------------
  /// Loading from cache
  /// ----------------------------------------------------------
  Future<List<dynamic>> _loadFromCacheOrError() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(cacheKey)) {
      final cachedJson = prefs.getString(cacheKey)!;
      return jsonDecode(cachedJson);
    } else {
      return Future.error("Offline");
    }
  }

  /// ----------------------------------------------------------
  /// Fetch + Cache Logic
  /// ----------------------------------------------------------
  Future<List<dynamic>> fetchHolidays() async {
    const url =
        "https://raw.githubusercontent.com/imtiyaz-allam/SmartDesk-backend/refs/heads/main/holidays.json";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(cacheKey, response.body); // Save to cache

        return jsonDecode(response.body);
      } else {
        return _loadFromCacheOrError();
      }
    } catch (_) {
      // If network fails, load from cache
      return _loadFromCacheOrError();
    }
  }

  Future<void> _refreshPage() async {
    await _checkInternet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SOA Holidays List 2025"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: FutureBuilder<List<dynamic>>(
          future: _holidayFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !offline &&
                snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || offline) {
              return _buildOfflinePlaceholder();
            }

            final holidays = snapshot.data!;
            return _buildHolidayTable(holidays);
          },
        ),
      ),
    );
  }

  Widget _buildOfflinePlaceholder() {
    return ListView(
      padding: const EdgeInsets.only(top: 80),
      children: [
        Center(
          child: Column(
            children: [
              Image.asset("assets/offline.png", width: 180),
              const SizedBox(height: 16),
              const Text("No Internet Connection",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text("Pull down to reload",
                  style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHolidayTable(List<dynamic> holidays) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Table(
            border: TableBorder.all(color: Colors.grey.shade400),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade300),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Sl. No",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Name of Festive Days",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Date",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Day",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              ...holidays.map(
                    (holiday) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(holiday["sl"] ?? ""),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(holiday["name"] ?? "", softWrap: true),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(holiday["date"] ?? ""),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(holiday["day"] ?? ""),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Academic Calendar", style: TextStyle(fontSize: 24)),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Select Your Year:"),
            ),
          ),

          Row(
            children: [
              _buildYearButton("1st",
                  "https://raw.githubusercontent.com/imtiyaz-allam/SmartDesk-backend/refs/heads/main/AcademicCalendar1.json"),
              _buildYearButton("2nd",
                  "https://raw.githubusercontent.com/imtiyaz-allam/SmartDesk-backend/refs/heads/main/AcademicCalendar2.json"),
              _buildYearButton("3rd",
                  "https://raw.githubusercontent.com/imtiyaz-allam/SmartDesk-backend/refs/heads/main/AcademicCalendar3.json"),
              _buildYearButton("4th",
                  "https://raw.githubusercontent.com/imtiyaz-allam/SmartDesk-backend/refs/heads/main/AcademicCalendar4.json"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearButton(String text, String url) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AcademicCalendarPage(
                  title: "Academic Calendar for $text year",
                  url: url,
                ),
              ),
            );
          },
          child: Text(text),
        ),
      ),
    );
  }
}
