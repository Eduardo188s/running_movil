import 'package:flutter/material.dart';

void main() => runApp(const WatchPage());

class WatchPage extends StatelessWidget {
  const WatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material App Bar'),
        ),
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}