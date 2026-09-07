import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.pageSizeOptions,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('Показывать по:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: pageSize,
                items: pageSizeOptions
                    .map(
                      (size) =>
                          DropdownMenuItem(value: size, child: Text('$size')),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onPageSizeChanged(value);
                },
              ),
            ],
          ),
          Text('Страница $currentPage из $totalPages (всего $totalItems)'),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
                tooltip: 'Первая страница',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                tooltip: 'Предыдущая',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                tooltip: 'Следующая',
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(totalPages)
                    : null,
                tooltip: 'Последняя страница',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
