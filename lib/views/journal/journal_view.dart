import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/journal_entry.dart';
import '../../services/hive_service.dart';
import '../../widgets/bottom_nav.dart';

class JournalView extends StatefulWidget {
  const JournalView({super.key});

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEntryDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Month header
            Text(
              DateFormat('MMMM yyyy').format(DateTime.now()),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Calendar grid with entry indicators
            Consumer<HiveService>(
              builder: (context, hive, child) {
                final entries = hive.journalEntries;
                return Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: 35,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      if (day > 31) return Container();
                      final date = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        day,
                      );
                      final hasEntry = entries.any(
                        (e) =>
                            e.createdAt.year == date.year &&
                            e.createdAt.month == date.month &&
                            e.createdAt.day == date.day,
                      );
                      return GestureDetector(
                        onTap: () => _showEntriesForDay(date, entries),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: hasEntry ? Colors.blue[50] : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('E').format(date).substring(0, 3),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '$day',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (hasEntry)
                                const Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Colors.blue,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddEntryDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Entry'),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Share Journal'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Journal Entry'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Enter content' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final hive = Provider.of<HiveService>(context, listen: false);
                final entry = JournalEntry(
                  id: const Uuid().v4(),
                  title: _titleController.text,
                  content: _contentController.text,
                  createdAt: DateTime.now(),
                );
                await hive.addJournalEntry(entry);
                _titleController.clear();
                _contentController.clear();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEntriesForDay(DateTime date, List<JournalEntry> entries) {
    final dayEntries = entries
        .where(
          (e) =>
              e.createdAt.year == date.year &&
              e.createdAt.month == date.month &&
              e.createdAt.day == date.day,
        )
        .toList();

    if (dayEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No entries for ${DateFormat.yMMMd().format(date)}'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DateFormat.yMMMd().format(date)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dayEntries.length,
            itemBuilder: (context, i) {
              final entry = dayEntries[i];
              return ListTile(
                title: Text(entry.title),
                subtitle: Text(entry.content),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final hive = Provider.of<HiveService>(
                      context,
                      listen: false,
                    );
                    await hive.deleteJournalEntry(entry.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
