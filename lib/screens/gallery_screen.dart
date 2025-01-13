import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/photo.dart';
import '../services/unsplash_service.dart';
import 'detail_screen.dart';
import 'search_results_screen.dart';
import '../screens/settings_screen.dart';
import 'dart:developer' as dev;

extension ObjectExt<T> on T? {
  R? let<R>(R Function(T) block) => this != null ? block(this!) : null;
}

class GalleryScreen extends StatefulWidget {
  final UnsplashService unsplashService;

  const GalleryScreen({super.key, required this.unsplashService});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> with SingleTickerProviderStateMixin {
  final List<Photo> _photos = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  static const int _initialPages = 1;
  static const int _photosPerPage = 20;
  bool _isSearchBarVisible = false;
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFieldNotEmpty = false;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _setupBackgroundUpdateListener();
    _loadInitialPhotos();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _searchController.addListener(() {
      setState(() {
        _isSearchFieldNotEmpty = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.unsplashService.dispose();
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _setupBackgroundUpdateListener() {
    widget.unsplashService.onPhotosUpdated = (List<Photo> freshPhotos) {
      if (mounted) {
        setState(() {
          // Replace the first page of photos with fresh data
          _photos.removeRange(0, min(_photosPerPage, _photos.length));
          _photos.insertAll(0, freshPhotos);
        });
      }
    };
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

  Future<void> _loadInitialPhotos() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      for (int i = 1; i <= _initialPages; i++) {
        final photos = await widget.unsplashService.getPhotos(page: i, perPage: _photosPerPage);
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

  Future<void> _loadPhotos() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final photos = await widget.unsplashService.getPhotos(
        page: _currentPage,
        perPage: _photosPerPage,
      );
      
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
    await _loadPhotos();
  }

  Future<void> _refreshPhotos() async {
    setState(() {
      _photos.clear();
      _currentPage = 1;
    });
    await _loadPhotos();
  }

  void _toggleSearchBar() {
    if (_isSearchBarVisible) {
      _animationController.reverse().then((_) {
        setState(() {
          _isSearchBarVisible = false;
          _searchFocusNode.unfocus();
        });
      });
    } else {
      setState(() {
        _isSearchBarVisible = true;
      });
      _animationController.forward().then((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  void _handleSearch(String query) {
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(query: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsplash Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearchBar,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPhotos,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_isSearchBarVisible)
            SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(8.0),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'People, Objects, Places...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearchFieldNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    ),
                    onSubmitted: _handleSearch,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_hasError && _photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show an error icon so the test can find it
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshPhotos,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshPhotos,
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
          final uniqueTag = '${photo.id}_$index'; // Create a unique tag
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
                    imageUrl: photo.urls['regular'] ?? '',
                    rawImageUrl: photo.urls['raw'] ?? '',
                    title: photo.description
                      ?? photo.altDescription
                      ?? 'Photo by ${photo.user?.name ?? 'Unknown'}',
                    authorName: photo.user?.name ?? 'Unknown',
                    dateTime: photo.updatedAt?.let((date) => DateFormat('dd MMM, yyyy').format(date)) ?? '',
                    likes: photo.likes ?? 0,
                    tag: uniqueTag, // Pass the unique tag to the DetailScreen
                  ),
                ),
              ),
              child: Hero(
                tag: uniqueTag,
                child: CachedNetworkImage(
                  imageUrl: photo.urls['small'] ?? '',
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
          );        },      ),
    );
  }

}