import 'package:flutter/material.dart';

class AnotherPage extends StatelessWidget {
  const AnotherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? payload = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(title: const Text("Another Page")),
      body: Center(
        child: Text(payload ?? "No payload received"),
      ),
    );
  }
}