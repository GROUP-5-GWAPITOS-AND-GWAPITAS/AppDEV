import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/theme.dart';

class BrowseJobsScreen extends StatefulWidget {
  const BrowseJobsScreen({super.key});
  @override
  State<BrowseJobsScreen> createState() => _BrowseJobsScreenState();
}

class _BrowseJobsScreenState extends State<BrowseJobsScreen> {
  List<dynamic> jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllJobs();
  }

  Future<void> fetchAllJobs() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/worker/all-jobs'));
      if (response.statusCode == 200) {
        setState(() {
          jobs = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Browse Available Jobs", style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : jobs.isEmpty
              ? const Center(child: Text("No jobs available right now."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job['title'] ?? 'Unknown Job', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
                            const SizedBox(height: 8),
                            Text("Client: ${job['clientId']?['name'] ?? 'Unknown'}", style: const TextStyle(color: textGray)),
                            const SizedBox(height: 8),
                            Text("Location: ${job['location'] ?? 'N/A'}", style: const TextStyle(color: textGray)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: (job['requiredSkills'] as List? ?? []).map((skill) => Chip(
                                label: Text(skill, style: const TextStyle(fontSize: 10)),
                                backgroundColor: Colors.blue.shade50,
                              )).toList(),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                                  child: const Text("\$45/hr (Est.)", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryNavy),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Applied! (Feature coming soon)")),
                                    );
                                  },
                                  child: const Text("Apply Now", style: TextStyle(color: Colors.white)),
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