import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Добро пожаловать в гостиницу',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: () => context.go('/rooms'),
                icon: const Icon(Icons.door_sliding),
                label: const Text('Номера'),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go('/bookings'),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Бронирования'),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go('/guests'),
                icon: const Icon(Icons.people),
                label: const Text('Гости'),
              ),

              const SizedBox(height: 32),

              Text(
                'Справочники',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.go('/floors'),
                icon: const Icon(Icons.layers),
                label: const Text('Этажи'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => context.go('/room-types'),
                icon: const Icon(Icons.category),
                label: const Text('Типы номеров'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
