import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'core/scroll_behavior.dart';
import 'repositories/room_repository.dart';
import 'repositories/booking_repository.dart';
import 'repositories/floor_repository.dart';
import 'repositories/room_type_repository.dart';
import 'repositories/guest_repository.dart';
import 'repositories/guest_card_repository.dart';
import 'state/room_list_notifier.dart';
import 'state/booking_list_notifier.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ru');
  usePathUrlStrategy();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<RoomRepository>(create: (_) => InMemoryRoomRepository(prefs)),
        Provider<BookingRepository>(
          create: (_) => InMemoryBookingRepository(prefs),
        ),
        Provider<FloorRepository>(
          create: (_) => InMemoryFloorRepository(prefs),
        ),
        Provider<RoomTypeRepository>(
          create: (_) => InMemoryRoomTypeRepository(prefs),
        ),
        Provider<GuestRepository>(
          create: (_) => InMemoryGuestRepository(prefs),
        ),
        Provider<GuestCardRepository>(
          create: (_) => InMemoryGuestCardRepository(prefs),
        ),

        Provider<SharedPreferences>.value(value: prefs),

        ChangeNotifierProvider(
          create: (context) =>
              RoomListNotifier(context.read<RoomRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              BookingListNotifier(context.read<BookingRepository>())..load(),
        ),
      ],
      child: const HotelApp(),
    ),
  );
}

class HotelApp extends StatelessWidget {
  const HotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Гостиница',
      debugShowCheckedModeBanner: false,
      theme: buildDarkTheme(),
      routerConfig: appRouter,
      scrollBehavior: const AppScrollBehavior(),
    );
  }
}
