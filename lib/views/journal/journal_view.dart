import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/journal_entry.dart';
import '../../services/hive_service.dart';
import '../../core/theme/app_theme.dart';

class JournalView extends StatefulWidget {
  const JournalView({super.key});

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimation;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fabAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _fabAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          DateFormat('MMMM yyyy').format(_selectedMonth),
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          Container(

            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.primaryColor.withOpacity(0.5),
              shape: BoxShape.rectangle,
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              onPressed: _showMonthPicker,
              tooltip: 'Change month',
              color: AppTheme.surfaceColor,
            ),
          ),
        ],
      ),
      body: Consumer<HiveService>(
        builder: (context, hive, child) {
          // Filter journal entries by selected month
          final entries = hive.journalEntries
              .where(
                (e) =>
                    e.createdAt.year == _selectedMonth.year &&
                    e.createdAt.month == _selectedMonth.month,
              )
              .toList();
          return Column(
            children: [
              _buildCalendar(entries),
              Expanded(child: _buildEntriesList(entries)),
            ],
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _showAddEntryDialog,
          icon: const Icon(Icons.add),
          label: const Text('New Entry'),
          backgroundColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCalendar(List<JournalEntry> entries) {
    /// Calendar grid calculation
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;
    final firstWeekday =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday %
        7; // 0 = Sunday

    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), // Added more horizontal margin to shrink calendar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2, // Slightly wider than tall to reduce vertical height
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final day = index - firstWeekday + 1;
              if (day < 1 || day > daysInMonth) return Container();
              final date = DateTime(
                _selectedMonth.year,
                _selectedMonth.month,
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
                    shape: BoxShape.circle,
                    color: hasEntry
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        fontWeight: hasEntry
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: hasEntry
                            ? AppTheme.primaryColor
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No entries yet', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          child: Dismissible(
            key: Key(entry.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deleteEntry(entry.id);
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  entry.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: Text(
                entry.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.MMMd().format(entry.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.jm().format(entry.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'New Journal Entry',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Enter content' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final hive = Provider.of<HiveService>(
                            context,
                            listen: false,
                          );
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
              ],
            ),
          ),
        ),
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat.yMMMd().format(date),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...dayEntries.map(
                (entry) => Dismissible(
                  key: Key(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    final hive = Provider.of<HiveService>(
                      context,
                      listen: false,
                    );
                    await hive.deleteJournalEntry(entry.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(entry.title),
                    subtitle: Text(entry.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Text(
                      DateFormat.jm().format(entry.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteEntry(String id) async {
    final hive = Provider.of<HiveService>(context, listen: false);
    await hive.deleteJournalEntry(id);
  }

  void _showMonthPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }
}
