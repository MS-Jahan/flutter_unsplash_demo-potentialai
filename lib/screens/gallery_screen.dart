import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/photo.dart';
import '../services/unsplash_service.dart';
import 'detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    super.key,
    UnsplashService? unsplashService,
  }) : _unsplashService = unsplashService;

  final UnsplashService? _unsplashService;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late final UnsplashService _unsplashService;
  final List<Photo> _photos = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _unsplashService = widget._unsplashService ?? UnsplashService();
    _scrollController.addListener(_scrollListener);
    _loadPhotos();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _unsplashService.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Load more when reaching 80% of the list
    if (currentScroll >= (maxScroll * 0.8) && !_isLoading && _hasMore) {
      _loadPhotos();
    }
  }

  Future<void> _loadPhotos() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final photos = await _unsplashService.getPhotos(
        page: _currentPage,
        perPage: 20,
      );
      
      setState(() {
        if (photos.isEmpty) {
          _hasMore = false;
        } else {
          _photos.addAll(photos);
          _currentPage++;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshList() async {
    setState(() {
      _photos.clear();
      _currentPage = 1;
      _hasMore = true;
      _error = null;
    });
    await _loadPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsplash Gallery'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _error != null && _photos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshList,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshList,
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: _photos.length + (_hasMore ? 2 : 0),
                itemBuilder: (context, index) {
                  if (index >= _photos.length) {
                    return const Card(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final photo = _photos[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: photo.urls['thumb']!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                    rawImageUrl: photo.urls['raw'],
                                    imageUrl: photo.urls['full'],
                                    title: photo.description ?? photo.alt_description ?? 'Photo by ${photo.user.name}',
                                  ),
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
            ),
    );
  }
} 