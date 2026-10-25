import 'package:flutter/material.dart';

class MatchViewScreen extends StatelessWidget {
  const MatchViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matched Workers')),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              title: const Text('Juan (Aircon Tech)'),
              subtitle: const Text('Rate: ₱500 - ₱800'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text('Book'),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Pedro (Plumber)'),
              subtitle: const Text('Rate: ₱300 - ₱500'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text('Book'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
