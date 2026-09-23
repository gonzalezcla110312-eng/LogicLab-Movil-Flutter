import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const LogicLabApp());
}

class LogicLabApp extends StatelessWidget {
  const LogicLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LogicLab',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const LogicLabWebView(),
    );
  }
}

class LogicLabWebView extends StatefulWidget {
  const LogicLabWebView({super.key});

  @override
  State<LogicLabWebView> createState() => _LogicLabWebViewState();
}

class _LogicLabWebViewState extends State<LogicLabWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('http://192.168.80.25:5173/'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}