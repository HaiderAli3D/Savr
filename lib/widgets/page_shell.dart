import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/animated_bottom_nav.dart';

class PageShell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? headerLeft;
  final bool showBottomNav;

  const PageShell({
    super.key,
    required this.title,
    required this.child,
    this.headerLeft,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Fixed header
            if (title.isNotEmpty || headerLeft != null)
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      if (headerLeft != null) ...[
                        headerLeft!,
                        const SizedBox(width: 12),
                      ],
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                    ],
                  ),
                ),
              ),

            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: 1.0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 350),
                    offset: Offset.zero,
                    curve: Curves.easeOut,
                    child: child,
                  ),
                ),
              ),
            ),

            // Bottom navigation
            if (showBottomNav) const AnimatedBottomNav(),
          ],
        ),
      ),
    );
  }
}
