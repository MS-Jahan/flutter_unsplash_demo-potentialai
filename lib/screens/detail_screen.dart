import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/gallery_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.imageUrl,
    required this.rawImageUrl,
    required this.title,
  });

  final String? imageUrl;
  final String? rawImageUrl;
  final String title;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with TickerProviderStateMixin {
  final _transformationController = TransformationController();
  bool _isZoomed = false;
  bool _isSaving = false;
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
    GalleryService.dispose();
    super.dispose();
  }

  Future<void> _saveImage() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      await GalleryService.saveImage(
        widget.rawImageUrl ?? widget.imageUrl!,
        'unsplash_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery'),
            backgroundColor: Colors.green,
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
    });
  }

  void _handleInteractionUpdate(ScaleUpdateDetails details) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    setState(() {
      _isZoomed = scale > 1.0;
    });
  }

  void _handleInteractionEnd(ScaleEndDetails details) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    setState(() {
      _isZoomed = scale > 1.0;
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
            title: Text(
              widget.title,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
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
                icon: const Icon(
                  Icons.share,
                  color: Colors.white70,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share feature coming soon'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: GestureDetector(
          onDoubleTapDown: _handleDoubleTapDown,
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            onInteractionUpdate: _handleInteractionUpdate,
            onInteractionEnd: _handleInteractionEnd,
            child: Center(
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}