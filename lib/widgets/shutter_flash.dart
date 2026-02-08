import 'package:flutter/material.dart';

class ShutterFlash extends StatefulWidget {
  final bool visible;
  final VoidCallback? onComplete;

  const ShutterFlash({
    super.key,
    required this.visible,
    this.onComplete,
  });

  @override
  State<ShutterFlash> createState() => _ShutterFlashState();
}

class _ShutterFlashState extends State<ShutterFlash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(ShutterFlash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible && _controller.value == 0) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return IgnorePointer(
          child: Container(
            color: Colors.white.withOpacity(_animation.value),
          ),
        );
      },
    );
  }
}
