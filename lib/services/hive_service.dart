import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';

class HiveService extends ChangeNotifier {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String journalBoxName = 'journal';
  static const String settingsBoxName = 'settings';

  late Box<JournalEntry> journalBox;
  late Box settingsBox;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    Hive.registerAdapter(JournalEntryAdapter());
    journalBox = await Hive.openBox<JournalEntry>(journalBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);
    _isInitialized = true;
    notifyListeners();
  }

  List<JournalEntry> get journalEntries => journalBox.values.toList();

  Future<void> addJournalEntry(JournalEntry entry) async {
    await journalBox.put(entry.id, entry);
    notifyListeners();
  }

  Future<void> updateJournalEntry(JournalEntry entry) async {
    await journalBox.put(entry.id, entry);
    notifyListeners();
  }

  Future<void> deleteJournalEntry(String id) async {
    await journalBox.delete(id);
    notifyListeners();
  }

  // --- Streak / Timer methods ---
  static const String streakStartKey = 'streakStart';

  DateTime? getStreakStart() {
    final timestamp = settingsBox.get(streakStartKey);
    if (timestamp == null) return null;
    return DateTime.parse(timestamp);
  }

  Future<void> setStreakStart(DateTime dateTime) async {
    await settingsBox.put(streakStartKey, dateTime.toIso8601String());
    notifyListeners();
  }

  Future<void> resetStreak() async {
    await setStreakStart(DateTime.now());
  }

  Duration getElapsedSinceStart() {
    final start = getStreakStart();
    if (start == null) return Duration.zero;
    return DateTime.now().difference(start);
  }

  // For "Harm Free Since" display (formatted string)
  String getFormattedElapsed() {
    final elapsed = getElapsedSinceStart();
    final days = elapsed.inDays;
    final hours = elapsed.inHours.remainder(24);
    final minutes = elapsed.inMinutes.remainder(60);
    final seconds = elapsed.inSeconds.remainder(60);
    return '$days Days $hours Hours $minutes Minutes $seconds Seconds';
  }

  // Get start time as formatted string (e.g., "Tuesday, 17 March 08:51")
  String getFormattedStartTime() {
    final start = getStreakStart();
    if (start == null) return 'Not set';
    return DateFormat('EEEE, d MMMM HH:mm').format(start);
  }

  // --- Daily Pledge check ---
  static const String lastPledgeDateKey = 'lastPledgeDate';

  Future<bool> hasPledgedToday() async {
    final lastDateStr = settingsBox.get(lastPledgeDateKey);
    if (lastDateStr == null) return false;
    final lastDate = DateTime.parse(lastDateStr);
    final now = DateTime.now();
    return lastDate.year == now.year &&
        lastDate.month == now.month &&
        lastDate.day == now.day;
  }

  Future<void> markPledgedToday() async {
    await settingsBox.put(lastPledgeDateKey, DateTime.now().toIso8601String());
    notifyListeners();
  }

  // --- Daily Message (static, but could be stored if we want to track seen messages)
  // For now we just show a random or fixed message.
}
