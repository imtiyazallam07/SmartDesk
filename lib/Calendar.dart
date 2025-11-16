import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import 'AcademicCalendarPage.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  // Initialize with a Future that completes immediately with an empty list.
  // This avoids the LateInitializationError on the very first build.
  late Future<List<dynamic>> _holidayFuture = Future.value([]);
  bool offline = false;

  @override
  void initState() {
    super.initState();
    // Start checking internet connectivity immediately.
    // This handles the initial fetch or sets the offline flag.
    _checkInternet(isInitialLoad: true);
  }

  Future<void> _checkInternet({bool isInitialLoad = false}) async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      setState(() {
        offline = true;
        // If initial load and offline, assign a failed Future
        if (isInitialLoad) {
          _holidayFuture = Future.error('Offline');
        }
      });
    } else {
      // If we are online, we proceed to fetch data
      setState(() {
        offline = false;
        // Ensure we only try to fetch if we are online
        _holidayFuture = fetchHolidays();
      });
    }
  }

  Future<List<dynamic>> fetchHolidays() async {
    const url =
        "https://raw.githubusercontent.com/imtiyaz-allam/SmartDesk-backend/refs/heads/main/holidays.json";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Throw an exception so FutureBuilder catches it and displays the error/placeholder.
      throw Exception("Holiday JSON Load Failed: ${response.statusCode}");
    }
  }

  Future<void> _refreshPage() async {
    // When refreshing, check internet and re-fetch if online
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
            // 1. Initial State / Waiting for Future
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator if the Future is truly waiting
              if (!offline && snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }
            }

            // 2. Error State / Offline
            if (snapshot.hasError || offline) {
              // The exception 'Offline' is thrown in initState() if no internet.
              // We also use 'offline' flag as a direct check.
              return _buildOfflinePlaceholder();
            }

            // 3. Success State
            final holidays = snapshot.data!;
            return _buildHolidayTable(holidays);
          },
        ),
      ),
    );
  }

  /// -------------------------------------------------------------
  /// OFFLINE PLACEHOLDER (scrollable so pull-to-refresh still works)
  /// -------------------------------------------------------------
  Widget _buildOfflinePlaceholder() {
    return ListView(
      padding: const EdgeInsets.only(top: 80),
      children: [
        Center(
          child: Column(
            children: [
              // Ensure this asset path is correct:
              // For robustness, you might want to use a standard Icon instead if the image fails.
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

  /// -------------------------------------------------------------
  /// HOLIDAY TABLE VIEW (Rest of the methods remain the same)
  /// -------------------------------------------------------------
  Widget _buildHolidayTable(List<dynamic> holidays) {
    // ... (Your existing _buildHolidayTable implementation)
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
              // HEADER
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

              // ROWS
              ...holidays.map(
                    (holiday) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(holiday["sl"] ?? ""),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(holiday["name"] ?? "",
                          softWrap: true), // word wrap
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

          /// --------------------------
          /// Academic Calendar Buttons
          /// --------------------------
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Academic Calendar",
                  style: TextStyle(fontSize: 24)),
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

  /// Reusable Year Button
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