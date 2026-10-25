import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Post a Job")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(decoration: InputDecoration(labelText: "Job Title")),
              TextField(decoration: InputDecoration(labelText: "Location")),
              TextField(decoration: InputDecoration(labelText: "Description")),
              SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: Text("Post Job"))
            ],
          ),
        ),
      ),
    );
  }
}
