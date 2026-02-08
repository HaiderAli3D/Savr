import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../nav.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.last.matchedLocation;
    
    final tabs = [
      _NavTab(
        route: AppRoutes.home,
        icon: Icons.qr_code_scanner,
        label: 'Scan',
        isActive: currentRoute == AppRoutes.home,
      ),
      _NavTab(
        route: AppRoutes.history,
        icon: Icons.history,
        label: 'History',
        isActive: currentRoute == AppRoutes.history,
      ),
      _NavTab(
        route: AppRoutes.settings,
        icon: Icons.person,
        label: 'Profile',
        isActive: currentRoute == AppRoutes.settings,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 60,
            maxHeight: 70,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.map((tab) => _buildNavItem(context, tab)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, _NavTab tab) {
    return GestureDetector(
      onTap: () => context.go(tab.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active indicator - made much smaller
            Container(
              width: tab.isActive ? 12 : 0,
              height: 1.5,
              decoration: BoxDecoration(
                color: tab.isActive ? Theme.of(context).primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            
            // Icon
            Icon(
              tab.icon,
              size: 14,
              color: tab.isActive 
                ? Theme.of(context).primaryColor
                : Theme.of(context).unselectedWidgetColor,
            ),
            
            // Label - using FittedBox to ensure it fits
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w500,
                    color: tab.isActive 
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).unselectedWidgetColor,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab {
  final String route;
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavTab({
    required this.route,
    required this.icon,
    required this.label,
    required this.isActive,
  });
}