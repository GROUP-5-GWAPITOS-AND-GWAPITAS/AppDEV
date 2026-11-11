import 'package:flutter/material.dart';
import '../core/theme.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_JobOffer> _pendingJobs = [
    const _JobOffer(
      title: 'Plumbing Repair',
      client: 'John Doe',
      location: 'Cagayan de Oro',
      rate: '\$45/hr',
    ),
    const _JobOffer(
      title: 'Electrical Wiring',
      client: 'Jane Smith',
      location: 'Cagayan de Oro',
      rate: '\$60/hr',
    ),
  ];
  final List<_JobOffer> _acceptedJobs = [];
  final List<_JobOffer> _rejectedJobs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateJobStatus(_JobOffer job, bool accepted) {
    setState(() {
      _pendingJobs.remove(job);
      (accepted ? _acceptedJobs : _rejectedJobs).add(job);
    });
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobList(_pendingJobs, isPending: true),
          _buildJobList(_acceptedJobs, emptyMessage: 'No accepted jobs yet.'),
          _buildJobList(_rejectedJobs, emptyMessage: 'No rejected jobs yet.'),
        ],
      ),
    );
  }

  Widget _buildJobList(
    List<_JobOffer> jobs, {
    bool isPending = false,
    String? emptyMessage,
  }) {
    if (jobs.isEmpty && emptyMessage != null) {
      return Center(child: Text(emptyMessage));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final job in jobs) _buildJobCard(job, showActions: isPending),
      ],
    );
  }

  Widget _buildJobCard(_JobOffer job, {required bool showActions}) {
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
                    job.title,
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
                      const SnackBar(
                        content: Text('Chat feature coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Client: ${job.client}',
                style: const TextStyle(color: textGray)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: textGray),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    style: const TextStyle(color: textGray),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job.rate,
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
                      onPressed: () => _updateJobStatus(job, false),
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
                      onPressed: () => _updateJobStatus(job, true),
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

class _JobOffer {
  const _JobOffer({
    required this.title,
    required this.client,
    required this.location,
    required this.rate,
  });

  final String title;
  final String client;
  final String location;
  final String rate;
}
