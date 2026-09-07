import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/rooms_list_screen.dart';
import 'screens/bookings_list_screen.dart';
import 'widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/rooms',
          builder: (context, state) => const RoomsListScreen(),
        ),
        GoRoute(
          path: '/bookings',
          builder: (context, state) => const BookingsListScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Ошибка')),
    body: Center(child: Text('404: ${state.uri}')),
  ),
);
