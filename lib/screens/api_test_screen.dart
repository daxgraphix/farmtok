import 'package:flutter/material.dart';
import '../services/api_test_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  Map<String, dynamic>? _testResults;
  bool _isTesting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Tests'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API Functionality Tests',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test all APIs and services to ensure everything works properly.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isTesting ? null : _runTests,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isTesting
                  ? const CircularProgressIndicator()
                  : const Text('Run All Tests'),
            ),

            const SizedBox(height: 24),

            if (_testResults != null) ...[
              _buildOverallStatus(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildTestResults(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatus() {
    final status = _testResults!['overall_status'];
    final isPassed = status == 'passed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPassed ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPassed ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPassed ? Icons.check_circle : Icons.error,
            color: isPassed ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPassed ? 'All Tests Passed' : 'Some Tests Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPassed ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  'Timestamp: ${_testResults!['timestamp']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResults() {
    final tests = _testResults!['tests'] as Map<String, dynamic>;

    return ListView.builder(
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final serviceName = tests.keys.elementAt(index);
        final testResult = tests[serviceName] as Map<String, dynamic>;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _getStatusIcon(testResult['status']),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        serviceName.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(testResult['message']),
                if (testResult.containsKey('error')) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${testResult['error']}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (testResult.containsKey('details')) ...[
                  const SizedBox(height: 8),
                  ..._buildDetails(testResult['details']),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDetails(Map<String, dynamic> details) {
    return details.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 4),
        child: Text(
          '${entry.key}: ${entry.value}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }).toList();
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'passed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'warning':
        return const Icon(Icons.warning, color: Colors.orange);
      case 'failed':
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  Future<void> _runTests() async {
    setState(() {
      _isTesting = true;
      _testResults = null;
    });

    try {
      final results = await ApiTestService.testAllServices();
      setState(() {
        _testResults = results;
      });

      // Also print to console for debugging
      ApiTestService.printTestResults(results);
    } catch (e) {
      setState(() {
        _testResults = {
          'overall_status': 'failed',
          'timestamp': DateTime.now().toIso8601String(),
          'error': e.toString(),
        };
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }
}