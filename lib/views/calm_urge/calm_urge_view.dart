import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/hive_service.dart';
import '../../widgets/bottom_nav.dart';

class CalmUrgeView extends StatefulWidget {
  const CalmUrgeView({super.key});

  @override
  State<CalmUrgeView> createState() => _CalmUrgeViewState();
}

class _CalmUrgeViewState extends State<CalmUrgeView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {}); // force rebuild to update time
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hive = Provider.of<HiveService>(context);
    final elapsed = hive.getElapsedSinceStart();
    final startTime = hive.getFormattedStartTime();

    return Scaffold(
      appBar: AppBar(title: const Text('CALM URGE')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TimeBox(value: elapsed.inDays.toString(), label: 'Days'),
                  _TimeBox(
                    value: elapsed.inHours.remainder(24).toString(),
                    label: 'Hours',
                  ),
                  _TimeBox(
                    value: elapsed.inMinutes.remainder(60).toString(),
                    label: 'Minutes',
                  ),
                  _TimeBox(
                    value: elapsed.inSeconds.remainder(60).toString(),
                    label: 'Seconds',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'I’ve been handling it well since\n$startTime',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => _resetStreak(context),
                  child: const Text('Reset'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _applyChanges(context),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }

  void _resetStreak(BuildContext context) async {
    final hive = Provider.of<HiveService>(context, listen: false);
    await hive.resetStreak();
    setState(() {}); // update immediately
  }

  void _applyChanges(BuildContext context) {
    // Possibly save any adjustments (like manual time set) - not implemented
    Navigator.pop(context);
  }
}

class _TimeBox extends StatelessWidget {
  final String value;
  final String label;
  const _TimeBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
