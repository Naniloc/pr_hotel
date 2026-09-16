import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final String Function(T item) idOf; // ← String
  final Set<String> selected; // ← Set<String>
  final ValueChanged<String>? onToggleSelect; // ← String
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          if (onToggleSelect != null)
            DataColumn(
              label: Checkbox(
                value: selected.length == items.length && items.isNotEmpty,
                onChanged: (value) {
                  if (value == true) {
                    for (final item in items) {
                      onToggleSelect!(idOf(item));
                    }
                  } else {
                    for (final item in items) {
                      if (selected.contains(idOf(item))) {
                        onToggleSelect!(idOf(item));
                      }
                    }
                  }
                },
              ),
            ),
          ...columns.map((col) {
            final isActive = sortField == col.sortField;
            return DataColumn(
              label: GestureDetector(
                onTap: col.sortField != null
                    ? () => onSort?.call(col.sortField!)
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(col.label),
                    if (isActive && col.sortField != null)
                      Icon(
                        sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
              numeric: col.numeric,
            );
          }),
          if (actions != null) const DataColumn(label: Text('Действия')),
        ],
        rows: items.map((item) {
          final id = idOf(item);
          return DataRow(
            cells: [
              if (onToggleSelect != null)
                DataCell(
                  Checkbox(
                    value: selected.contains(id),
                    onChanged: (_) => onToggleSelect!(id),
                  ),
                ),
              ...columns.map((col) => DataCell(col.build(item))),
              if (actions != null)
                DataCell(
                  Row(mainAxisSize: MainAxisSize.min, children: actions!(item)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
