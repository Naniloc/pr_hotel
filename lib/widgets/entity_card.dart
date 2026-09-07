import 'package:flutter/material.dart';

class EntityCard<T> extends StatelessWidget {
  final T item;
  final String Function(T item) title;
  final String Function(T item) subtitle;
  final List<Widget> Function(T item)? actions;

  const EntityCard({
    super.key,
    required this.item,
    required this.title,
    required this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title(item),
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle(item),
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (actions != null)
                  PopupMenuButton(
                    itemBuilder: (context) => actions!(
                      item,
                    ).map((action) => PopupMenuItem(child: action)).toList(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
