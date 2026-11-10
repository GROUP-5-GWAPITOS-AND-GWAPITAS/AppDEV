import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import 'post_job_screen.dart';
import 'match_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    setState(() => isLoading = true);
    final response = await http.get(Uri.parse('http://localhost:3000/api/jobs')); 
    if (response.statusCode == 200) {
      setState(() { jobs = jsonDecode(response.body); isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(backgroundColor: primaryNavy, child: Icon(Icons.person, color: Colors.white)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Welcome back", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Get your home projects done.", style: TextStyle(color: textGray, fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.logout, color: textGray), onPressed: () => context.read<AuthProvider>().logout())
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(decoration: InputDecoration(hintText: "Search for services...", prefixIcon: const Icon(Icons.search, color: textGray), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PostJobScreen()));
                        if (result == true) fetchJobs(); 
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: primaryNavy, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundColor: accentOrange, child: const Icon(Icons.add, color: Colors.white)),
                            const SizedBox(width: 16),
                            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Post a repair job", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text("Describe your issue and get matched", style: TextStyle(color: Colors.white70, fontSize: 12))])),
                            const Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.people, color: primaryNavy)),
                          const SizedBox(width: 16),
                          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Browse local pros", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text("Find skilled workers near you.", style: TextStyle(color: textGray, fontSize: 12))])),
                          const Icon(Icons.chevron_right, color: textGray),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategoryIcon(Icons.water_damage, "Plumbing", Colors.blue),
                        _buildCategoryIcon(Icons.electric_bolt, "Electrical", Colors.orange),
                        _buildCategoryIcon(Icons.handyman, "Carpentry", Colors.brown),
                        _buildCategoryIcon(Icons.cleaning_services, "Cleaning", Colors.green),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text("Open Jobs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("See all", style: TextStyle(color: primaryNavy))]),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MatchScreen(jobId: job['_id']))),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              children: [
                                CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.water_damage, color: primaryNavy)),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(job['title'], style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Text(job['status'], style: const TextStyle(color: primaryNavy, fontSize: 10)))])),
                                const Icon(Icons.chevron_right, color: textGray),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, Color color) {
    return Column(children: [CircleAvatar(radius: 30, backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))]);
  }
}