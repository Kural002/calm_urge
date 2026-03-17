import 'package:calm_urge/views/analytics/analytics_view.dart';
import 'package:calm_urge/views/calm_urge/calm_urge_view.dart';
import 'package:calm_urge/views/home/home_view.dart';
import 'package:calm_urge/views/journal/journal_view.dart';
import 'package:calm_urge/views/more/more_view.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String home = '/';
  static const String journal = '/journal';
  static const String calmUrge = '/calm-urge';
  static const String analytics = '/analytics';
  static const String more = '/more';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case journal:
        return MaterialPageRoute(builder: (_) => const JournalView());
      case calmUrge:
        return MaterialPageRoute(builder: (_) => const CalmUrgeView());
      case analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsView());
      case more:
        return MaterialPageRoute(builder: (_) => const MoreView());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
