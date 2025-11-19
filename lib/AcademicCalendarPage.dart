import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcademicCalendarPage extends StatefulWidget {
  final String title;
  final String url;

  const AcademicCalendarPage({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  State<AcademicCalendarPage> createState() => _AcademicCalendarPageState();
}

class _AcademicCalendarPageState extends State<AcademicCalendarPage> {
  late Future<List<dynamic>> _calendarFuture = Future.value([]);

  bool offline = false;

  /// UNIQUE cache key per year → very important
  late final String cacheKey;

  @override
  void initState() {
    super.initState();

    // Create unique cache key per URL (safe for each academic year)
    cacheKey = "academic_calendar_${widget.url.hashCode}";

    _checkConnection(isInitialLoad: true);
  }

  // -------------------------------------------------------------
  // LOAD FROM CACHE
  // -------------------------------------------------------------
  Future<List<dynamic>?> loadCachedCalendar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(cacheKey);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  // -------------------------------------------------------------
  // SAVE TO CACHE
  // -------------------------------------------------------------
  Future<void> saveCachedCalendar(List<dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, jsonEncode(data));
  }

  // -------------------------------------------------------------
  // CHECK INTERNET
  // -------------------------------------------------------------
  Future<void> _checkConnection({bool isInitialLoad = false}) async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      // --- OFFLINE ---
      setState(() {
        offline = true;
        if (isInitialLoad) {
          _calendarFuture = loadCachedCalendar().then((cached) {
            if (cached != null) return cached;
            throw Exception("Offline. No cached data.");
          });
        }
      });

    } else {
      // --- ONLINE ---
      setState(() {
        offline = false;
        _calendarFuture = fetchCalendarData();
      });
    }
  }

  // -------------------------------------------------------------
  // REFRESH / PULL TO REFRESH
  // -------------------------------------------------------------
  Future<void> _refreshPage() async {
    await _checkConnection();
  }

  // -------------------------------------------------------------
  // FETCH + CACHE + OFFLINE FALLBACK
  // -------------------------------------------------------------
  Future<List<dynamic>> fetchCalendarData() async {
    try {
      final response = await http.get(Uri.parse(widget.url));

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);
        await saveCachedCalendar(jsonList);   // Cache it
        return jsonList;
      } else {
        throw Exception();
      }
    } catch (e) {
      // On error → load cached version
      final cached = await loadCachedCalendar();
      if (cached != null) return cached;

      throw Exception("Failed to load data & no cache available");
    }
  }

  // -------------------------------------------------------------
  // BUILD UI
  // -------------------------------------------------------------
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
            if (offline && snapshot.hasError) {
              return _buildOfflinePlaceholder();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildOfflinePlaceholder();
            }

            return _buildCalendarTable(snapshot.data!);
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // OFFLINE PLACEHOLDER
  // -------------------------------------------------------------
  Widget _buildOfflinePlaceholder() {
    return ListView(
      padding: const EdgeInsets.only(top: 60),
      children: [
        Column(
          children: [
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

  // -------------------------------------------------------------
  // TABLE UI
  // -------------------------------------------------------------
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
                      softWrap: true,
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
