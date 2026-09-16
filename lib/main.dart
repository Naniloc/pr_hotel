import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dio/dio.dart';

import 'core/theme.dart';
import 'core/scroll_behavior.dart';
import 'core/api_client.dart';
import 'repositories/room_repository.dart';
import 'repositories/booking_repository.dart';
import 'repositories/floor_repository.dart';
import 'repositories/room_type_repository.dart';
import 'repositories/guest_repository.dart';
import 'repositories/guest_card_repository.dart';
import 'repositories/pocketbase_room_repository.dart';
import 'repositories/pocketbase_room_type_repository.dart';
import 'repositories/pocketbase_floor_repository.dart';
import 'repositories/pocketbase_guest_repository.dart';
import 'repositories/pocketbase_guest_card_repository.dart';
import 'repositories/pocketbase_booking_repository.dart';
import 'state/room_list_notifier.dart';
import 'state/booking_list_notifier.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ru');
  usePathUrlStrategy();

  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>(create: (_) => buildDio()),

        ProxyProvider<Dio, RoomRepository>(
          update: (_, dio, _) => PocketBaseRoomRepository(dio),
        ),

        ProxyProvider<Dio, RoomTypeRepository>(
          update: (_, dio, _) => PocketBaseRoomTypeRepository(dio),
        ),

        ProxyProvider<Dio, FloorRepository>(
          update: (_, dio, _) => PocketBaseFloorRepository(dio),
        ),

        ProxyProvider<Dio, GuestRepository>(
          update: (_, dio, _) => PocketBaseGuestRepository(dio),
        ),

        ProxyProvider<Dio, GuestCardRepository>(
          update: (_, dio, _) => PocketBaseGuestCardRepository(dio),
        ),

        ProxyProvider<Dio, BookingRepository>(
          update: (_, dio, _) => PocketBaseBookingRepository(dio),
        ),

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
