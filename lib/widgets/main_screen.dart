import 'package:calm_urge/views/analytics/analytics_view.dart';
import 'package:calm_urge/views/calm_urge/calm_urge_view.dart';
import 'package:calm_urge/views/home/home_view.dart';
import 'package:calm_urge/views/journal/journal_view.dart';
import 'package:calm_urge/views/more/more_view.dart';
import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeView(),
    JournalView(),
    CalmUrgeView(),
    AnalyticsView(),
    MoreView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
