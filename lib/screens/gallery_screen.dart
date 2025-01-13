import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsplash Gallery'),
      ),
      body: const Center(
        child: Text('Gallery will be implemented here'),
      ),
    );
  }
} 