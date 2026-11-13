import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
<<<<<<< HEAD
import 'worker_profile_setup.dart';
import 'browse_jobs_screen.dart'; // ADDED IMPORT
=======
>>>>>>> 442337e284513d10fd81b7622f5f6d52596e3e26

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  
  List<dynamic> offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchOffers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchOffers() async {
    setState(() => isLoading = true);
    final workerId = context.read<AuthProvider>().workerProfileId;
    
    if (workerId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/worker/offers/$workerId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          offers = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching offers: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> respondToOffer(String offerId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/worker/offers/$offerId/respond'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": status}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Offer $status!")),
        );
<<<<<<< HEAD
        fetchOffers(); 
=======
        fetchOffers(); // Refresh the list
>>>>>>> 442337e284513d10fd81b7622f5f6d52596e3e26
      }
    } catch (e) {
      print("Error responding to offer: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryNavy,
        title: const Text(
          'Worker Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkerProfileSetup()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => context.read<AuthProvider>().logout(),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentOrange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
<<<<<<< HEAD
      // --- NEW FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentOrange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BrowseJobsScreen()),
          );
        },
        icon: const Icon(Icons.search, color: Colors.white),
        label: const Text("Browse Jobs", style: TextStyle(color: Colors.white)),
      ),
      // ----------------------------------
=======
>>>>>>> 442337e284513d10fd81b7622f5f6d52596e3e26
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
          controller: _tabController,
          children: [
            _buildJobList('pending'),
            _buildJobList('accepted'),
            _buildJobList('rejected'),
          ],
        ),
    );
  }

  Widget _buildJobList(String statusFilter) {
    final filteredOffers = offers.where((offer) => offer['status'] == statusFilter).toList();

    if (filteredOffers.isEmpty) {
      return Center(child: Text("No $statusFilter jobs yet.", style: const TextStyle(color: textGray)));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final offer in filteredOffers) _buildJobCard(offer, showActions: statusFilter == 'pending'),
      ],
    );
  }

  Widget _buildJobCard(dynamic offer, {required bool showActions}) {
    final job = offer['jobId'];
    final client = offer['clientId'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job['title'] ?? 'Unknown Job',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryNavy,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.message, color: primaryNavy),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chat feature coming soon!')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Client: ${client['name'] ?? 'Unknown'}', style: const TextStyle(color: textGray)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: textGray),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job['location'] ?? 'Unknown Location',
                    style: const TextStyle(color: textGray),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
<<<<<<< HEAD
                    '\$45/hr',
=======
                    '\$45/hr', // Hardcoded rate for now
>>>>>>> 442337e284513d10fd81b7622f5f6d52596e3e26
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () => respondToOffer(offer['_id'], 'rejected'),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => respondToOffer(offer['_id'], 'accepted'),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}