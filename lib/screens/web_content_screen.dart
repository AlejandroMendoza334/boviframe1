import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebContentScreen extends StatelessWidget {
  final String url;
  const WebContentScreen({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contenido Externo'),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
