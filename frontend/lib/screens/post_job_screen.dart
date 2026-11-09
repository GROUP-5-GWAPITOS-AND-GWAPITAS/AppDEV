import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/theme.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});
  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _skillsController = TextEditingController();

  Future<void> submitJob() async {
    await http.post(
      Uri.parse('http://localhost:3000/api/jobs'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": _titleController.text, 
        "description": _descController.text,
        "requiredSkills": _skillsController.text.split(',').map((s) => s.trim()).toList()
      }),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post a Repair Job"), backgroundColor: primaryNavy, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Job Title")),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: _skillsController, decoration: const InputDecoration(labelText: "Required Skills (Comma separated)")),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, foregroundColor: Colors.white), onPressed: submitJob, child: const Text("Submit Job"))),
          ],
        ),
      ),
    );
  }
}