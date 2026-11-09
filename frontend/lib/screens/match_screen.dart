import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/theme.dart';
import 'worker_profile_screen.dart';

class MatchScreen extends StatefulWidget {
  final String? jobId;
  const MatchScreen({super.key, this.jobId});
  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  List<dynamic> workers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkers();
  }

  Future<void> fetchWorkers() async {
    setState(() => isLoading = true);
    String url = 'http://localhost:3000/api/workers';
    if (widget.jobId != null) url += '?jobId=${widget.jobId}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() { workers = jsonDecode(response.body); isLoading = false; });
    }
  }

  Future<void> shortlistWorker(String workerId) async {
    await http.post(Uri.parse('http://localhost:3000/api/workers/shortlist'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"workerId": workerId}));
    fetchWorkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        if (widget.jobId != null) IconButton(icon: const Icon(Icons.arrow_back, size: 28), onPressed: () => Navigator.pop(context)) else const SizedBox(width: 48),
                        const SizedBox(width: 8),
                        RichText(text: const TextSpan(style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryNavy), children: [TextSpan(text: "WORK "), TextSpan(text: "| ", style: TextStyle(color: accentOrange)), TextSpan(text: "MATCH")])),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: primaryNavy, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.work, color: primaryNavy)),
                        const SizedBox(height: 16),
                        const Text("Site Construction Supervisor", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)), child: const Text("\$45/hr", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))), const SizedBox(width: 12), const Icon(Icons.location_on, color: Colors.white70, size: 16), const SizedBox(width: 4), const Text("Cagayan de Oro", style: TextStyle(color: Colors.white70, fontSize: 12))]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: workers.length,
                      itemBuilder: (context, index) {
                        final worker = workers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(radius: 30, backgroundColor: textGray, child: Icon(Icons.person, color: Colors.white)),
                                  const SizedBox(width: 16),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(worker['userId']['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(worker['roleTitle'], style: const TextStyle(color: textGray, fontSize: 12)), const SizedBox(height: 4), Row(children: const [Icon(Icons.star, color: Colors.amber, size: 16), Icon(Icons.star, color: Colors.amber, size: 16), Icon(Icons.star, color: Colors.amber, size: 16), Icon(Icons.star, color: Colors.amber, size: 16), Icon(Icons.star_half, color: Colors.amber, size: 16), SizedBox(width: 4), Text("4.9 (124 reviews)", style: TextStyle(color: textGray, fontSize: 10))])])),
                                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.green, width: 2)), child: Column(mainAxisSize: MainAxisSize.min, children: [Text("${worker['match']}%", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)), const Text("Match", style: TextStyle(color: textGray, fontSize: 10))])),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(spacing: 8, runSpacing: 8, children: (worker['skills'] as List).map((skill) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(skill, style: const TextStyle(color: Colors.green, fontSize: 10)), const SizedBox(width: 4), const Icon(Icons.check_circle, color: Colors.green, size: 12)]))).toList()),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: primaryNavy), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerProfileScreen(worker: worker))), child: const Text("View Profile", style: TextStyle(color: primaryNavy)))),
                                  const SizedBox(width: 12),
                                  Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: worker['shortlisted'] ? Colors.green : primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => shortlistWorker(worker['_id']), child: Text(worker['shortlisted'] ? "Shortlisted" : "Shortlist", style: const TextStyle(color: Colors.white)))),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}