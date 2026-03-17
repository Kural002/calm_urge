import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/hive_service.dart';
import '../../widgets/bottom_nav.dart';
import '../../core/theme/app_theme.dart';

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
                      // Timer circles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTimerCircle(elapsed.inDays, 'Days'),
                          _buildTimerCircle(
                            elapsed.inHours.remainder(24),
                            'Hours',
                          ),
                          _buildTimerCircle(
                            elapsed.inMinutes.remainder(60),
                            'Mins',
                          ),
                          _buildTimerCircle(
                            elapsed.inSeconds.remainder(60),
                            'Secs',
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Text(
                                'Handling it well since',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                startTime,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            label: 'Reset',
                            color: Colors.red,
                            onPressed: () => _resetStreak(context),
                          ),
                          _buildActionButton(
                            label: 'Cancel',
                            color: Colors.grey,
                            onPressed: () => Navigator.pop(context),
                          ),
                          _buildActionButton(
                            label: 'Apply',
                            color: AppTheme.primaryColor,
                            onPressed: () => _applyChanges(context),
                          ),
                        ],
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }

  Widget _buildTimerCircle(int value, String label) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              center: Alignment.center,
              radius: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                value.toString().padLeft(2, '0'),
                key: ValueKey(value),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        elevation: 5,
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  void _resetStreak(BuildContext context) async {
    final hive = Provider.of<HiveService>(context, listen: false);
    await hive.resetStreak();
  }

  void _applyChanges(BuildContext context) {
    Navigator.pop(context);
  }
}

// Simple wave painter
class WavePainter extends CustomPainter {
  final Color color;
  WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.6,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      size.height * 0.7,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
