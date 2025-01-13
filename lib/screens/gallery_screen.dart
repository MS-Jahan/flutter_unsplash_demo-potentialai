import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsplash Gallery'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 1.0,
        ),
        itemCount: 20, // Placeholder count, will be replaced with actual data
        itemBuilder: (context, index) {
          return Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Placeholder for image
                Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
                // Loading indicator overlay
                const Center(
                  child: CircularProgressIndicator(),
                ),
                // Clickable overlay
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // TODO: Navigate to detail screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image detail view coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 