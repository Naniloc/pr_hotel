import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/breakpoints.dart';
import '../models/guest.dart';
import '../repositories/guest_repository.dart';
import '../repositories/pocketbase_guest_repository.dart';
import '../widgets/entity_card.dart';
import '../widgets/entity_table.dart';

class GuestsListScreen extends StatefulWidget {
  const GuestsListScreen({super.key});

  @override
  State<GuestsListScreen> createState() => _GuestsListScreenState();
}

class _GuestsListScreenState extends State<GuestsListScreen> {
  List<Guest> _guests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = context.read<GuestRepository>() as PocketBaseGuestRepository;
      final guests = await repo.getAllAsync();
      if (mounted) {
        setState(() {
          _guests = guests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = layoutSizeOf(context);
    final isMobile = size == LayoutSize.compact;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Гости'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/guests/new'),
            tooltip: 'Добавить гостя',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGuests,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Ошибка: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadGuests,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            )
          : _guests.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Гостей пока нет'),
                ],
              ),
            )
          : isMobile
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _guests.length,
              itemBuilder: (context, index) {
                final guest = _guests[index];
                return EntityCard<Guest>(
                  item: guest,
                  title: (g) => g.name,
                  subtitle: (g) => '${g.email} • ${g.phone}',
                  actions: (g) => [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.go('/guests/${g.id}/edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmation(g.id),
                    ),
                  ],
                );
              },
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: EntityTable<Guest>(
                columns: [
                  TableColumnSpec(label: 'ФИО', build: (g) => Text(g.name)),
                  TableColumnSpec(label: 'Email', build: (g) => Text(g.email)),
                  TableColumnSpec(
                    label: 'Телефон',
                    build: (g) => Text(g.phone),
                  ),
                ],
                items: _guests,
                idOf: (g) => g.id,
                actions: (g) => [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.go('/guests/${g.id}/edit'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmation(g.id),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _showDeleteConfirmation(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить?'),
        content: const Text('Вы уверены?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repo =
            context.read<GuestRepository>() as PocketBaseGuestRepository;
        await repo.deleteAsync(id);
        _loadGuests();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Гость удалён')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка удаления: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
