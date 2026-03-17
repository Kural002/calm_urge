import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.textSecondary,
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/journal');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/calm-urge');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/analytics');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/more');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          activeIcon: Icon(Icons.book),
          label: 'Journal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.self_improvement),
          label: 'Calm Urge',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
      ],
    );
  }
}
