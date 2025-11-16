import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CurriculumPage extends StatefulWidget {
  final String jsonUrl;

  const CurriculumPage({
    Key? key,
    required this.jsonUrl,
  }) : super(key: key);

  @override
  State<CurriculumPage> createState() => _CurriculumPageState();
}

class _CurriculumPageState extends State<CurriculumPage> {
  Map<String, dynamic>? data;
  bool offline = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final conn = await Connectivity().checkConnectivity();

    if (conn == ConnectivityResult.none) {
      setState(() => offline = true);
      return;
    }

    try {
      final response = await http.get(Uri.parse(widget.jsonUrl));

      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
          offline = false;
        });
      } else {
        setState(() => offline = true);
      }
    } catch (e) {
      setState(() => offline = true);
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

  Widget buildTile(String title, List list) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return ListTile(
                title: Text(
                  item["name"],
                  softWrap: true,
                ),
                trailing: const Icon(Icons.open_in_new, color: Colors.blue),
                onTap: () => _launchURL(item["url"]),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Curriculum"),
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: loadData,

        child: offline
            ? Center(
          child: Image.asset(
            "assets/offline.png",
            width: 180,
          ),
        )
            : data == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            if (data!.containsKey("btech2020"))
              buildTile("B.Tech Admission Batch 2020",
                  data!["btech2020"]),
            if (data!.containsKey("btech2021"))
              buildTile("B.Tech Admission Batch 2021",
                  data!["btech2021"]),
            if (data!.containsKey("btech2022"))
              buildTile("B.Tech Admission Batch 2022",
                  data!["btech2022"]),
            if (data!.containsKey("btech2023"))
              buildTile("B.Tech Admission Batch 2023",
                  data!["btech2023"]),
            if (data!.containsKey("btech2024"))
              buildTile("B.Tech Admission Batch 2024",
                  data!["btech2024"]),
            if (data!.containsKey("mca"))
              buildTile("MCA", data!["mca"]),
          ],
        ),
      ),
    );
  }
}
