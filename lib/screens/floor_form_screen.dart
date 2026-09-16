// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/floor.dart';
import '../repositories/floor_repository.dart';
import '../core/validators.dart';

class FloorFormScreen extends StatefulWidget {
  final String? id;

  const FloorFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<FloorFormScreen> createState() => _FloorFormScreenState();
}

class _FloorFormScreenState extends State<FloorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _numberController;
  late final TextEditingController _roomCountController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController();
    _roomCountController = TextEditingController();

    if (widget.isEditing) {
      _loadFloor();
    }
  }

  void _loadFloor() {
    setState(() => _isLoading = true);

    final repo = context.read<FloorRepository>();
    final floor = repo.getById(widget.id!);

    if (floor != null && mounted) {
      setState(() {
        _numberController.text = floor.number.toString();
        _roomCountController.text = floor.roomCount.toString();
        _isLoading = false;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Этаж не найден')));
        context.go('/floors');
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = context.read<FloorRepository>();

    final floor = Floor(
      id: widget.id ?? '', // ← String
      number: int.parse(_numberController.text),
      roomCount: int.parse(_roomCountController.text),
    );

    try {
      if (widget.isEditing) {
        repo.update(floor);
      } else {
        repo.create(floor);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'Этаж обновлён' : 'Этаж создан'),
          ),
        );
        context.go('/floors');
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
    _roomCountController.dispose();
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
        title: Text(widget.isEditing ? 'Редактирование этажа' : 'Новый этаж'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Номер этажа',
                border: OutlineInputBorder(),
                helperText: 'Например: 1, 2, 3',
              ),
              keyboardType: TextInputType.number,
              validator: Validators.combine([
                (v) => Validators.required(v, 'Номер этажа'),
                Validators.positiveInt,
                (v) => Validators.range(v, 1, 100, 'Номер этажа'),
              ]),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _roomCountController,
              decoration: const InputDecoration(
                labelText: 'Количество номеров',
                border: OutlineInputBorder(),
                helperText: 'Сколько номеров на этаже',
              ),
              keyboardType: TextInputType.number,
              validator: Validators.combine([
                (v) => Validators.required(v, 'Количество'),
                Validators.positiveInt,
                (v) => Validators.range(v, 1, 50, 'Количество'),
              ]),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/floors'),
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
