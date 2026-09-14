// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/guest.dart';
import '../models/guest_card.dart';
import '../repositories/guest_repository.dart';
import '../repositories/guest_card_repository.dart';
import '../core/validators.dart';

class GuestFormScreen extends StatefulWidget {
  final int? id;

  const GuestFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<GuestFormScreen> createState() => _GuestFormScreenState();
}

class _GuestFormScreenState extends State<GuestFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  late final TextEditingController _passportNumberController;
  late final TextEditingController _passportIssuedByController;
  DateTime? _passportIssuedDate;

  bool _hasCard = false;
  int? _cardId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passportNumberController = TextEditingController();
    _passportIssuedByController = TextEditingController();

    if (widget.isEditing) {
      _loadGuest();
    }
  }

  Future<void> _loadGuest() async {
    setState(() => _isLoading = true);

    final guestRepo = context.read<GuestRepository>();
    final cardRepo = context.read<GuestCardRepository>();

    final guest = guestRepo.getById(widget.id!);

    if (guest != null && mounted) {
      _nameController.text = guest.name;
      _emailController.text = guest.email;
      _phoneController.text = guest.phone;

      final card = cardRepo.getByGuestId(guest.id);
      if (card != null) {
        _cardId = card.id;
        _hasCard = true;
        _passportNumberController.text = card.passportNumber;
        _passportIssuedByController.text = card.passportIssuedBy;
        _passportIssuedDate = card.passportIssuedDate;
      }

      setState(() => _isLoading = false);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Гость не найден')));
        context.go('/guests');
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final guestRepo = context.read<GuestRepository>();
    final cardRepo = context.read<GuestCardRepository>();

    final emailUnique = guestRepo.isEmailUnique(
      _emailController.text.trim(),
      excludeId: widget.id,
    );

    if (!emailUnique) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email уже используется другим гостем'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final guest = Guest(
        id: widget.id ?? 0,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final savedGuest = widget.isEditing
          ? guestRepo.update(guest)
          : guestRepo.create(guest);

      if (_hasCard && _passportIssuedDate != null) {
        final card = GuestCard(
          id: _cardId ?? 0,
          guestId: savedGuest.id,
          passportNumber: _passportNumberController.text.trim(),
          passportIssuedBy: _passportIssuedByController.text.trim(),
          passportIssuedDate: _passportIssuedDate!,
        );

        if (_cardId != null) {
          cardRepo.update(card);
        } else {
          cardRepo.create(card);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'Гость обновлён' : 'Гость создан'),
          ),
        );
        context.go('/guests');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _passportIssuedDate ?? DateTime(2020),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _passportIssuedDate = date);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passportNumberController.dispose();
    _passportIssuedByController.dispose();
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
        title: Text(widget.isEditing ? 'Редактирование гостя' : 'Новый гость'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Основная информация',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ФИО',
                border: OutlineInputBorder(),
              ),
              validator: Validators.combine([
                (v) => Validators.required(v, 'ФИО'),
                (v) => Validators.minLength(v, 3, 'ФИО'),
                (v) => Validators.maxLength(v, 100, 'ФИО'),
              ]),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                helperText: 'Должен быть уникальным',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: Validators.combine([
                (v) => Validators.required(v, 'Email'),
                Validators.email,
              ]),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Телефон',
                border: OutlineInputBorder(),
                helperText: '+7 (XXX) XXX-XX-XX',
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.combine([
                (v) => Validators.required(v, 'Телефон'),
                Validators.phone,
              ]),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Паспортные данные',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Switch(
                  value: _hasCard,
                  onChanged: (value) => setState(() => _hasCard = value),
                ),
              ],
            ),
            const Divider(),

            if (_hasCard) ...[
              const SizedBox(height: 16),
              const Text(
                'Введите паспортные данные гостя',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passportNumberController,
                decoration: const InputDecoration(
                  labelText: 'Серия и номер паспорта',
                  border: OutlineInputBorder(),
                  helperText: 'XXXX XXXXXX',
                ),
                validator: _hasCard
                    ? Validators.combine([
                        (v) => Validators.required(v, 'Номер паспорта'),
                        Validators.passportNumber,
                      ])
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passportIssuedByController,
                decoration: const InputDecoration(
                  labelText: 'Кем выдан',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: _hasCard
                    ? (v) => Validators.required(v, 'Орган выдачи')
                    : null,
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Дата выдачи',
                    border: const OutlineInputBorder(),
                    errorText: _hasCard && _passportIssuedDate == null
                        ? 'Выберите дату'
                        : null,
                  ),
                  child: Text(
                    _passportIssuedDate != null
                        ? '${_passportIssuedDate!.day.toString().padLeft(2, '0')}.${_passportIssuedDate!.month.toString().padLeft(2, '0')}.${_passportIssuedDate!.year}'
                        : 'Нажмите для выбора',
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/guests'),
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
