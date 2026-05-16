import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class AnalyticsData {
  final List<ChartDataPoint> weeklyScans;
  final List<ChartDataPoint> diseaseDistribution;
  final List<ChartDataPoint> weatherImpact;
  final Map<String, int> cropHealthStats;
  final List<ActivityTrend> activityTrends;

  AnalyticsData({
    required this.weeklyScans,
    required this.diseaseDistribution,
    required this.weatherImpact,
    required this.cropHealthStats,
    required this.activityTrends,
  });
}

class ChartDataPoint {
  final String label;
  final double value;
  final DateTime? date;

  ChartDataPoint({
    required this.label,
    required this.value,
    this.date,
  });
}

class ActivityTrend {
  final DateTime date;
  final int scans;
  final int chats;
  final int weatherChecks;

  ActivityTrend({
    required this.date,
    required this.scans,
    required this.chats,
    required this.weatherChecks,
  });
}

class AdvancedAnalyticsService {
  static AnalyticsData generateSampleData() {
    final now = DateTime.now();

    // Weekly scans data
    final weeklyScans = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return ChartDataPoint(
        label: _getDayName(date.weekday),
        value: Random().nextInt(8) + 1,
        date: date,
      );
    });

    // Disease distribution
    final diseaseDistribution = [
      ChartDataPoint(label: 'Healthy', value: 65),
      ChartDataPoint(label: 'Leaf Spot', value: 15),
      ChartDataPoint(label: 'Rust', value: 12),
      ChartDataPoint(label: 'Blight', value: 8),
    ];

    // Weather impact
    final weatherImpact = [
      ChartDataPoint(label: 'Rain', value: 85),
      ChartDataPoint(label: 'Sun', value: 92),
      ChartDataPoint(label: 'Cloud', value: 78),
      ChartDataPoint(label: 'Wind', value: 70),
    ];

    // Crop health stats
    final cropHealthStats = {
      'Maize': 78,
      'Beans': 85,
      'Cassava': 72,
      'Rice': 90,
      'Vegetables': 82,
    };

    // Activity trends
    final activityTrends = List.generate(14, (index) {
      final date = now.subtract(Duration(days: 13 - index));
      return ActivityTrend(
        date: date,
        scans: Random().nextInt(5) + 1,
        chats: Random().nextInt(8) + 2,
        weatherChecks: Random().nextInt(3) + 1,
      );
    });

    return AnalyticsData(
      weeklyScans: weeklyScans,
      diseaseDistribution: diseaseDistribution,
      weatherImpact: weatherImpact,
      cropHealthStats: cropHealthStats,
      activityTrends: activityTrends,
    );
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}

class AnalyticsCharts {
  static Widget buildWeeklyScansChart(List<ChartDataPoint> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Crop Scans',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final point = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: point.value,
                          color: const Color(0xFF4CAF50),
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < data.length) {
                            return Text(
                              data[value.toInt()].label,
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildDiseaseDistributionChart(List<ChartDataPoint> data) {
    final total = data.fold(0.0, (sum, item) => sum + item.value);
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFFF44336),
      const Color(0xFF9C27B0),
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disease Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sections: data.asMap().entries.map((entry) {
                          final index = entry.key;
                          final point = entry.value;
                          final percentage = (point.value / total) * 100;

                          return PieChartSectionData(
                            value: point.value,
                            title: '${percentage.toStringAsFixed(0)}%',
                            color: colors[index % colors.length],
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final point = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                point.label,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildActivityTrendsChart(List<ActivityTrend> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '14-Day Activity Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < data.length && value.toInt() % 3 == 0) {
                            return Text(
                              data[value.toInt()].date.day.toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.scans.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.chats.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Scans', Colors.blue),
                const SizedBox(width: 24),
                _buildLegendItem('Chats', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}