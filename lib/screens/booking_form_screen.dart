// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/booking.dart';
import '../models/room.dart';
import '../models/guest.dart';
import '../models/room_query.dart';
import '../repositories/booking_repository.dart';
import '../repositories/room_repository.dart';
import '../repositories/guest_repository.dart';
import '../repositories/pocketbase_guest_repository.dart';
import '../core/formatting.dart';
import '../state/booking_list_notifier.dart';

class BookingFormScreen extends StatefulWidget {
  final String? id;

  const BookingFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _roomId;
  String? _guestId;
  DateTime? _checkIn;
  DateTime? _checkOut;
  String _status = 'confirmed';

  bool _isLoading = false;
  List<Room> _rooms = [];
  List<Guest> _guests = [];

  @override
  void initState() {
    super.initState();

    _loadData();

    if (widget.isEditing) {
      _loadBooking();
    } else {
      _checkIn = DateTime.now().add(const Duration(days: 1));
      _checkOut = DateTime.now().add(const Duration(days: 2));
    }
  }

  Future<void> _loadData() async {
    final roomRepo = context.read<RoomRepository>();
    final guestRepo =
        context.read<GuestRepository>() as PocketBaseGuestRepository;

    try {
      final roomsResult = await roomRepo.find(const RoomQuery(size: 200));
      final guests = await guestRepo.getAllAsync();

      if (mounted) {
        setState(() {
          _rooms = roomsResult.items;
          _guests = guests;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки данных: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadBooking() async {
    setState(() => _isLoading = true);

    try {
      final repo = context.read<BookingRepository>();
      final booking = await repo.findById(widget.id!);

      if (booking != null && mounted) {
        setState(() {
          _roomId = booking.roomId;
          _guestId = booking.guestId;
          _checkIn = booking.checkIn;
          _checkOut = booking.checkOut;
          _status = booking.status;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Бронирование не найдено')),
          );
          context.go('/bookings');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/bookings');
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите даты заезда и выезда'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_checkIn!.isAfter(_checkOut!) ||
        _checkIn!.isAtSameMomentAs(_checkOut!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дата выезда должна быть позже даты заезда'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final repo = context.read<BookingRepository>();
      final guestRepo =
          context.read<GuestRepository>() as PocketBaseGuestRepository;

      final guest = await guestRepo.getByIdAsync(_guestId!);
      if (guest == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Гость не найден'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final booking = Booking(
        id: widget.id ?? '',
        roomId: _roomId!,
        guestId: _guestId!,
        guestName: guest.name,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        status: _status,
      );

      if (widget.isEditing) {
        await repo.update(booking);
      } else {
        await repo.create(booking);
      }

      if (mounted) {
        context.read<BookingListNotifier>().load();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Бронирование обновлено'
                  : 'Бронирование создано',
            ),
          ),
        );
        context.go('/bookings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectDate(bool isCheckIn) async {
    final initialDate = isCheckIn
        ? (_checkIn ?? DateTime.now().add(const Duration(days: 1)))
        : (_checkOut ?? DateTime.now().add(const Duration(days: 2)));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = date;
          if (_checkOut != null && _checkOut!.isBefore(date)) {
            _checkOut = date.add(const Duration(days: 1));
          }
        } else {
          _checkOut = date;
        }
      });
    }
  }

  int get _nights {
    if (_checkIn == null || _checkOut == null) return 0;
    return _checkOut!.difference(_checkIn!).inDays;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Загрузка...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Редактирование бронирования'
              : 'Новое бронирование',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _roomId,
              decoration: const InputDecoration(
                labelText: 'Номер',
                border: OutlineInputBorder(),
              ),
              items: _rooms
                  .map(
                    (r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(
                        'Номер ${r.number} (${formatMoney(r.pricePerNight)}/ночь)',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _roomId = value),
              validator: (value) => value == null ? 'Выберите номер' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _guestId,
              decoration: const InputDecoration(
                labelText: 'Гость',
                border: OutlineInputBorder(),
              ),
              items: _guests
                  .map(
                    (g) => DropdownMenuItem(
                      value: g.id,
                      child: Text('${g.name} (${g.email})'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _guestId = value),
              validator: (value) => value == null ? 'Выберите гостя' : null,
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => _selectDate(true),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Дата заезда',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: _checkIn != null ? formatShortDate(_checkIn!) : '',
                  ),
                  validator: (value) =>
                      _checkIn == null ? 'Выберите дату заезда' : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => _selectDate(false),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Дата выезда',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: _checkOut != null ? formatShortDate(_checkOut!) : '',
                  ),
                  validator: (value) =>
                      _checkOut == null ? 'Выберите дату выезда' : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_nights > 0)
              Card(
                color: Colors.blue.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Количество ночей:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '$_nights',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Статус',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Ожидает')),
                DropdownMenuItem(
                  value: 'confirmed',
                  child: Text('Подтверждено'),
                ),
                DropdownMenuItem(value: 'completed', child: Text('Завершено')),
                DropdownMenuItem(value: 'cancelled', child: Text('Отменено')),
              ],
              onChanged: (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/bookings'),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(widget.isEditing ? 'Сохранить' : 'Создать'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
