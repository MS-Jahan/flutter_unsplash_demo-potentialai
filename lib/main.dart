import 'package:flutter/material.dart';

void main() {
  runApp(const UnsplashGalleryApp());
}

class UnsplashGalleryApp extends StatelessWidget {
  const UnsplashGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unsplash Gallery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Gallery App'),
        ),
      ),
    );
  }
}
