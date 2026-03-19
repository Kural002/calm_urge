import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../services/hive_service.dart';
import '../../models/journal_entry.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  // Helper parsers
  int? _parseDifficulty(String content) {
    final match = RegExp(r'Difficulty:\s*(.*)').firstMatch(content);
    if (match != null) {
      final val = match.group(1)?.trim();
      switch (val) {
        case 'Easy': return 1;
        case 'Not bad': return 2;
        case 'Medium': return 3;
        case 'Hard': return 4;
        case 'Impossible': return 5;
      }
    }
    return null;
  }

  bool? _parseAvoidedSafely(String content) {
    final match = RegExp(r'Avoided self-harm:\s*(Yes|No)').firstMatch(content);
    if (match != null) {
      return match.group(1) == 'Yes';
    }
    return null;
  }

  List<String> _parseList(String content, String key) {
    final match = RegExp('$key:\\s*(.*)').firstMatch(content);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Consumer<HiveService>(
        builder: (context, hive, child) {
          final entries = hive.journalEntries..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          if (entries.isEmpty) {
            return const Center(child: Text('No entries to analyze yet. Keep tracking!'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSuccessRateRing(entries),
                const SizedBox(height: 30),
                _buildDifficultyChart(entries),
                const SizedBox(height: 30),
                _buildFrequencyChart(entries, 'Feelings', AppTheme.primaryColor),
                const SizedBox(height: 30),
                _buildFrequencyChart(entries, 'Concerns', AppTheme.secondaryColor),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessRateRing(List<JournalEntry> entries) {
    int totalAvoidanceInputs = 0;
    int successInputs = 0;

    for (var e in entries) {
      final safe = _parseAvoidedSafely(e.content);
      if (safe != null) {
        totalAvoidanceInputs++;
        if (safe) successInputs++;
      }
    }

    if (totalAvoidanceInputs == 0) return const SizedBox.shrink();

    final percentage = (successInputs / totalAvoidanceInputs * 100).toStringAsFixed(0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Harm-Free Rate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Avoided self-harm $successInputs out of $totalAvoidanceInputs times tracked', style: const TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
            SizedBox(
              height: 80,
              width: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: successInputs.toDouble(),
                          color: AppTheme.secondaryColor,
                          radius: 10,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: (totalAvoidanceInputs - successInputs).toDouble(),
                          color: Colors.grey[200]!,
                          radius: 10,
                          showTitle: false,
                        ),
                      ],
                      centerSpaceRadius: 30,
                      sectionsSpace: 0,
                    ),
                  ),
                  Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChart(List<JournalEntry> entries) {
    final Map<DateTime, int> difficultyData = {};
    for (var e in entries) {
      final diff = _parseDifficulty(e.content);
      if (diff != null) {
        // Just take the day date to avoid multiple points per day, or plot all. We'll map all points with index
        difficultyData[e.createdAt] = diff;
      }
    }

    if (difficultyData.isEmpty) return const SizedBox.shrink();

    final sortedKeys = difficultyData.keys.toList()..sort();
    
    // Convert to spots
    final List<FlSpot> spots = [];
    double minX = 0;
    double maxX = (sortedKeys.length - 1).toDouble();
    if (sortedKeys.length == 1) {
      // Keep dot centered by using whole numbers for interval compatibility
      minX = -1.0;
      maxX = 1.0;
    } else if (maxX < 0) {
      maxX = 0;    }
    
    for (int i = 0; i < sortedKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), difficultyData[sortedKeys[i]]!.toDouble()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Day Difficulty Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.only(right: 30, top: 30, bottom: 10, left: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index < 0 || index >= sortedKeys.length) return const SizedBox.shrink();
                      // Only show a few labels to avoid clutter
                      if (sortedKeys.length > 7 && index % (sortedKeys.length ~/ 5) != 0 && index != sortedKeys.length - 1) {
                         return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('d MMM').format(sortedKeys[index]),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 45,
                    getTitlesWidget: (value, meta) {
                      String label = '';
                      switch (value.toInt()) {
                        case 1: label = 'Easy'; break;
                        case 3: label = 'Med'; break;
                        case 5: label = 'Hard'; break;
                      }
                      return Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: minX,
              maxX: maxX,
              minY: 1,
              maxY: 5,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppTheme.primaryColor,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.primaryColor.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyChart(List<JournalEntry> entries, String category, Color barColor) {
    final Map<String, int> frequencies = {};
    for (var e in entries) {
      final items = _parseList(e.content, category);
      for (var item in items) {
        frequencies[item] = (frequencies[item] ?? 0) + 1;
      }
    }

    if (frequencies.isEmpty) return const SizedBox.shrink();

    // Sort by frequency and take top 3
    final sortedEntries = frequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topItems = sortedEntries.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top $category', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.only(top: 20, right: 30, left: 20, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: topItems.first.value.toDouble() + 1,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < 0 || value.toInt() >= topItems.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          topItems[value.toInt()].key,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: topItems.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.value.toDouble(),
                      color: barColor,
                      width: 25,
                      borderRadius: BorderRadius.circular(6),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: topItems.first.value.toDouble() + 1,
                        color: barColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
