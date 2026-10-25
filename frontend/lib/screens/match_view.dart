import 'package:flutter/material.dart';

class MatchViewScreen extends StatelessWidget {
  const MatchViewScreen({super.key});

  static const _workers = [
    _Worker(
      name: 'Juan',
      skill: 'Aircon Technician',
      rateRange: '₱500 - ₱800',
    ),
    _Worker(
      name: 'Pedro',
      skill: 'Plumber',
      rateRange: '₱300 - ₱500',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matched Workers')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _workers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final worker = _workers[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    worker.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Skill: ${worker.skill}'),
                  Text('Rate Range: ${worker.rateRange}'),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Worker {
  const _Worker({
    required this.name,
    required this.skill,
    required this.rateRange,
  });

  final String name;
  final String skill;
  final String rateRange;
}
