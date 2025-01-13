import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/photo.dart';
import '../services/unsplash_service.dart';
import 'detail_screen.dart';
import 'package:intl/intl.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final UnsplashService _unsplashService = UnsplashService();
  final List<Photo> _photos = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  static const int _initialPages = 2;
  static const int _photosPerPage = 20;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _searchInitialPhotos();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading) {
        _loadMorePhotos();
      }
    });
  }

  Future<void> _searchInitialPhotos() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      for (int i = 1; i <= _initialPages; i++) {
        final photos = await _unsplashService.searchPhotos(widget.query, page: i, perPage: _photosPerPage);
        if (mounted) {
          setState(() {
            _photos.addAll(photos);
            _currentPage++;
          });
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchPhotos() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final photos = await _unsplashService.searchPhotos(widget.query, page: _currentPage, perPage: _photosPerPage);
      if (mounted) {
        setState(() {
          _photos.addAll(photos);
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMorePhotos() async {
    await _searchPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results: ${widget.query}'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _photos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError && _photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchPhotos,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _photos.clear();
          _currentPage = 1;
        });
        await _searchPhotos();
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _photos.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _photos.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final photo = _photos[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    imageUrl: photo.urls['regular'],
                    rawImageUrl: photo.urls['raw'],
                    title: photo.description ?? photo.altDescription ?? 'Photo by ${photo.user.name}',
                    authorName: photo.user.name,
                    dateTime: photo.updatedAt != null ? DateFormat('dd MMM, yyyy').format(photo.updatedAt!) : '',
                    likes: photo.likes ?? 0,
                  ),
                ),
              ),
              child: Hero(
                tag: photo.id,
                child: CachedNetworkImage(
                  imageUrl: photo.urls['small']!,
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
              ),
            ),
          );
        },
      ),
    );
  }
}
