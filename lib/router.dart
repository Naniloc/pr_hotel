import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/rooms_list_screen.dart';
import 'screens/bookings_list_screen.dart';
import 'screens/room_form_screen.dart';
import 'screens/guests_list_screen.dart';
import 'screens/guest_form_screen.dart';
import 'widgets/app_shell.dart';
import 'screens/floor_form_screen.dart';
import 'screens/floors_list_screen.dart';
import 'screens/room_type_form_screen.dart';
import 'screens/room_types_list_screen.dart';
import 'screens/booking_form_screen.dart';

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
          path: '/rooms/new',
          builder: (context, state) => const RoomFormScreen(),
        ),
        GoRoute(
          path: '/rooms/:id/edit',
          builder: (context, state) {
            final id = state.pathParameters['id']; // ← String?
            return RoomFormScreen(id: id);
          },
        ),

        GoRoute(
          path: '/bookings',
          builder: (context, state) => const BookingsListScreen(),
        ),
        GoRoute(
          path: '/bookings/new',
          builder: (context, state) => const BookingFormScreen(),
        ),
        GoRoute(
          path: '/bookings/:id/edit',
          builder: (context, state) {
            final id = state.pathParameters['id']; // ← String?
            return BookingFormScreen(id: id);
          },
        ),

        GoRoute(
          path: '/guests',
          builder: (context, state) => const GuestsListScreen(),
        ),
        GoRoute(
          path: '/guests/new',
          builder: (context, state) => const GuestFormScreen(),
        ),
        GoRoute(
          path: '/guests/:id/edit',
          builder: (context, state) {
            final id = state.pathParameters['id']; // ← String?
            return GuestFormScreen(id: id);
          },
        ),
        GoRoute(
          path: '/floors',
          builder: (context, state) => const FloorsListScreen(),
        ),
        GoRoute(
          path: '/floors/new',
          builder: (context, state) => const FloorFormScreen(),
        ),
        GoRoute(
          path: '/floors/:id/edit',
          builder: (context, state) {
            final id = state.pathParameters['id']; // ← String?
            return FloorFormScreen(id: id);
          },
        ),

        GoRoute(
          path: '/room-types',
          builder: (context, state) => const RoomTypesListScreen(),
        ),
        GoRoute(
          path: '/room-types/new',
          builder: (context, state) => const RoomTypeFormScreen(),
        ),
        GoRoute(
          path: '/room-types/:id/edit',
          builder: (context, state) {
            final id = state.pathParameters['id']; // ← String?
            return RoomTypeFormScreen(id: id);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Ошибка')),
    body: Center(child: Text('404: ${state.uri}')),
  ),
);
