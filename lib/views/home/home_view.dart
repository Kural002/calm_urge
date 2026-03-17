import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/hive_service.dart';
import '../../widgets/bottom_nav.dart';
import '../../core/theme/app_theme.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_open, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pushNamed(context, '/more'),
          ),
        ],
      ),
      body: Consumer<HiveService>(
        builder: (context, hive, child) {
          final elapsed = hive.getElapsedSinceStart();
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(elapsed),
                const SizedBox(height: 24),
                _buildPremiumCard(),
                const SizedBox(height: 24),
                _buildDailySection(context, hive),
                const SizedBox(height: 24),
                _buildWeekStrip(hive),
                const SizedBox(height: 24),
                _buildCommunityCard(),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeader(Duration elapsed) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Harm Free Since',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              // Fix: Wrap row with LayoutBuilder and use Expanded to prevent overflow
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: _buildTimeUnit(elapsed.inDays, 'Days')),
                      Expanded(
                        child: _buildTimeUnit(
                          elapsed.inHours.remainder(24),
                          'Hours',
                        ),
                      ),
                      Expanded(
                        child: _buildTimeUnit(
                          elapsed.inMinutes.remainder(60),
                          'Mins',
                        ),
                      ),
                      Expanded(
                        child: _buildTimeUnit(
                          elapsed.inSeconds.remainder(60),
                          'Secs',
                        ),
                      ),
                    ],
                  );
                },
              ),
              // const SizedBox(height: 20),
              // Center(
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 8,
              //     ),
              //     decoration: BoxDecoration(
              //       color: Colors.white.withOpacity(0.2),
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //     child: const Text(
              //       'Keep going, you’re doing great!',
              //       style: TextStyle(color: Colors.white),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toString().padLeft(2, '0'),
              key: ValueKey(value),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildPremiumCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unlock Premium',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get insights, themes & more',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailySection(BuildContext context, HiveService hive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Practices',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Fix: Use Row with mainAxisAlignment and flexible children
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _DailyCard(
                  icon: Icons.track_changes,
                  label: 'Track',
                  color: AppTheme.primaryColor,
                  onTap: () => _showDailyTrack(context),
                ),
              ),
              Expanded(
                child: _DailyCard(
                  icon: Icons.assignment_turned_in,
                  label: 'Pledge',
                  color: AppTheme.secondaryColor,
                  onTap: () => _showPledgeDialog(context, hive),
                ),
              ),
              Expanded(
                child: _DailyCard(
                  icon: Icons.message,
                  label: 'Message',
                  color: AppTheme.accentColor,
                  onTap: () => _showDailyMessage(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip(HiveService hive) {
    final entries = hive.journalEntries;
    final today = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Fix: Use horizontal ListView for scrollable week strip
          Container(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = today.subtract(Duration(days: 6 - index));
                final hasEntry = entries.any(
                  (e) =>
                      e.createdAt.year == date.year &&
                      e.createdAt.month == date.month &&
                      e.createdAt.day == date.day,
                );
                return Container(
                  width: 50, // fixed width for each day chip
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: _DayChip(
                    day: DateFormat.E().format(date)[0],
                    date: date.day.toString(),
                    hasEntry: hasEntry,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          leading: CircleAvatar(
            backgroundColor: AppTheme.secondaryColor,
            child: const Icon(Icons.people, color: Colors.white),
          ),
          title: const Text('Join the Community'),
          subtitle: const Text('Connect with others'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'NEW',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  void _showDailyMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_stories,
                size: 60,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Daily Message',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('EEEE, d MMMM').format(DateTime.now()),
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              const Text(
                '"Do not wait to strike till the iron is hot, but make it hot by striking."',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              const Text('- William Butler Yeats'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPledgeDialog(BuildContext context, HiveService hive) async {
    final hasPledged = await hive.hasPledgedToday();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, size: 60, color: AppTheme.accentColor),
              const SizedBox(height: 16),
              const Text(
                'Today I Will Not Hurt Myself',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'While I accept myself if I fail,\nTODAY I WILL TRY',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('Because I want to feel better'),
              const SizedBox(height: 24),
              if (hasPledged)
                const Text(
                  'You already pledged today!',
                  style: TextStyle(color: Colors.green),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    await hive.markPledgedToday();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('I PLEDGE', style: TextStyle(fontSize: 16)),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe later'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDailyTrack(BuildContext context) {
    Navigator.pushNamed(context, '/journal');
  }
}

class _DailyCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DailyCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: hasEntry ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasEntry ? AppTheme.primaryColor : Colors.grey[200],
          ),
          child: Center(
            child: Text(
              date,
              style: TextStyle(
                fontSize: 14,
                fontWeight: hasEntry ? FontWeight.bold : FontWeight.normal,
                color: hasEntry ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
