import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/breakpoints.dart';
import '../models/floor.dart';
import '../models/room_query.dart';
import '../repositories/floor_repository.dart';
import '../repositories/room_repository.dart';
import '../widgets/entity_card.dart';
import '../widgets/entity_table.dart';

class FloorsListScreen extends StatelessWidget {
  const FloorsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FloorRepository>();
    final roomRepo = context.read<RoomRepository>();
    final floors = repo.getAll();
    final size = layoutSizeOf(context);
    final isMobile = size == LayoutSize.compact;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Этажи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/floors/new'),
            tooltip: 'Добавить этаж',
          ),
        ],
      ),
      body: floors.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Этажей пока нет'),
                ],
              ),
            )
          : isMobile
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: floors.length,
              itemBuilder: (context, index) {
                final floor = floors[index];
                return EntityCard<Floor>(
                  item: floor,
                  title: (f) => 'Этаж ${f.number}',
                  subtitle: (f) => 'Номеров: ${f.roomCount}',
                  actions: (f) => [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.go('/floors/${f.id}/edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmation(
                        context,
                        repo,
                        roomRepo,
                        f.id,
                      ),
                    ),
                  ],
                );
              },
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: EntityTable<Floor>(
                columns: [
                  TableColumnSpec(
                    label: 'Номер',
                    numeric: true,
                    build: (f) => Text('${f.number}'),
                  ),
                  TableColumnSpec(
                    label: 'Количество номеров',
                    numeric: true,
                    build: (f) => Text('${f.roomCount}'),
                  ),
                ],
                items: floors,
                idOf: (f) => f.id,
                actions: (f) => [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.go('/floors/${f.id}/edit'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        _showDeleteConfirmation(context, repo, roomRepo, f.id),
                  ),
                ],
              ),
            ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    FloorRepository repo,
    RoomRepository roomRepo,
    String id,
  ) async {
    final floor = repo.getById(id);
    if (floor == null) return;

    final result = await roomRepo.find(
      const RoomQuery().copyWith(floor: floor.number),
    );
    final roomCount = result.total;

    if (!context.mounted) return;

    if (roomCount > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Невозможно удалить'),
          content: Text(
            'На этом этаже есть $roomCount номер(ов). '
            'Сначала удалите или переместите номера.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
    } else {
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
}
