import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/hive_service.dart';
import '../../core/theme/app_theme.dart';
import 'calm_urge_widgets.dart';

class CalmUrgeView extends StatefulWidget {
  const CalmUrgeView({super.key});

  @override
  State<CalmUrgeView> createState() => _CalmUrgeViewState();
}

class _CalmUrgeViewState extends State<CalmUrgeView>
    with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _timer.cancel();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Calm Urge'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: CustomPaint(
              painter: WavePainter(
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ),
          // Rotating circles
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateController.value * 2 * 3.14159,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      width: 40,
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Consumer<HiveService>(
              builder: (context, hive, child) {
                final elapsed = hive.getElapsedSinceStart();
                final startTime = hive.getFormattedStartTime();
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      _buildTimerRow(elapsed),
                      const SizedBox(height: 40),
                      _buildStartDateCard(startTime),
                      const SizedBox(height: 40),
                      _buildActionButtonRow(),
                      const Spacer(flex: 3),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the timer circles row
  Widget _buildTimerRow(Duration elapsed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TimerCircle(value: elapsed.inDays, label: 'Days'),
        TimerCircle(value: elapsed.inHours.remainder(24), label: 'Hours'),
        TimerCircle(value: elapsed.inMinutes.remainder(60), label: 'Mins'),
        TimerCircle(value: elapsed.inSeconds.remainder(60), label: 'Secs'),
      ],
    );
  }

  /// Builds the card showing start date
  Widget _buildStartDateCard(String startTime) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Handling it well since',
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              startTime,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the action buttons row
  Widget _buildActionButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ActionButton(
          label: 'Reset',
          color: Colors.red,
          onPressed: () => _resetStreak(),
        ),
        ActionButton(label: 'Cancel', color: Colors.grey, onPressed: () {}),
        // ActionButton(
        //   label: 'Apply',
        //   color: AppTheme.primaryColor,
        //   onPressed: () {},
        // ),
      ],
    );
  }

  /// Resets the streak
  void _resetStreak() async {
    final hive = Provider.of<HiveService>(context, listen: false);
    await hive.resetStreak();
  }
}
