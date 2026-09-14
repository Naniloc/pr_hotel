import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/breakpoints.dart';
import '../models/guest.dart';
import '../repositories/guest_repository.dart';
import '../widgets/entity_card.dart';
import '../widgets/entity_table.dart';

class GuestsListScreen extends StatelessWidget {
  const GuestsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<GuestRepository>();
    final guests = repo.getAll();
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
        ],
      ),
      body: guests.isEmpty
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
              itemCount: guests.length,
              itemBuilder: (context, index) {
                final guest = guests[index];
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
                      onPressed: () =>
                          _showDeleteConfirmation(context, repo, g.id),
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
                items: guests,
                idOf: (g) => g.id,
                actions: (g) => [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.go('/guests/${g.id}/edit'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        _showDeleteConfirmation(context, repo, g.id),
                  ),
                ],
              ),
            ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    GuestRepository repo,
    int id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить?'),
        content: const Text('Вы уверены?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              repo.delete(id);
              Navigator.pop(context);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
