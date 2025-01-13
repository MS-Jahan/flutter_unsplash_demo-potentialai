import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/photo.dart';
import '../services/unsplash_service.dart';
import 'detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> with SingleTickerProviderStateMixin {
  final UnsplashService _unsplashService = UnsplashService();
  final List<Photo> _photos = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  static const int _photosPerPage = 40;
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
    _loadPhotos();
    
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
    _unsplashService.dispose();
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _setupBackgroundUpdateListener() {
    _unsplashService.onPhotosUpdated = (List<Photo> freshPhotos) {
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

  Future<void> _loadPhotos() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final photos = await _unsplashService.getPhotos(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsplash Gallery'),
        actions: [
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
                    onSubmitted: (query) {
                      // Handle search query submission
                    },
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