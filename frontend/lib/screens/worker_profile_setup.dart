import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';

class WorkerProfileSetup extends StatefulWidget {
  const WorkerProfileSetup({super.key});
  @override
  State<WorkerProfileSetup> createState() => _WorkerProfileSetupState();
}

class _WorkerProfileSetupState extends State<WorkerProfileSetup> {
  final _roleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  bool isSaving = false;

  Future<void> saveProfile() async {
    setState(() => isSaving = true);
    final workerId = context.read<AuthProvider>().workerProfileId;
    
    // Convert comma-separated string to an array
    final skillsList = _skillsCtrl.text.split(',').map((s) => s.trim()).toList();

    try {
      final res = await http.put(
        Uri.parse('http://localhost:3000/api/worker/profile/$workerId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'roleTitle': _roleCtrl.text,
          'location': _locationCtrl.text,
          'skills': skillsList,
        }),
      );
      
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile saved successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error saving profile: $e");
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Setup Your Profile", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Tell clients what you do so we can match you with jobs!",
              style: TextStyle(fontSize: 16, color: textGray),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _roleCtrl,
              decoration: const InputDecoration(labelText: "Your Title (e.g., Plumber, Electrician)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(labelText: "Your Location (e.g., Cagayan de Oro)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _skillsCtrl,
              decoration: const InputDecoration(labelText: "Skills (Comma separated, e.g., Plumbing, Pipe Fitting)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, foregroundColor: Colors.white),
                onPressed: isSaving ? null : saveProfile,
                child: isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Profile", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}