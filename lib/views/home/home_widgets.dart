import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Time unit widget displaying animated countdown for home header
class TimeUnit extends StatelessWidget {
  final int value;
  final String label;

  const TimeUnit({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
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
}

/// Daily practice card with icon and tap handler
class DailyCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const DailyCard({
    super.key,
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

/// Day chip widget for recent activity strip display
class DayChip extends StatelessWidget {
  final String day;
  final String date;
  final bool hasEntry;

  const DayChip({
    super.key,
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
