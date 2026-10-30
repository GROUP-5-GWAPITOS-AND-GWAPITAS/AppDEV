import 'package:flutter/material.dart';

import 'screens/match_view.dart';
import 'widgets/bottom_nav_bar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppDEV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A4B8F),
          primary: const Color(0xFF0A4B8F),
        ),
      ),
      home: AppShell(),
      routes: {
        '/home': (_) => const AppShell(),
        '/match': (_) => const AppShell(initialIndex: 1),
        '/jobs': (_) => const AppShell(initialIndex: 1),
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          MatchViewScreen(),
          PlaceholderScreen(title: 'Messages'),
          PlaceholderScreen(title: 'Profile'),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _selectTab,
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: Text('$title screen'),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFFDDE9F5),
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=160&q=80',
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, color: Color(0xFF0A4B8F)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, John',
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF123A67)),
                      ),
                      SizedBox(height: 3),
                      Text('Get your home projects done.',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF728096))),
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12)
                        ],
                      ),
                      child: const Icon(Icons.notifications_none_rounded,
                          color: Color(0xFF163D6A)),
                    ),
                    Positioned(
                      right: 8,
                      top: 9,
                      child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Color(0xFFE95D4F),
                              shape: BoxShape.circle)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for services...',
                hintStyle: const TextStyle(color: Color(0xFF9AA7B7)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8FA0B2)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF084C90), Color(0xFF083C73)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                        color: Color(0xFFEE892B), shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Post a repair job',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800)),
                        SizedBox(height: 5),
                        Text(
                            'Describe your issue and get matched\nwith trusted pros.',
                            style: TextStyle(
                                color: Color(0xFFCFE1F4),
                                fontSize: 12,
                                height: 1.35)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _HomeActionTile(
              icon: Icons.groups_rounded,
              title: 'Browse local pros',
              subtitle: 'Find skilled workers near you.',
            ),
            const SizedBox(height: 24),
            const _SectionHeading(title: 'Categories'),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Category(
                    icon: Icons.plumbing,
                    label: 'Plumbing',
                    color: Color(0xFF0A72B9)),
                _Category(
                    icon: Icons.bolt_rounded,
                    label: 'Electrical',
                    color: Color(0xFFF2A93B)),
                _Category(
                    icon: Icons.handyman_rounded,
                    label: 'Carpentry',
                    color: Color(0xFFA76743)),
                _Category(
                    icon: Icons.cleaning_services_rounded,
                    label: 'Cleaning',
                    color: Color(0xFF43A77A)),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionHeading(title: 'Open Jobs'),
            const SizedBox(height: 12),
            const _OpenJobCard(),
          ],
        ),
      ),
    );
  }
}

class _HomeActionTile extends StatelessWidget {
  const _HomeActionTile(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
                color: Color(0xFFE6F0F7), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF0A4B8F))),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF173A60))),
          const SizedBox(height: 3),
          Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF728096))),
        ])),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFF8DA0B5)),
      ]),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF123A67))),
      const Text('See all  >',
          style: TextStyle(fontSize: 12, color: Color(0xFF687C92))),
    ]);
  }
}

class _Category extends StatelessWidget {
  const _Category(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(children: [
        Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30)),
        const SizedBox(height: 8),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF173A60))),
      ]),
    );
  }
}

class _OpenJobCard extends StatelessWidget {
  const _OpenJobCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
                color: Color(0xFFE5F1FA), shape: BoxShape.circle),
            child: const Icon(Icons.plumbing, color: Color(0xFF0A4B8F))),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Plumbing Repair',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF173A60))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0F7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Finding pros...',
              style: TextStyle(fontSize: 11, color: Color(0xFF477CA8)),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
              "We're matching your job with\n the best local professionals.",
              style: TextStyle(fontSize: 11, color: Color(0xFF728096))),
        ])),
        OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE66A4B),
                side: const BorderSide(color: Color(0xFFE66A4B)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Cancel')),
      ]),
    );
  }
}
