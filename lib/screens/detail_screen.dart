import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/gallery_service.dart';
import '../services/share_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.imageUrl,
    required this.rawImageUrl,
    required this.title,
    required this.authorName,
    required this.dateTime,
    required this.likes, 
    required this.tag,
  });

  final String? imageUrl;
  final String? rawImageUrl;
  final String title;
  final String authorName;
  final String dateTime;
  final int likes;
  final String tag;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with TickerProviderStateMixin {
  final _transformationController = TransformationController();
  bool _isZoomed = false;
  bool _isSaving = false;
  bool _isSharing = false;
  bool _showOverlay = true;
  TapDownDetails? _doubleTapDetails;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    // GalleryService.dispose();
    // Only dispose GalleryService when leaving the screen
    // as it might be needed for sharing
    super.dispose();
  }

  Future<void> _saveImage() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      final (success, message) = await GalleryService.saveImage(
        widget.rawImageUrl ?? widget.imageUrl!,
        'unsplash_${DateTime.now().millisecondsSinceEpoch}',
        onDownloadStarted: (message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? message : 'Failed: $message'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareImage() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    try {
      await ShareService.shareImage(
        widget.rawImageUrl ?? widget.imageUrl!,
        widget.title,
        onDownloadStarted: (message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;

    if (_isZoomed) {
      // If zoomed in, zoom out to initial position with animation
      final animation = Matrix4Tween(
        begin: _transformationController.value,
        end: Matrix4.identity(),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      
      animation.addListener(() {
        _transformationController.value = animation.value;
      });
      
      _animationController
        ..reset()
        ..forward();
    } else {
      // If zoomed out, zoom in on the double-tap position with animation
      final position = _doubleTapDetails!.localPosition;
      final animation = Matrix4Tween(
        begin: _transformationController.value,
        end: Matrix4.identity()
          ..translate(-position.dx * 2, -position.dy * 2)
          ..scale(3.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      
      animation.addListener(() {
        _transformationController.value = animation.value;
      });
      
      _animationController
        ..reset()
        ..forward();
    }
    
    // Update zoom state
    setState(() {
      _isZoomed = !_isZoomed;
      _toggleOverlay();
    });
  }

  void _handleInteractionUpdate(ScaleUpdateDetails details) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    setState(() {
      _isZoomed = scale > 1.0;
      // Show overlay if zoomed in, hide if zoomed out
      _showOverlay = !_isZoomed;
    });
  }

  void _handleInteractionEnd(ScaleEndDetails details) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    setState(() {
      _isZoomed = scale > 1.0;
      // Show overlay if zoomed in, hide if zoomed out
      _showOverlay = !_isZoomed;
    });
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          opacity: _isZoomed ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AppBar(
            backgroundColor: const Color.fromARGB(0, 51, 51, 51),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white70),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.authorName,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  widget.dateTime,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.white70,
                ),
                onPressed: () {
                  // Handle info button press
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Image Info'),
                      content: Text('Title: ${widget.title}\nAuthor: ${widget.authorName}\nDate: ${widget.dateTime}\nLikes: ${widget.likes}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white70,
                        ),
                      )
                    : const Icon(
                        Icons.download,
                        color: Colors.white70,
                      ),
                onPressed: _isSaving ? null : _saveImage,
              ),
              IconButton(
                icon: _isSharing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white70,
                        ),
                      )
                    : const Icon(
                        Icons.share,
                        color: Colors.white70,
                      ),
                onPressed: _isSharing ? null : _shareImage,
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: _handleDoubleTap,
        onTap: _toggleOverlay,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 4.0,
                onInteractionUpdate: _handleInteractionUpdate,
                onInteractionEnd: _handleInteractionEnd,
                child: Center(
                  child: Hero(
                    tag: widget.tag,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl ?? widget.rawImageUrl!,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            FutureBuilder(
                            future: Future.delayed(const Duration(milliseconds: 600)),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox.shrink();
                              } else {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.red[300]),
                                ),
                                ],
                              );
                              }
                            },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Overlay at the bottom of the screen
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showOverlay ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(25.0),
                    color: Colors.black54,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.likes} likes',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}