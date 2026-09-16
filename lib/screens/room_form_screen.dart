import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// ignore_for_file: deprecated_member_use

import '../models/room.dart';
import '../models/floor.dart';
import '../models/room_type.dart';
import '../repositories/room_repository.dart';
import '../repositories/floor_repository.dart';
import '../repositories/room_type_repository.dart';
import '../repositories/pocketbase_floor_repository.dart';
import '../repositories/pocketbase_room_type_repository.dart';
import '../core/validators.dart';
import '../state/room_list_notifier.dart';

class RoomFormScreen extends StatefulWidget {
  final String? id;

  const RoomFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _numberController;
  late final TextEditingController _capacityController;
  late final TextEditingController _priceController;

  String? _floorId;
  String? _roomTypeId;
  bool _isAvailable = true;
  bool _isLoading = false;

  List<Floor> _floors = [];
  List<RoomType> _roomTypes = [];

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController();
    _capacityController = TextEditingController();
    _priceController = TextEditingController();

    _loadFloors();
    _loadRoomTypes();

    if (widget.isEditing) {
      _loadRoom();
    }
  }

  Future<void> _loadFloors() async {
    final repo = context.read<FloorRepository>() as PocketBaseFloorRepository;
    final floors = await repo.getAllAsync();
    if (mounted) {
      setState(() => _floors = floors);
    }
  }

  Future<void> _loadRoomTypes() async {
    final repo =
        context.read<RoomTypeRepository>() as PocketBaseRoomTypeRepository;
    final types = await repo.getAllAsync();
    if (mounted) {
      setState(() => _roomTypes = types);
    }
  }

  Future<void> _loadRoom() async {
    setState(() => _isLoading = true);

    final repo = context.read<RoomRepository>();
    final room = await repo.findById(widget.id!);

    if (room != null && mounted) {
      setState(() {
        _numberController.text = room.number;
        _capacityController.text = room.capacity.toString();
        _priceController.text = room.pricePerNight.toString();
        _floorId = room.floorId;
        _roomTypeId = room.roomTypeId;
        _isAvailable = room.isAvailable;
        _isLoading = false;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Номер не найден')));
        context.go('/rooms');
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = context.read<RoomRepository>();

    final room = Room(
      id: widget.id ?? '',
      number: _numberController.text.trim(),
      floorId: _floorId!,
      roomTypeId: _roomTypeId!,
      capacity: int.parse(_capacityController.text),
      pricePerNight: int.parse(_priceController.text),
      isAvailable: _isAvailable,
    );

    try {
      if (widget.isEditing) {
        await repo.update(room);
      } else {
        await repo.create(room);
      }

      if (mounted) {
        context.read<RoomListNotifier>().load();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'Номер обновлён' : 'Номер создан'),
          ),
        );
        context.go('/rooms');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Загрузка...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final roomRepo = context.read<RoomRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Редактирование номера' : 'Новый номер'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Номер комнаты
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Номер комнаты',
                border: OutlineInputBorder(),
                helperText: 'Например: 101, 205',
              ),
              validator: (value) {
                final basic = Validators.combine([
                  (v) => Validators.required(v, 'Номер'),
                  (v) => Validators.maxLength(v, 10, 'Номер'),
                ])(value);

                if (basic != null) return basic;

                final number = value!.trim();
                if (!roomRepo.isRoomNumberUnique(
                  number,
                  excludeId: widget.id,
                )) {
                  return 'Номер "$number" уже занят';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _floorId,
              decoration: const InputDecoration(
                labelText: 'Этаж',
                border: OutlineInputBorder(),
              ),
              items: _floors
                  .map(
                    (f) => DropdownMenuItem(
                      value: f.id,
                      child: Text('Этаж ${f.number}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _floorId = value),
              validator: (value) => value == null ? 'Выберите этаж' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _roomTypeId,
              decoration: const InputDecoration(
                labelText: 'Тип номера',
                border: OutlineInputBorder(),
              ),
              items: _roomTypes
                  .map(
                    (rt) =>
                        DropdownMenuItem(value: rt.id, child: Text(rt.name)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _roomTypeId = value),
              validator: (value) => value == null ? 'Выберите тип' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Вместимость (человек)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: Validators.combine([
                (v) => Validators.required(v, 'Вместимость'),
                Validators.positiveInt,
                (v) => Validators.range(v, 1, 10, 'Вместимость'),
              ]),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Цена за ночь (₽)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: Validators.combine([
                (v) => Validators.required(v, 'Цена'),
                Validators.positiveInt,
                (v) => Validators.range(v, 100, 100000, 'Цена'),
              ]),
            ),
            const SizedBox(height: 16),

            // Доступность
            SwitchListTile(
              title: const Text('Номер доступен для бронирования'),
              value: _isAvailable,
              onChanged: (value) => setState(() => _isAvailable = value),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/rooms'),
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
