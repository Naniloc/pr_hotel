import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/breakpoints.dart';
import '../core/formatting.dart';
import '../models/room.dart';
import '../models/room_type.dart';
import '../models/room_query.dart';
import '../repositories/room_type_repository.dart';
import '../state/room_list_notifier.dart';
import '../widgets/entity_card.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';

class RoomsListScreen extends StatefulWidget {
  const RoomsListScreen({super.key});

  @override
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  final _searchController = TextEditingController();
  int? _selectedType;
  int? _selectedFloor;
  int? _minPrice;
  int? _maxPrice;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        final notifier = context.read<RoomListNotifier>();
        notifier.applyQuery(
          notifier.query.copyWith(search: _searchController.text),
        );
      }
    });
  }

  void _applyFilters() {
    final notifier = context.read<RoomListNotifier>();
    notifier.applyQuery(
      notifier.query.copyWith(
        roomTypeId: _selectedType,
        floor: _selectedFloor,
        priceMin: _minPrice,
        priceMax: _maxPrice,
      ),
    );
  }

  void _clearFilters() {
    _searchController.clear();
    _selectedType = null;
    _selectedFloor = null;
    _minPrice = null;
    _maxPrice = null;
    final notifier = context.read<RoomListNotifier>();
    notifier.applyQuery(const RoomQuery());
  }

  List<RoomType> _getRoomTypes(BuildContext context) {
    return context.read<RoomTypeRepository>().getAll();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<RoomListNotifier>();
    final roomTypes = _getRoomTypes(context);
    final size = layoutSizeOf(context);
    final isMobile = size == LayoutSize.compact;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Номера'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/rooms/new'),
            tooltip: 'Добавить номер',
          ),
          if (notifier.hasSelection)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Chip(
                  label: Text('Выбрано: ${notifier.selected.length}'),
                ),
              ),
            ),
          if (notifier.hasSelection)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context, notifier),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск по номеру',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _searchController.clear,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedType,
                          hint: const Text('Тип'),
                          items: roomTypes
                              .map(
                                (rt) => DropdownMenuItem(
                                  value: rt.id,
                                  child: Text(rt.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedType = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedFloor,
                          hint: const Text('Этаж'),
                          items: [1, 2, 3, 4]
                              .map(
                                (floor) => DropdownMenuItem(
                                  value: floor,
                                  child: Text('$floor'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedFloor = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Применить'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear),
                        label: const Text('Сброс'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildContent(notifier, roomTypes, isMobile)),
        ],
      ),
    );
  }

  Widget _buildContent(
    RoomListNotifier notifier,
    List<RoomType> roomTypes,
    bool isMobile,
  ) {
    switch (notifier.status) {
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case LoadStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(notifier.error ?? 'Произошла ошибка'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.load(),
                child: const Text('Повторить'),
              ),
            ],
          ),
        );

      case LoadStatus.success:
        if (notifier.result.items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('Номера не найдены'),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: isMobile
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifier.result.items.length,
                      itemBuilder: (context, index) {
                        final room = notifier.result.items[index];
                        final roomType = roomTypes
                            .firstWhere(
                              (rt) => rt.id == room.roomTypeId,
                              orElse: () => const RoomType(
                                id: 0,
                                name: 'Неизвестно',
                                description: '',
                              ),
                            )
                            .name;
                        return EntityCard<Room>(
                          item: room,
                          title: (r) => 'Номер ${r.number}',
                          subtitle: (r) =>
                              '$roomType • Этаж ${r.floorId} • ${r.capacity} мест • ${formatMoney(r.pricePerNight)}',
                          actions: (r) => [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  context.go('/rooms/${r.id}/edit'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteConfirmation(
                                context,
                                notifier,
                                roomId: r.id,
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: EntityTable<Room>(
                        columns: [
                          TableColumnSpec(
                            label: 'Номер',
                            sortField: 'number',
                            build: (r) => Text(r.number),
                          ),
                          TableColumnSpec(
                            label: 'Тип',
                            build: (r) {
                              final roomType = roomTypes
                                  .firstWhere(
                                    (rt) => rt.id == r.roomTypeId,
                                    orElse: () => const RoomType(
                                      id: 0,
                                      name: 'Неизвестно',
                                      description: '',
                                    ),
                                  )
                                  .name;
                              return Text(roomType);
                            },
                          ),
                          TableColumnSpec(
                            label: 'Этаж',
                            sortField: 'floor',
                            numeric: true,
                            build: (r) => Text('${r.floorId}'),
                          ),
                          TableColumnSpec(
                            label: 'Мест',
                            sortField: 'capacity',
                            numeric: true,
                            build: (r) => Text('${r.capacity}'),
                          ),
                          TableColumnSpec(
                            label: 'Цена',
                            sortField: 'price',
                            numeric: true,
                            build: (r) => Text(formatMoney(r.pricePerNight)),
                          ),
                          TableColumnSpec(
                            label: 'Статус',
                            build: (r) => Chip(
                              label: Text(r.isAvailable ? 'Свободен' : 'Занят'),
                              backgroundColor: r.isAvailable
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                        items: notifier.result.items,
                        idOf: (r) => r.id,
                        selected: notifier.selected,
                        onToggleSelect: (id) => notifier.toggleSelection(id),
                        sortField: notifier.query.sortField,
                        sortAscending: notifier.query.sortAscending,
                        onSort: (field) => notifier.applyQuery(
                          notifier.query.copyWith(
                            sortField: field,
                            sortAscending: field == notifier.query.sortField
                                ? !notifier.query.sortAscending
                                : true,
                          ),
                        ),
                        actions: (r) => [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => context.go('/rooms/${r.id}/edit'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteConfirmation(
                              context,
                              notifier,
                              roomId: r.id,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            PaginationBar(
              currentPage: notifier.result.page,
              totalPages: notifier.result.totalPages,
              totalItems: notifier.result.total,
              pageSize: notifier.query.size,
              pageSizeOptions: const [10, 25, 50],
              onPageChanged: (page) =>
                  notifier.applyQuery(notifier.query.copyWith(page: page)),
              onPageSizeChanged: (size) =>
                  notifier.applyQuery(notifier.query.copyWith(size: size)),
            ),
          ],
        );

      case LoadStatus.idle:
        return const SizedBox.shrink();
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    RoomListNotifier notifier, {
    int? roomId,
  }) {
    final count = roomId != null ? 1 : notifier.selected.length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить?'),
        content: Text('Вы уверены? Будет удалено $count номер(ов).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              notifier.deleteSelected();
              Navigator.pop(context);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
