import 'package:calm_urge/core/router/app_router.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    String route;
    switch (index) {
      case 0:
        route = AppRouter.home;
        break;
      case 1:
        route = AppRouter.journal;
        break;
      case 2:
        route = AppRouter.calmUrge;
        break;
      case 3:
        route = AppRouter.analytics;
        break;
      case 4:
        route = AppRouter.more;
        break;
      default:
        return;
    }
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
        BottomNavigationBarItem(
          icon: Icon(Icons.self_improvement),
          label: 'CALM URGE',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
      ],
    );
  }
}
