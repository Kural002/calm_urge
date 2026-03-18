import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'more_widgets.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          SettingsSection(
            title: 'Premium',
            icon: Icons.star,
            children: [
              SettingsTile(
                title: 'Unlock Premium',
                icon: Icons.lock_open,
                onTap: () {},
              ),
            ],
          ),

          const SettingsSection(
            title: 'Support',
            icon: Icons.support_agent,
            children: [
              SettingsTile(title: 'Share App', icon: Icons.share),
              SettingsTile(title: 'Write Review', icon: Icons.star_border),
              SettingsTile(title: 'Feedback', icon: Icons.feedback_outlined),
            ],
          ),
          const SettingsSection(
            title: 'Legal',
            icon: Icons.gavel,
            children: [
              SettingsTile(
                title: 'Privacy policy',
                icon: Icons.privacy_tip_outlined,
              ),
              SettingsTile(
                title: 'Terms of Service',
                icon: Icons.description_outlined,
              ),
            ],
          ),
          const SettingsTile(
            title: 'Troubles with purchases?',
            icon: Icons.help_outline,
            isLast: true,
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Version 2.28.2',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
