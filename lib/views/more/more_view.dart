import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';
import '../../core/theme/app_theme.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSection('Premium', Icons.star, [
            _buildTile('Unlock Premium', Icons.lock_open, onTap: () {}),
          ]),
          _buildSection('Settings', Icons.settings, [
            _buildTile('Passcode', Icons.lock_outline),
            _buildTile('Language', Icons.language),
          ]),
          _buildSection('Support', Icons.support_agent, [
            _buildTile('Share App', Icons.share),
            _buildTile('Write Review', Icons.star_border),
            _buildTile('Feedback', Icons.feedback_outlined),
          ]),
          _buildSection('Legal', Icons.gavel, [
            _buildTile('Privacy policy', Icons.privacy_tip_outlined),
            _buildTile('Terms of Service', Icons.description_outlined),
          ]),
          _buildTile(
            'Troubles with purchases?',
            Icons.help_outline,
            isLast: true,
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Version 2.28.2',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 4),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildTile(
    String title,
    IconData icon, {
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: isLast ? 16 : 0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Icon(icon, color: AppTheme.primaryColor),
          title: Text(title),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppTheme.textSecondary,
          ),
          onTap: onTap ?? () {},
        ),
      ),
    );
  }
}
