import 'package:calm_urge/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSectionHeader('Premium'),
          _buildTile('Unlock Premium', Icons.lock_open),
          const Divider(),
          _buildTile('Passcode', Icons.lock_outline),
          _buildTile('Share App', Icons.share),
          _buildTile('Write Review', Icons.star_border),
          _buildTile('Feedback', Icons.feedback_outlined),
          _buildTile('Language', Icons.language),
          _buildTile('Privacy policy', Icons.privacy_tip_outlined),
          _buildTile('Terms of Service', Icons.description_outlined),
          _buildTile('Troubles with purchases?', Icons.help_outline),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Version 2.28.2',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 4),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[700]),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
