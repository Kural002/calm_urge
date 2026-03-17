import 'package:calm_urge/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/hive_service.dart';
import '../../widgets/bottom_nav.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Set initial streak if not set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hive = Provider.of<HiveService>(context, listen: false);
      if (hive.getStreakStart() == null) {
        hive.setStreakStart(DateTime.now());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_open),
            onPressed: () => Navigator.pushNamed(context, AppRouter.more),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Harm Free Since with live timer
            Consumer<HiveService>(
              builder: (context, hive, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Harm Free Since',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTimeDisplay(hive.getElapsedSinceStart()),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Unlock Premium
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRouter.more),
                child: const Text('Unlock Premium'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Every day',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DailyCard(
                  icon: Icons.track_changes,
                  label: 'Daily Track',
                  onTap: () => _showDailyTrack(context),
                ),
                _DailyCard(
                  icon: Icons.assignment_turned_in,
                  label: 'Daily Pledge',
                  onTap: () => _showPledgeDialog(context),
                ),
                _DailyCard(
                  icon: Icons.message,
                  label: 'Daily Message',
                  onTap: () => _showDailyMessage(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Mini Journal strip
            Consumer<HiveService>(
              builder: (context, hive, child) {
                final entries = hive.journalEntries;
                // Show last 7 days with entry indicators
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (index) {
                      final date = DateTime.now().subtract(
                        Duration(days: 6 - index),
                      );
                      final hasEntry = entries.any(
                        (e) =>
                            e.createdAt.year == date.year &&
                            e.createdAt.month == date.month &&
                            e.createdAt.day == date.day,
                      );
                      return _DayChip(
                        day: DateFormat('E').format(date).substring(0, 3),
                        date: date.day.toString(),
                        hasEntry: hasEntry,
                      );
                    }),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Join community
            ListTile(
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('Join the community'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildTimeDisplay(Duration elapsed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _TimeUnit(value: elapsed.inDays.toString(), unit: 'Days'),
        _TimeUnit(
          value: elapsed.inHours.remainder(24).toString(),
          unit: 'Hours',
        ),
        _TimeUnit(
          value: elapsed.inMinutes.remainder(60).toString(),
          unit: 'Minutes',
        ),
        _TimeUnit(
          value: elapsed.inSeconds.remainder(60).toString(),
          unit: 'Seconds',
        ),
      ],
    );
  }

  void _showDailyMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Daily Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Tuesday, 17 March'),
            SizedBox(height: 8),
            Text(
              'Do not wait to strike till the iron is hot, but make it hot by striking. - William Butler Yeats',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPledgeDialog(BuildContext context) async {
    final hive = Provider.of<HiveService>(context, listen: false);
    final hasPledged = await hive.hasPledgedToday();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('TODAY I WILL NOT HURT MYSELF'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('While I accept myself if I fail,'),
            const Text(
              'TODAY I WILL TRY',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Because I want to feel better'),
            if (hasPledged) const SizedBox(height: 8),
            if (hasPledged)
              const Text(
                'You have already pledged today!',
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: hasPledged
                ? null
                : () async {
                    await hive.markPledgedToday();
                    Navigator.pop(context);
                  },
            child: const Text(
              'PLEDGE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDailyTrack(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.journal);
  }
}

class _TimeUnit extends StatelessWidget {
  final String value;
  final String unit;
  const _TimeUnit({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _DailyCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DailyCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blueGrey[100],
            child: Icon(icon, color: Colors.blueGrey[800]),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String day;
  final String date;
  final bool hasEntry;
  const _DayChip({
    required this.day,
    required this.date,
    required this.hasEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: hasEntry ? Colors.blue : Colors.white,
            shape: BoxShape.circle,
          ),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: hasEntry ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
