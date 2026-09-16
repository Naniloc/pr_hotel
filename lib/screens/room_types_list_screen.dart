import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/breakpoints.dart';
import '../models/room_type.dart';
import '../repositories/room_type_repository.dart';
import '../widgets/entity_card.dart';
import '../widgets/entity_table.dart';

class RoomTypesListScreen extends StatelessWidget {
  const RoomTypesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<RoomTypeRepository>();
    final roomTypes = repo.getAll();
    final size = layoutSizeOf(context);
    final isMobile = size == LayoutSize.compact;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Типы номеров'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/room-types/new'),
            tooltip: 'Добавить тип',
          ),
        ],
      ),
      body: roomTypes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Типов номеров пока нет'),
                ],
              ),
            )
          : isMobile
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: roomTypes.length,
              itemBuilder: (context, index) {
                final rt = roomTypes[index];
                return EntityCard<RoomType>(
                  item: rt,
                  title: (r) => r.name,
                  subtitle: (r) => r.description,
                  actions: (r) => [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.go('/room-types/${r.id}/edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          _showDeleteConfirmation(context, repo, r.id),
                    ),
                  ],
                );
              },
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: EntityTable<RoomType>(
                columns: [
                  TableColumnSpec(
                    label: 'Название',
                    build: (rt) => Text(rt.name),
                  ),
                  TableColumnSpec(
                    label: 'Описание',
                    build: (rt) => Text(
                      rt.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                items: roomTypes,
                idOf: (rt) => rt.id,
                actions: (rt) => [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.go('/room-types/${rt.id}/edit'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        _showDeleteConfirmation(context, repo, rt.id),
                  ),
                ],
              ),
            ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    RoomTypeRepository repo,
    String id, // ← String
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
