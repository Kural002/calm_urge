import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 0)
class JournalEntry {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? updatedAt;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });
}
