import 'package:calm_urge/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(child: Text('Analytics screen – placeholder')),
      bottomNavigationBar: BottomNav(currentIndex: 3),
    );
  }
}
