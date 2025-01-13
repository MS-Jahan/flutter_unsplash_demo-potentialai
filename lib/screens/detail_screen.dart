import 'package:flutter/material.dart';
import '../services/gallery_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    this.imageUrl,
    this.rawImageUrl,
    this.title = '',
  });

  final String? imageUrl;
  final String? rawImageUrl;
  final String title;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with TickerProviderStateMixin {
  bool _isZoomed = false;
  bool _isSaving = false;
  final TransformationController _transformationController = TransformationController();
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
    if (widget.imageUrl == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final (success, message) = await GalleryService.saveImage(
        widget.rawImageUrl!,
        'unsplash_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
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

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final isZoomed = scale > 1.0;
    if (_isZoomed != isZoomed) {
      setState(() => _isZoomed = isZoomed);
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale <= 1.0 && _isZoomed) {
      setState(() => _isZoomed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _isZoomed ? null : AppBar(
        title: Text(widget.title.isNotEmpty ? widget.title : 'Photo Detail'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: _isSaving 
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.download),
            onPressed: _isSaving ? null : _saveImage,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share coming soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              onInteractionUpdate: _onInteractionUpdate,
              onInteractionEnd: _onInteractionEnd,
              child: Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: widget.imageUrl != null
                  ? Image.network(
                      widget.imageUrl!,
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 60,
                            ),
                            SizedBox(height: 16),
                            Text('Failed to load image'),
                          ],
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
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