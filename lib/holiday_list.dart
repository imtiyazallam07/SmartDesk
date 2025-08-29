import 'package:flutter/material.dart';

class HolidayTable extends StatelessWidget {
  final List<Map<String, String>> holidays = [
    {"sl": "1", "name": "Maha Shivaratri", "date": "26.02.2025", "day": "Wednesday"},
    {"sl": "2", "name": "Holi", "date": "15.03.2025", "day": "Saturday"},
    {"sl": "3", "name": "Id-ul-Zuha", "date": "07.06.2025", "day": "Saturday"},
    {"sl": "4", "name": "Rath Yatra", "date": "27.06.2025", "day": "Friday"},
    {"sl": "5", "name": "Independence Day/Janmastami", "date": "15.08.2025", "day": "Friday"},
    {"sl": "6", "name": "Ganesh Puja", "date": "27.08.2025", "day": "Wednesday"},
    {"sl": "7", "name": "Maha Ashtami", "date": "30.09.2025", "day": "Tuesday"},
    {"sl": "8", "name": "Maha Navami", "date": "01.10.2025", "day": "Wednesday"},
    {"sl": "9", "name": "Gandhi Jayanti/Dussehra", "date": "02.10.2025", "day": "Thursday"},
    {"sl": "10", "name": "Diwali (Deepawali)", "date": "21.10.2025", "day": "Tuesday"},
    {"sl": "11", "name": "Kartika Purnima", "date": "05.11.2025", "day": "Wednesday"},
    {"sl": "12", "name": "X-Mass Day", "date": "25.12.2025", "day": "Thursday"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SOA Holidays List 2025")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // ✅ Only vertical scrolling
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade400),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              // Table Header
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade300),
                children: const [
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Sl. No",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Name of Festive days",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Date",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Day",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              // Table Rows
              ...holidays.map(
                    (holiday) => TableRow(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(holiday["sl"]!)),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(holiday["name"]!)),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(holiday["date"]!)),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(holiday["day"]!)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}