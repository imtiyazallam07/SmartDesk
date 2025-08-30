import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PortalPage extends StatefulWidget {
  @override
  State<PortalPage> createState() => _PortalPageState();
}

class _PortalPageState extends State<PortalPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;

            // Checking if URL looks like a downloadable file
            if (url.startsWith("blob")) {
              await _downloadAndOpen(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse("https://soaportals.com/StudentPortalSOA/#/"));
  }

  Future<void> _downloadAndOpen(String url) async {
    _controller.addJavaScriptChannel(
      'DownloadChannel',
      onMessageReceived: (JavaScriptMessage message) async {
        final base64Data = message.message;
        final bytes = base64Decode(base64Data);

        final dir = await getApplicationDocumentsDirectory();
        final filePath = "${dir.path}/downloaded.pdf";
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        await OpenFile.open(filePath);
      },
    );
    await _controller.runJavaScript('''
  function downloadBlob(blobUrl) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', blobUrl, true);
    xhr.responseType = 'blob';
    xhr.onload = function() {
      var reader = new FileReader();
      reader.onloadend = function() {
        var base64data = reader.result.split(',')[1];
        DownloadChannel.postMessage(base64data);
      }
      reader.readAsDataURL(xhr.response);
    };
    xhr.send();
  }
''');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}