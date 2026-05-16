import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/local_cache_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Map<String, dynamic>> _scans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      final scans = await LocalCacheService.getCachedScans();
      setState(() {
        _scans = scans.map((scan) => scan.toJson()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading analytics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Scans',
                          _scans.length.toString(),
                          Icons.camera_alt,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Healthy Crops',
                          '${_calculateHealthyPercentage().toStringAsFixed(1)}%',
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Diseases Found',
                          _scans.where((scan) => scan['confidence'] > 0.5).length.toString(),
                          Icons.warning,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'This Week',
                          _getScansThisWeek().toString(),
                          Icons.calendar_today,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Disease trends chart
                  Text(
                    'Disease Trends',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 200,
                        child: _buildDiseaseChart(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Scan activity chart
                  Text(
                    'Scan Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 200,
                        child: _buildActivityChart(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent scans
                  Text(
                    'Recent Scans',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._scans.take(5).map((scan) => _buildRecentScanCard(scan)),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateHealthyPercentage() {
    if (_scans.isEmpty) return 100.0;
    final healthyScans = _scans.where((scan) => scan['confidence'] < 0.3).length;
    return (healthyScans / _scans.length) * 100;
  }

  int _getScansThisWeek() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _scans.where((scan) {
      final scanDate = DateTime.parse(scan['created_at']);
      return scanDate.isAfter(weekAgo);
    }).length;
  }

  Widget _buildDiseaseChart() {
    // Group diseases by type
    final diseaseCounts = <String, int>{};
    for (final scan in _scans) {
      final disease = scan['disease_name'] as String;
      diseaseCounts[disease] = (diseaseCounts[disease] ?? 0) + 1;
    }

    final sections = diseaseCounts.entries.map((entry) {
      final colors = [Colors.red, Colors.orange, Colors.yellow, Colors.blue, Colors.green];
      final index = diseaseCounts.keys.toList().indexOf(entry.key) % colors.length;

      return PieChartSectionData(
        color: colors[index],
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildActivityChart() {
    // Create activity data for last 7 days
    final last7Days = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final scansOnDay = _scans.where((scan) {
        final scanDate = DateTime.parse(scan['created_at']);
        return scanDate.year == date.year &&
               scanDate.month == date.month &&
               scanDate.day == date.day;
      }).length;

      return FlSpot(index.toDouble(), scansOnDay.toDouble());
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final day = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                return Text('${day.day}/${day.month}');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: last7Days,
            isCurved: true,
            color: const Color(0xFF2E7D32),
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            ),
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScanCard(Map<String, dynamic> scan) {
    final createdAt = DateTime.parse(scan['created_at']);
    final confidence = (scan['confidence'] as double) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: confidence > 50 ? Colors.red.shade100 : Colors.green.shade100,
          child: Icon(
            confidence > 50 ? Icons.warning : Icons.check_circle,
            color: confidence > 50 ? Colors.red : Colors.green,
          ),
        ),
        title: Text(scan['disease_name']),
        subtitle: Text(
          '${createdAt.day}/${createdAt.month}/${createdAt.year} • ${confidence.toStringAsFixed(1)}% confidence',
        ),
        trailing: Text(
          scan['treatment'].toString().split('.').first,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}