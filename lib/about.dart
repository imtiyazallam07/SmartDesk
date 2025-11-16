import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _open(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      print("Error launching: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Colors.black87;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About',
          style: TextStyle(color: textColor),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            /// -------------------- App Info --------------------
            const SizedBox(height: 8),
            Image.asset('assets/logo.png', width: 70, height: 70),
            const SizedBox(height: 12),
            const Text(
              "SmartDesk",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              "1.0.0 (20251114)",
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),

            /// -------------------- Developer Info --------------------
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: const NetworkImage(
                "https://avatars.githubusercontent.com/u/95128488?v=4",
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Developed and designed by",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              "Imtiyaz Allam",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _icon(FontAwesomeIcons.instagram,
                    "https://instagram.com/sudo_imtiyaz.sh", textColor),
                _icon(FontAwesomeIcons.linkedinIn,
                    "https://www.linkedin.com/in/imtiyaz-allam-68b106252/",
                    textColor),
                _icon(FontAwesomeIcons.github,
                    "https://github.com/imtiyazallam07", textColor),
                _icon(Icons.mail_outline,
                    "mailto:imtiyazallam07@outlook.com", textColor),
              ],
            ),

            const SizedBox(height: 32),

            /// -------------------- Support Section --------------------
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                "SUPPORT",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            _tile(
              "Changelog",
              textColor,
                  () => _open(
                  "https://github.com/imtiyazallam07/SmartDesk/releases"),
            ),
            _tile(
              "Provide feedback",
              textColor,
                  () => _open("mailto:imtiyazallam07@outlook.com"),
            ),
            _tile(
              "Open source licences",
              textColor,
                  () => showLicensePage(context: context),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Small inline helpers (allowed since not separate widgets)

  Widget _icon(IconData icon, String link, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () => _open(link),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _tile(String title, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          title,
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      ),
    );
  }
}
