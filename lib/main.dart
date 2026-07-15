import 'package:flutter/material.dart';

void main() {
  runApp(const NowBarApp());
}

class NowBarApp extends StatelessWidget {
  const NowBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NowBar',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const NowBarHome(),
    );
  }
}

class NowBarHome extends StatelessWidget {
  const NowBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 700,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xff181818),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              '🎵 NowBar',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}