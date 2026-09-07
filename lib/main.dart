import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme.dart';
import 'core/scroll_behavior.dart';
import 'repositories/room_repository.dart';
import 'repositories/booking_repository.dart';
import 'state/room_list_notifier.dart';
import 'state/booking_list_notifier.dart';
import 'router.dart';

void main() async {
  await initializeDateFormatting('ru');
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        Provider<RoomRepository>(create: (_) => InMemoryRoomRepository()),
        Provider<BookingRepository>(create: (_) => InMemoryBookingRepository()),
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
