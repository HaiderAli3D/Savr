import 'package:flutter/material.dart';

class ShutterFlash extends StatelessWidget {
  final bool visible;

  const ShutterFlash({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: Container(
        color: Colors.white.withOpacity(0.2),
      ),
    );
  }
}
