import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});
  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  List<dynamic> applications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    setState(() => isLoading = true);
    final userId = context.read<AuthProvider>().userId;
    
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final res = await http.get(Uri.parse('http://localhost:3000/api/client/applications/$userId'));
      if (res.statusCode == 200) {
        setState(() {
          applications = jsonDecode(res.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> respondToApplication(String appId, String status) async {
    await http.post(
      Uri.parse('http://localhost:3000/api/worker/offers/$appId/respond'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": status}),
    );
    fetchApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Client Dashboard", style: TextStyle(color: Colors.white)), backgroundColor: primaryNavy, iconTheme: const IconThemeData(color: Colors.white)),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : applications.isEmpty 
          ? const Center(child: Text("No applications from workers yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final app = applications[index];
                final job = app['jobId'];
                final worker = app['workerId'];
                final workerName = worker?['userId']?['name'] ?? 'Unknown Worker';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$workerName applied for:", style: const TextStyle(color: textGray, fontSize: 12)),
                        Text(job?['title'] ?? 'Unknown Job', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryNavy)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status: ${app['status']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (app['status'] == 'pending')
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => respondToApplication(app['_id'], 'rejected'),
                                    child: const Text("Reject", style: TextStyle(color: Colors.red)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    onPressed: () => respondToApplication(app['_id'], 'accepted'),
                                    child: const Text("Accept", style: TextStyle(color: Colors.white)),
                                  )
                                ],
                              )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}