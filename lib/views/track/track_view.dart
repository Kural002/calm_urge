import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../models/journal_entry.dart';
import '../../services/hive_service.dart';

class TrackView extends StatefulWidget {
  const TrackView({super.key});

  @override
  State<TrackView> createState() => _TrackViewState();
}

class _TrackViewState extends State<TrackView> {
  // Selections
  bool? _avoidedSelfHarm;
  final TextEditingController _noteController = TextEditingController();
  String? _difficulty;
  final Set<String> _feelings = {};
  final Set<String> _concerns = {};

  // Custom inputs
  final List<String> _customFeelings = [];
  final List<String> _customConcerns = [];

  // Options matching the screenshot
  final List<String> _difficultyOptions = [
    'Easy',
    'Not bad',
    'Medium',
    'Hard',
    'Impossible'
  ];

  final List<String> _feelingsOptions = [
    'Calm', 'Anxious', 'Depressed', 'Sad',
    'Tired', 'Stressed', 'Angry', 'Scared',
    'Frustrated', 'Guilty', 'Upset', 'Bored'
  ];

  final List<String> _concernsOptions = [
    'Work', 'Love', 'Study', 'Friends',
    'Past', 'Financial', 'Future', 'Health',
    'Food', 'Body', 'Family', 'Time'
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveEntry() async {
    final hive = Provider.of<HiveService>(context, listen: false);

    // Build the string representation of the entry
    final buffer = StringBuffer();
    if (_avoidedSelfHarm != null) {
      buffer.writeln('Avoided self-harm: ${_avoidedSelfHarm! ? "Yes" : "No"}');
    }
    if (_noteController.text.trim().isNotEmpty) {
      buffer.writeln('Note: ${_noteController.text.trim()}');
    }
    if (_difficulty != null) {
      buffer.writeln('Difficulty: $_difficulty');
    }
    if (_feelings.isNotEmpty) {
      buffer.writeln('Feelings: ${_feelings.join(", ")}');
    }
    if (_concerns.isNotEmpty) {
      buffer.writeln('Concerns: ${_concerns.join(", ")}');
    }

    final entry = JournalEntry(
      id: const Uuid().v4(),
      title: 'Daily Track',
      content: buffer.toString().trim().isEmpty ? 'Empty track entry' : buffer.toString().trim(),
      createdAt: DateTime.now(),
    );

    await hive.addJournalEntry(entry);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _addCustomOption(String title, Function(String) onAdd) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your custom $title...',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onAdd(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.calmUrgeRed, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              todayStr,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 30),
            
            // Self Harm Section
            const Text(
              'Were you able to avoid self-harm?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBinaryButton('No', _avoidedSelfHarm == false, () {
                  setState(() => _avoidedSelfHarm = false);
                }),
                const SizedBox(width: 16),
                _buildBinaryButton('Yes', _avoidedSelfHarm == true, () {
                  setState(() => _avoidedSelfHarm = true);
                }),
              ],
            ),
            const SizedBox(height: 20),

            // Note Text Field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'leave a note here...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Difficulty Section
            const Text(
              'How difficult was your day?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _difficultyOptions.map((opt) {
                final isSelected = _difficulty == opt;
                return _buildPill(
                  opt, 
                  isSelected, 
                  () => setState(() => _difficulty = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Feelings Section
            const Text(
              'How you felt?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildCustomPill(() {
                  _addCustomOption('feeling', (val) {
                    setState(() {
                      if (!_customFeelings.contains(val)) _customFeelings.add(val);
                      _feelings.add(val);
                    });
                  });
                }),
                ..._customFeelings.map((opt) => _buildPill(
                  opt,
                  _feelings.contains(opt),
                  () => setState(() {
                    _feelings.contains(opt) ? _feelings.remove(opt) : _feelings.add(opt);
                  }),
                )),
                ..._feelingsOptions.map((opt) => _buildPill(
                  opt,
                  _feelings.contains(opt),
                  () => setState(() {
                    _feelings.contains(opt) ? _feelings.remove(opt) : _feelings.add(opt);
                  }),
                )),
              ],
            ),
            const SizedBox(height: 30),

            // Concerns Section
            const Text(
              'What were your concerns?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildCustomPill(() {
                  _addCustomOption('concern', (val) {
                    setState(() {
                      if (!_customConcerns.contains(val)) _customConcerns.add(val);
                      _concerns.add(val);
                    });
                  });
                }),
                ..._customConcerns.map((opt) => _buildPill(
                  opt,
                  _concerns.contains(opt),
                  () => setState(() {
                    _concerns.contains(opt) ? _concerns.remove(opt) : _concerns.add(opt);
                  }),
                )),
                ..._concernsOptions.map((opt) => _buildPill(
                  opt,
                  _concerns.contains(opt),
                  () => setState(() {
                    _concerns.contains(opt) ? _concerns.remove(opt) : _concerns.add(opt);
                  }),
                )),
              ],
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('Save Entry', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBinaryButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPill(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.8), // Using a shade of the theme's primary blue color
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Custom',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
