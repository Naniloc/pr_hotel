import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/breakpoints.dart';
import '../core/formatting.dart';
import '../models/booking.dart';
import '../models/booking_query.dart';
import '../state/booking_list_notifier.dart';
import '../widgets/entity_card.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  final _searchController = TextEditingController();
  String? _selectedStatus;
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
        final notifier = context.read<BookingListNotifier>();
        notifier.applyQuery(
          notifier.query.copyWith(search: _searchController.text),
        );
      }
    });
  }

  void _applyFilters() {
    final notifier = context.read<BookingListNotifier>();
    notifier.applyQuery(notifier.query.copyWith(status: _selectedStatus));
  }

  void _clearFilters() {
    _searchController.clear();
    _selectedStatus = null;
    final notifier = context.read<BookingListNotifier>();
    notifier.applyQuery(const BookingQuery());
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookingListNotifier>();
    final size = layoutSizeOf(context);
    final isMobile = size == LayoutSize.compact;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Бронирования'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/bookings/new'),
            tooltip: 'Добавить бронирование',
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
                    hintText: 'Поиск по имени гостя',
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
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedStatus,
                          hint: const Text('Статус'),
                          items:
                              ['pending', 'confirmed', 'completed', 'cancelled']
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(_statusLabel(status)),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedStatus = value),
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
          Expanded(child: _buildContent(notifier, isMobile)),
        ],
      ),
    );
  }

  Widget _buildContent(BookingListNotifier notifier, bool isMobile) {
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
                Text('Бронирования не найдены'),
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
                        final booking = notifier.result.items[index];
                        return EntityCard<Booking>(
                          item: booking,
                          title: (b) => b.guestName,
                          subtitle: (b) =>
                              '${formatShortDate(b.checkIn)} - ${formatShortDate(b.checkOut)} (${b.nights} ночей)',
                          actions: (b) => [
                            InkWell(
                              onTap: () => context.go('/bookings/${b.id}/edit'),
                              child: const Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Редактировать'),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _showDeleteConfirmation(
                                context,
                                notifier,
                                bookingId: b.id,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Удалить',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: EntityTable<Booking>(
                        columns: [
                          TableColumnSpec(
                            label: 'Гость',
                            sortField: 'guestName',
                            build: (b) => Text(b.guestName),
                          ),
                          TableColumnSpec(
                            label: 'Номер',
                            numeric: true,
                            build: (b) => Text('${b.roomId}'),
                          ),
                          TableColumnSpec(
                            label: 'Заезд',
                            sortField: 'checkIn',
                            build: (b) => Text(formatShortDate(b.checkIn)),
                          ),
                          TableColumnSpec(
                            label: 'Выезд',
                            build: (b) => Text(formatShortDate(b.checkOut)),
                          ),
                          TableColumnSpec(
                            label: 'Ночей',
                            sortField: 'nights',
                            numeric: true,
                            build: (b) => Text('${b.nights}'),
                          ),
                          TableColumnSpec(
                            label: 'Статус',
                            build: (b) => Chip(
                              label: Text(_statusLabel(b.status)),
                              backgroundColor: _statusColor(b.status),
                            ),
                          ),
                        ],
                        items: notifier.result.items,
                        idOf: (b) => b.id,
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
                        actions: (b) => [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                context.go('/bookings/${b.id}/edit'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteConfirmation(
                              context,
                              notifier,
                              bookingId: b.id,
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

  String _statusLabel(String status) {
    return switch (status) {
      'pending' => 'Ожидает',
      'confirmed' => 'Подтверждено',
      'completed' => 'Завершено',
      'cancelled' => 'Отменено',
      _ => status,
    };
  }

  Color _statusColor(String status) {
    return switch (status) {
      'pending' => Colors.orange.withValues(alpha: 0.3),
      'confirmed' => Colors.green.withValues(alpha: 0.3),
      'completed' => Colors.blue.withValues(alpha: 0.3),
      'cancelled' => Colors.red.withValues(alpha: 0.3),
      _ => Colors.grey.withValues(alpha: 0.3),
    };
  }

  void _showDeleteConfirmation(
    BuildContext context,
    BookingListNotifier notifier, {
    int? bookingId,
  }) {
    final count = bookingId != null ? 1 : notifier.selected.length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить?'),
        content: Text('Вы уверены? Будет удалено $count бронирование(ий).'),
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
