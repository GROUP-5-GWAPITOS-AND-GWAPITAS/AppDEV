import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/theme.dart';

class WorkerProfileScreen extends StatefulWidget {
  final dynamic worker;
  const WorkerProfileScreen({super.key, required this.worker});
  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  bool isShortlisted = false;

  @override
  void initState() {
    super.initState();
    isShortlisted = widget.worker['shortlisted'] ?? false;
  }

  Future<void> toggleShortlist() async {
    await http.post(Uri.parse('http://localhost:3000/api/workers/shortlist'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"workerId": widget.worker['_id']}));
    setState(() { isShortlisted = !isShortlisted; });
  }

  @override
  Widget build(BuildContext context) {
    final worker = widget.worker;
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryNavy, iconTheme: const IconThemeData(color: Colors.white), title: const Text("Worker Profile", style: TextStyle(color: Colors.white))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: primaryNavy, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Icon(Icons.person, size: 60, color: primaryNavy)),
                  const SizedBox(height: 16),
                  Text(worker['userId']['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(worker['roleTitle'], style: const TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 12),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)), child: Text("${worker['match']}% Match", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
                  const SizedBox(height: 8),
                  const Text("Experienced site supervisor with a strong background in safety management and team leadership. Dedicated to delivering projects on time and within budget.", style: TextStyle(color: textGray, height: 1.5)),
                  const SizedBox(height: 24),
                  const Text("Skills", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: (worker['skills'] as List).map((skill) => Chip(label: Text(skill, style: const TextStyle(color: primaryNavy)), backgroundColor: Colors.blue.shade50, side: BorderSide.none)).toList()),
                  const SizedBox(height: 24),
                  Row(children: [const Icon(Icons.location_on, color: textGray), const SizedBox(width: 8), Text(worker['location'], style: const TextStyle(fontSize: 16))]),
                  const SizedBox(height: 12),
                  Row(children: const [Icon(Icons.work_history, color: textGray), SizedBox(width: 8), Text("5+ Years Experience", style: TextStyle(fontSize: 16))]),
                  const SizedBox(height: 40),
                  SizedBox(width: double.infinity, height: 56, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: isShortlisted ? Colors.green : primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: toggleShortlist, child: Text(isShortlisted ? "Shortlisted ✓" : "Shortlist Worker", style: const TextStyle(fontSize: 18, color: Colors.white)))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}