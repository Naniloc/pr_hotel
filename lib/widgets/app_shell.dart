import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/breakpoints.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = layoutSizeOf(context);
    final isMobile = size == LayoutSize.compact;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(title: const Text('Гостиница')),
        drawer: _buildDrawer(context),
        body: child,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Главная'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.door_sliding),
                label: Text('Номера'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                label: Text('Бронирования'),
              ),
            ],
            selectedIndex: _getSelectedIndex(context),
            onDestinationSelected: (index) {
              final routes = ['/', '/rooms', '/bookings'];
              context.go(routes[index]);
            },
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Гостиница',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Главная'),
            onTap: () {
              context.go('/');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.door_sliding),
            title: const Text('Номера'),
            onTap: () {
              context.go('/rooms');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Бронирования'),
            onTap: () {
              context.go('/bookings');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/') return 0;
    if (location.startsWith('/rooms')) return 1;
    if (location.startsWith('/bookings')) return 2;
    return 0;
  }
}
