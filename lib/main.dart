import 'package:flutter/material.dart';

void main() {
  runApp(const OmniAgent());
}

class OmniAgent extends StatelessWidget {
  const OmniAgent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniAgent',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OmniAgent Home'),
      ),
      body: const Center(
        child: Text(
          'Welcome to OmniAgent! Stay tuned for AI and Automation!',
        ),
      ),
    );
  }
}