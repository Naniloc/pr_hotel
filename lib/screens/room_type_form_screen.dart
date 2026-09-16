// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/room_type.dart';
import '../repositories/room_type_repository.dart';
import '../core/validators.dart';

class RoomTypeFormScreen extends StatefulWidget {
  final String? id;

  const RoomTypeFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<RoomTypeFormScreen> createState() => _RoomTypeFormScreenState();
}

class _RoomTypeFormScreenState extends State<RoomTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.isEditing) {
      _loadRoomType();
    }
  }

  void _loadRoomType() {
    setState(() => _isLoading = true);

    final repo = context.read<RoomTypeRepository>();
    final roomType = repo.getById(widget.id!);

    if (roomType != null && mounted) {
      setState(() {
        _nameController.text = roomType.name;
        _descriptionController.text = roomType.description;
        _isLoading = false;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Тип номера не найден')));
        context.go('/room-types');
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = context.read<RoomTypeRepository>();

    final roomType = RoomType(
      id: widget.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    try {
      if (widget.isEditing) {
        repo.update(roomType);
      } else {
        repo.create(roomType);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing ? 'Тип номера обновлён' : 'Тип номера создан',
            ),
          ),
        );
        context.go('/room-types');
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
    _nameController.dispose();
    _descriptionController.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Редактирование типа номера' : 'Новый тип номера',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
                helperText: 'Например: Стандарт, Люкс',
              ),
              validator: Validators.combine([
                (v) => Validators.required(v, 'Название'),
                (v) => Validators.minLength(v, 2, 'Название'),
                (v) => Validators.maxLength(v, 50, 'Название'),
              ]),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: Validators.combine([
                (v) => Validators.required(v, 'Описание'),
                (v) => Validators.minLength(v, 10, 'Описание'),
                (v) => Validators.maxLength(v, 200, 'Описание'),
              ]),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/room-types'),
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
